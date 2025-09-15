import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:datalens/core/utils/logger.dart';
import 'package:datalens/features/image_processor/model/image_processing_response.dart';

/// Service class for handling image processing API calls
class ImageProcessingService {
  /// Base URL for the API - you can configure this in app_config later
  static const String _baseUrl = 'https://datalens-541929b8c017.herokuapp.com'; // Replace with your actual API endpoint

  /// Upload an image to the processing API
  /// Returns ImageProcessingResponse on success
  /// Throws exception on failure
  Future<ImageProcessingResponse> processImage(File imageFile) async {
    try {
      logInfo('Starting image upload...');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'), // Replace with your actual endpoint
      );

      // Add the image file to the request
      // Determine content type based on file extension
      String contentType = 'image/jpeg';
      final extension = imageFile.path.toLowerCase().split('.').last;
      switch (extension) {
        case 'png':
          contentType = 'image/png';
          break;
        case 'jpg':
        case 'jpeg':
          contentType = 'image/jpeg';
          break;
        case 'gif':
          contentType = 'image/gif';
          break;
        case 'webp':
          contentType = 'image/webp';
          break;
        default:
          contentType = 'image/jpeg';
      }
      
      final file = await http.MultipartFile.fromPath(
        'file', // This should match your API's expected field name
        imageFile.path,
        contentType: MediaType.parse(contentType),
      );

      request.files.add(file);

      // Add any additional headers if needed
      request.headers.addAll({
        'Accept': 'application/json',
        // Don't set Content-Type manually for multipart/form-data
        // The http package will set it automatically with the boundary
      });

      logInfo('Request URL: ${request.url}');
      logInfo('Request method: ${request.method}');
      logInfo('Request headers: ${request.headers}');
      logInfo('File field name: file');
      logInfo('File path: ${imageFile.path}');
      logInfo('File content type: $contentType');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      logInfo('API response status: ${response.statusCode}');
      logInfo('API response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          // Parse the response
          final jsonData = json.decode(response.body) as Map<String, dynamic>;
          
          // Check if the API returned success
          if (jsonData['success'] == true) {
            final result = ImageProcessingResponse.fromJson(jsonData);
            logInfo('Image processing successful');
            return result;
          } else {
            throw Exception('API returned error: ${jsonData['error'] ?? 'Unknown error'}');
          }
        } catch (e) {
          logError('Error parsing API response: $e');
          throw Exception('Failed to parse API response: $e');
        }
      } else {
        String errorMessage = 'HTTP ${response.statusCode}';
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          // If response body is not JSON, use the raw body
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
        throw Exception('API request failed: $errorMessage');
      }
    } catch (e) {
      logError('Error processing image: $e');
      throw Exception('Failed to process image: $e');
    }
  }

  /// Test API connectivity
  Future<bool> testConnection() async {
    try {
      logInfo('Testing API connectivity...');
      final response = await http.get(
        Uri.parse('$_baseUrl/'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      logInfo('Connection test response: ${response.statusCode}');
      return response.statusCode < 500; // Accept any response that's not a server error
    } catch (e) {
      logError('Connection test failed: $e');
      return false;
    }
  }

  /// Mock implementation for testing (remove when you have real API)
  Future<ImageProcessingResponse> processImageMock(File imageFile) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 2));

    // Mock response
    return ImageProcessingResponse(
      text: "Document processed successfully",
      formFields: {
        "Last Name": "SMITH",
        "First Name": "JOHN",
        "Date of Birth": "01/15/1985",
        "Address": "123 Main St, City, State 12345",
        "Phone": "(555) 123-4567",
        "Email": "john.smith@email.com",
      },
    );
  }
}
