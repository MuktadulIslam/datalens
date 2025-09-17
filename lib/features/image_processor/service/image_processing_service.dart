import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:datalens/core/utils/logger.dart';
import 'package:datalens/features/image_processor/model/image_processing_response.dart';
import 'dart:async'; // Added for StreamSubscription and Completer

/// Service class for handling image processing API calls
class ImageProcessingService {
  /// Base URL for the API - you can configure this in app_config later
  static const String _baseUrl = 'https://datalens-541929b8c017.herokuapp.com'; // Replace with your actual API endpoint

  StreamSubscription<String>? _subscription;
  Completer<ImageProcessingResponse>? _completer;

  void cancelProcessing() {
    _subscription?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.completeError(Exception('Processing cancelled by user'));
    }
    _subscription = null;
    _completer = null;
  }

  /// Upload an image to the processing API
  /// Returns ImageProcessingResponse on success
  /// Throws exception on failure
  Future<ImageProcessingResponse> processImage(File imageFile) async {
    try {
      logInfo('Starting image upload...');

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/api/upload'), // Replace with your actual endpoint
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
        'Accept': 'text/event-stream',
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
      logInfo('API response status: ${streamedResponse.statusCode}');

      if (streamedResponse.statusCode != 200) {
        final response = await http.Response.fromStream(streamedResponse);
        String errorMessage = 'HTTP ${response.statusCode}';
        try {
          final errorData = json.decode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['error'] ?? errorData['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
        throw Exception('API request failed: $errorMessage');
      }

      // Handle SSE stream
      String fullChunk = '';
      String currentEvent = '';

      final lines = streamedResponse.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter());

      _completer = Completer<ImageProcessingResponse>();

      _subscription = lines.listen(
        (line) {
          if (line.isEmpty) return;

          if (line.startsWith('event: ')) {
            currentEvent = line.substring(7).trim();
            logInfo('SSE Event: $currentEvent');
          } else if (line.startsWith('data: ')) {
            final data = line.substring(6).trim();
            logInfo('SSE Data: $data');

            try {
              final jsonData = jsonDecode(data) as Map<String, dynamic>;

              if (currentEvent == 'start') {
                logInfo('Processing started: ${jsonData['status']}');
              } else if (currentEvent == 'token') {
                if (jsonData.containsKey('message')) {
                  logInfo('Progress: ${jsonData['message']}');
                } else if (jsonData.containsKey('chunk')) {
                  fullChunk += jsonData['chunk'] as String;
                }
              } else if (currentEvent == 'end') {
                if (jsonData['status'] == 'complete') {
                  // Parse the full chunk
                  final fullJson = jsonDecode(fullChunk) as Map<String, dynamic>;
                  final result = ImageProcessingResponse.fromJson(fullJson);
                  logInfo('Image processing successful');
                  _completer!.complete(result);
                } else {
                  _completer!.completeError(Exception('Processing failed: ${jsonData['status']}'));
                }
              }
            } catch (e) {
              logError('Error parsing SSE data: $e');
              if (!_completer!.isCompleted) {
                _completer!.completeError(e);
              }
            }
          }
        },
        onDone: () {
          if (!_completer!.isCompleted) {
            _completer!.completeError(Exception('Stream ended without "end" event'));
          }
          _subscription = null;
          _completer = null;
        },
        onError: (e) {
          if (!_completer!.isCompleted) {
            _completer!.completeError(e);
          }
          _subscription = null;
          _completer = null;
        },
        cancelOnError: true,
      );

      return _completer!.future;

    } catch (e) {
      logError('Error processing image: $e');
      throw Exception('Failed to process image: $e');
    }
  }
}
