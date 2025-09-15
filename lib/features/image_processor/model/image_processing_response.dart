/// Model class for the API response from image processing
class ImageProcessingResponse {
  final String text;
  final Map<String, String> formFields;
  final double? processingTime;
  final Map<String, dynamic>? imageInfo;
  final bool success;

  const ImageProcessingResponse({
    required this.text,
    required this.formFields,
    this.processingTime,
    this.imageInfo,
    this.success = true,
  });

  /// Factory constructor to create an instance from JSON
  factory ImageProcessingResponse.fromJson(Map<String, dynamic> json) {
    // Handle the new API response format with extracted_data wrapper
    final extractedData = json['extracted_data'] as Map<String, dynamic>;
    
    return ImageProcessingResponse(
      text: extractedData['text'] as String,
      formFields: Map<String, String>.from(extractedData['form_fields'] as Map<dynamic, dynamic>),
      processingTime: (json['processing_time'] as num?)?.toDouble(),
      imageInfo: json['image_info'] as Map<String, dynamic>?,
      success: json['success'] as bool? ?? true,
    );
  }

  /// Convert to JSON (useful for debugging or serialization)
  Map<String, dynamic> toJson() {
    return {
      'extracted_data': {
        'text': text,
        'form_fields': formFields,
      },
      'processing_time': processingTime,
      'image_info': imageInfo,
      'success': success,
    };
  }
}
