import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:datalens/core/widgets/app_button.dart';
import 'package:datalens/core/utils/logger.dart';
import 'package:datalens/core/app_theme.dart';
import 'package:datalens/features/image_processor/service/image_processing_service.dart';
import 'package:datalens/features/image_processor/model/image_processing_response.dart';

/// Main page for image processing functionality
class ImageProcessorPage extends StatefulWidget {
  const ImageProcessorPage({super.key});

  @override
  State<ImageProcessorPage> createState() => _ImageProcessorPageState();
}

class _ImageProcessorPageState extends State<ImageProcessorPage> {
  final ImagePicker _picker = ImagePicker();
  final ImageProcessingService _service = ImageProcessingService();

  File? _selectedImage;
  ImageProcessingResponse? _processingResult;
  bool _isProcessing = false;
  String? _errorMessage;
  String? _debugInfo;

  @override
  void initState() {
    super.initState();
    _testApiConnection();
  }

  /// Test API connection on app start
  Future<void> _testApiConnection() async {
    try {
      final isConnected = await _service.testConnection();
      setState(() {
        _debugInfo = isConnected 
            ? 'API connection successful' 
            : 'API connection failed - server may be down';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Connection test error: $e';
      });
    }
  }

  /// Show options to pick image from camera or gallery
  Future<void> _showImageSourceDialog() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Image Source',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.darkGray,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.camera);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryPurple.withOpacity(0.1),
                                AppTheme.secondaryPink.withOpacity(0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.primaryPurple.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryPurple.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: AppTheme.primaryPurple,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Camera',
                                style: TextStyle(
                                  color: AppTheme.darkGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                          _pickImage(ImageSource.gallery);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.accentBlue.withOpacity(0.1),
                                AppTheme.accentBlue.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.accentBlue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentBlue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.photo_library_rounded,
                                  color: AppTheme.accentBlue,
                                  size: 32,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Gallery',
                                style: TextStyle(
                                  color: AppTheme.darkGray,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Pick image from specified source
  Future<void> _pickImage(ImageSource source) async {
    try {
      // Clear previous messages
      _clearMessages();

      // Request permissions if needed
      final permission = source == ImageSource.camera
          ? Permission.camera
          : Permission.photos;

      logInfo('Requesting ${source == ImageSource.camera ? 'camera' : 'gallery'} permission...');
      setState(() => _debugInfo = 'Requesting ${source == ImageSource.camera ? 'camera' : 'gallery'} permission...');

      final status = await permission.request();

      if (status.isDenied) {
        setState(() => _debugInfo = 'Permission denied');
        _showError('Permission denied. Please enable ${source == ImageSource.camera ? 'camera' : 'gallery'} access in app settings.');
        return;
      }

      if (status.isPermanentlyDenied) {
        setState(() => _debugInfo = 'Permission permanently denied');
        _showError('Permission permanently denied. Please go to app settings and enable ${source == ImageSource.camera ? 'camera' : 'gallery'} access.');
        // Optionally open app settings
        await openAppSettings();
        return;
      }

      setState(() => _debugInfo = 'Permission granted. Opening ${source == ImageSource.camera ? 'camera' : 'gallery'}...');
      logInfo('Permission granted. Opening ${source == ImageSource.camera ? 'camera' : 'gallery'}...');

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920, // Limit image size for better performance
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear, // Use rear camera by default
      );

      if (image != null) {
        // Verify file exists and is readable
        final file = File(image.path);
        if (await file.exists()) {
          final fileSize = await file.length();
          logInfo('Image selected successfully. Path: ${image.path}, Size: ${fileSize} bytes');

          setState(() {
            _selectedImage = file;
            _processingResult = null; // Clear previous results
            _errorMessage = null;
            _debugInfo = 'Image selected successfully (${(fileSize / 1024).round()} KB)';
          });
        } else {
          setState(() => _debugInfo = 'Selected file does not exist');
          _showError('Selected image file does not exist or is not accessible.');
        }
      } else {
        logInfo('User cancelled image selection');
        // Don't show error for user cancellation
      }
    } catch (e) {
      logError('Error picking image: $e');

      // Provide more specific error messages with troubleshooting steps
      String errorMessage = 'Failed to pick image';
      String troubleshooting = '';

      if (e.toString().contains('camera')) {
        errorMessage = 'Camera access failed';
        troubleshooting = '• Make sure no other app is using the camera\n• Check camera permissions in app settings\n• Try restarting the app';
      } else if (e.toString().contains('gallery') || e.toString().contains('photo') || e.toString().contains('storage')) {
        errorMessage = 'Gallery access failed';
        troubleshooting = '• Grant storage/gallery permissions\n• Make sure you have photos in your gallery\n• Try selecting a different image';
      } else if (e.toString().contains('permission')) {
        errorMessage = 'Permission denied';
        troubleshooting = '• Go to Settings > Apps > Doc Ext > Permissions\n• Enable Camera and Storage permissions\n• Restart the app';
      } else {
        troubleshooting = '• Make sure the device has a camera/gallery\n• Check available storage space\n• Try restarting the app';
      }

      _showError('$errorMessage\n\nTroubleshooting:\n$troubleshooting');
    }
  }

  /// Process the selected image
  Future<void> _processImage() async {
    if (_selectedImage == null) {
      _showError('Please select an image first');
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _debugInfo = 'Processing image...';
    });

    try {
      // Use real API implementation
      final result = await _service.processImage(_selectedImage!);

      setState(() {
        _processingResult = result;
        _debugInfo = 'Processing completed successfully in ${result.processingTime?.toStringAsFixed(2) ?? 'unknown'} seconds';
      });

      logInfo('Image processed successfully');
    } catch (e) {
      logError('Error processing image: $e');
      setState(() {
        _debugInfo = 'API Error: $e';
      });
      
      // Provide more user-friendly error messages
      String userMessage = 'Failed to process image';
      if (e.toString().contains('Connection refused') || e.toString().contains('SocketException')) {
        userMessage = 'Cannot connect to the server. Please check your internet connection and make sure the API server is running.';
      } else if (e.toString().contains('HTTP 404')) {
        userMessage = 'API endpoint not found. Please check the server configuration.';
      } else if (e.toString().contains('HTTP 500')) {
        userMessage = 'Server error occurred while processing the image. Please try again.';
      } else if (e.toString().contains('Failed to parse API response')) {
        userMessage = 'Received invalid response from server. Please check the API format.';
      }
      
      _showError(userMessage);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Show error message
  void _showError(String message) {
    setState(() {
      _errorMessage = message;
      _debugInfo = null; // Clear debug info when showing error
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Clear all errors and debug info
  void _clearMessages() {
    setState(() {
      _errorMessage = null;
      _debugInfo = null;
    });
  }

  /// Build the header section with title and subtitle
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryPurple, AppTheme.secondaryPink],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Document Scanner',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.darkGray,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Capture & extract document data',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.darkGray.withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build error card with modern design
  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.red.shade50,
            Colors.red.shade100.withOpacity(0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                color: Colors.red.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Error',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red.shade700,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// Build debug card with modern design
  Widget _buildDebugCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.1),
            AppTheme.accentBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bug_report_rounded,
                color: AppTheme.accentBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Debug Info',
                style: TextStyle(
                  color: AppTheme.accentBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _debugInfo!,
            style: TextStyle(
              color: AppTheme.accentBlue.withOpacity(0.8),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.lightGray,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section
                  _buildHeader(),

                  const SizedBox(height: 32),

                  // Image selection section
                  _buildImageSection(),

                  const SizedBox(height: 10),

                  // Upload button
                  if (_selectedImage != null)
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 500),
                      offset: const Offset(0, 0),
                      child: AppButton(
                        label: _isProcessing ? 'Processing...' : 'Process Document',
                        icon: _isProcessing ? null : Icons.auto_fix_high_rounded,
                        isLoading: _isProcessing,
                        onPressed: _isProcessing ? null : _processImage,
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Error message
                  if (_errorMessage != null)
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      offset: const Offset(0, 0),
                      child: _buildErrorCard(),
                    ),

                  // Debug info (only show in debug mode)
                  if (_debugInfo != null && const bool.fromEnvironment('dart.vm.product') == false)
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 300),
                      offset: const Offset(0, 0),
                      child: _buildDebugCard(),
                    ),

                  // Results section
                  if (_processingResult != null) ...[
                    const SizedBox(height: 32),
                    AnimatedSlide(
                      duration: const Duration(milliseconds: 600),
                      offset: const Offset(0, 0),
                      child: _buildResultsSection(),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build the image selection and display section
  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.add_photo_alternate_rounded,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Document Upload',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Image display area
          GestureDetector(
            onTap: _showImageSourceDialog,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: _selectedImage != null
                    ? null
                    : LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.lightGray,
                          Colors.white,
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _selectedImage != null
                      ? AppTheme.successGreen
                      : AppTheme.primaryPurple.withOpacity(0.3),
                  width: 2,
                  style: BorderStyle.solid,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_selectedImage != null
                            ? AppTheme.successGreen
                            : AppTheme.primaryPurple)
                        .withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _selectedImage != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.successGreen.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryPurple.withOpacity(0.1),
                                  AppTheme.secondaryPink.withOpacity(0.1),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              Icons.cloud_upload_rounded,
                              size: 48,
                              color: AppTheme.primaryPurple,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Tap to select document',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppTheme.darkGray,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Camera or Gallery',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.darkGray.withOpacity(0.6),
                                ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          if (_selectedImage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.successGreen.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppTheme.successGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Document ready for processing',
                    style: TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build the results section with extracted text and form fields
  Widget _buildResultsSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.successGreen, AppTheme.accentBlue],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Processing Results',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.darkGray,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          // const SizedBox(height: 24),

          // // Extracted text - commented out for now
          // Container(
          //   padding: const EdgeInsets.all(20),
          //   decoration: BoxDecoration(
          //     gradient: LinearGradient(
          //       colors: [
          //         AppTheme.accentBlue.withOpacity(0.1),
          //         AppTheme.accentBlue.withOpacity(0.05),
          //       ],
          //     ),
          //     borderRadius: BorderRadius.circular(16),
          //     border: Border.all(
          //       color: AppTheme.accentBlue.withOpacity(0.3),
          //     ),
          //   ),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Row(
          //         children: [
          //           Icon(
          //             Icons.text_snippet_rounded,
          //             color: AppTheme.accentBlue,
          //             size: 20,
          //           ),
          //           const SizedBox(width: 8),
          //           Text(
          //             'Extracted Text',
          //             style: TextStyle(
          //               color: AppTheme.accentBlue,
          //               fontWeight: FontWeight.bold,
          //               fontSize: 16,
          //             ),
          //           ),
          //         ],
          //       ),
          //       const SizedBox(height: 12),
          //       Container(
          //         padding: const EdgeInsets.all(16),
          //         decoration: BoxDecoration(
          //           color: Colors.white,
          //           borderRadius: BorderRadius.circular(12),
          //           border: Border.all(
          //             color: AppTheme.accentBlue.withOpacity(0.2),
          //           ),
          //         ),
          //         child: Text(
          //           _processingResult!.text,
          //           style: TextStyle(
          //             color: AppTheme.darkGray,
          //             height: 1.5,
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),

          const SizedBox(height: 12.0),

          // Form fields
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.table_chart_rounded,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Form Fields',
                    style: TextStyle(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._processingResult!.formFields.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.lightGray,
                        Colors.white,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryPurple.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Field name - styled as a label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          entry.key,
                          style: TextStyle(
                            color: AppTheme.primaryPurple,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Field value - emphasized and distinct
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTheme.primaryPurple.withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryPurple.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            color: AppTheme.darkGray,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
