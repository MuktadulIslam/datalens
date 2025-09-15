# 📊 DataLens - AI-Powered Document Processing App

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-000000?style=for-the-badge&logo=ios&logoColor=white)

**An intelligent Flutter application that leverages AI to extract and process data from document images**

[Features](#-features) • [Installation](#-installation) • [Usage](#-usage) • [API](#-api-integration) • [Architecture](#-architecture)

</div>

---

## 🌟 Overview

DataLens is a sophisticated Flutter mobile application that transforms document images into structured, processable data using advanced AI technology. Simply capture or select a document image, and let DataLens extract text and form fields automatically.

## ✨ Features

### 🎯 Core Functionality

#### 📸 **Smart Image Capture**
- **Camera Integration**: Direct photo capture using device camera
- **Gallery Selection**: Choose existing images from device gallery
- **Multi-format Support**: JPEG, PNG, GIF, WebP image formats
- **Permission Management**: Seamless camera and storage permission handling

#### 🧠 **AI-Powered Document Processing**
- **Text Extraction**: Advanced OCR capabilities for text recognition
- **Form Field Detection**: Intelligent identification and extraction of form fields
- **Data Structuring**: Converts unstructured document data into organized key-value pairs
- **Real-time Processing**: Fast and efficient document analysis

#### 📊 **Data Visualization**
- **Extracted Text Display**: Clean presentation of recognized text content
- **Form Fields Mapping**: Structured display of detected form fields and values
- **Processing Metrics**: Display processing time and image information
- **Error Handling**: User-friendly error messages and debugging information

### 🎨 **User Interface & Experience**

#### 🎭 **Modern Design System**
- **Material 3 Design**: Latest Material Design principles
- **Custom Color Palette**: 
  - Primary Purple (`#6C63FF`)
  - Secondary Pink (`#FF6B9D`) 
  - Accent Blue (`#4ECDC4`)
  - Professional grays and success/warning colors
- **Responsive Layout**: Optimized for various screen sizes
- **Smooth Animations**: Elegant transitions and loading states

#### 🔧 **Custom Components**
- **App Button**: Reusable button component with consistent styling
- **Theme Configuration**: Centralized theme management
- **Route Management**: Organized navigation system

### 🔌 **Technical Features**

#### 🌐 **API Integration**
- **RESTful API Communication**: HTTP-based communication with backend services
- **Multipart File Upload**: Efficient image upload mechanism
- **Connection Testing**: Built-in API connectivity verification
- **Error Recovery**: Robust error handling and retry mechanisms

#### 📱 **Cross-Platform Support**
- **Android**: Full Android support with NDK 27.0.12077973
- **iOS**: Complete iOS implementation
- **Web**: Web platform ready
- **Windows, macOS, Linux**: Desktop platform support

#### 🛡️ **Security & Permissions**
- **Runtime Permissions**: Dynamic permission requests for camera and storage
- **Secure HTTP**: HTTPS communication with backend services
- **Data Privacy**: Local image processing with secure API transmission

### 🏗️ **Development Features**

#### 📋 **Code Quality**
- **Flutter Lints**: Comprehensive linting rules for code quality
- **Type Safety**: Strong typing throughout the application
- **Documentation**: Well-documented codebase with clear comments
- **Modular Architecture**: Feature-based project structure

#### 🧪 **Testing & Debugging**
- **Unit Tests**: Comprehensive test coverage
- **Widget Tests**: UI component testing
- **Debug Logging**: Detailed logging system for troubleshooting
- **Mock Services**: Development-time mock implementations

## 🚀 Installation

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio / VS Code
- Device/Emulator for testing

### Quick Start

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd datalens
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Platform-Specific Setup

#### Android
- Minimum SDK: 21
- Target SDK: 34
- NDK Version: 27.0.12077973

#### iOS
- iOS 11.0+
- Xcode 12+

## 📱 Usage

### Basic Workflow

1. **Launch the App**: Open DataLens on your device
2. **API Connection**: The app automatically tests API connectivity on startup
3. **Image Selection**: 
   - Tap "Select Image" to choose source (Camera/Gallery)
   - Grant necessary permissions when prompted
4. **Document Processing**:
   - Select or capture your document image
   - Tap "Process Image" to start AI analysis
   - Wait for processing completion
5. **View Results**:
   - Review extracted text in the text section
   - Check form fields in the structured data section
   - View processing metrics and debug information

### Supported Document Types
- Forms and applications
- Identity documents
- Invoices and receipts
- Contracts and agreements
- Any text-containing document

## 🔗 API Integration

### Backend Configuration

The app connects to a RESTful API for document processing:

```dart
static const String _baseUrl = 'https://datalens-541929b8c017.herokuapp.com';
```

### API Endpoints

#### POST /upload
Upload and process document images
- **Content-Type**: `multipart/form-data`
- **Field**: `file` (image file)
- **Response**: JSON with extracted data

#### GET /
Health check and connectivity test

### Response Format

```json
{
  "success": true,
  "extracted_data": {
    "text": "Extracted document text...",
    "form_fields": {
      "field_name": "field_value"
    }
  },
  "processing_time": 1.23,
  "image_info": {
    "width": 1920,
    "height": 1080,
    "format": "JPEG"
  }
}
```

## 🏗️ Architecture

### Project Structure

```
lib/
├── core/                    # Core application components
│   ├── app_config.dart     # App configuration and constants
│   ├── app_routes.dart     # Navigation and routing
│   ├── app_theme.dart      # UI theme and styling
│   ├── utils/
│   │   └── logger.dart     # Logging utilities
│   └── widgets/
│       └── app_button.dart # Custom UI components
├── features/               # Feature-based modules
│   └── image_processor/    # Document processing feature
│       ├── model/          # Data models
│       ├── service/        # Business logic and API calls
│       └── view/           # UI components
└── main.dart              # Application entry point
```

### Key Components

#### Models
- **ImageProcessingResponse**: API response data structure
- **Type-safe**: Strong typing for all data models

#### Services
- **ImageProcessingService**: API communication and image upload
- **Connection Testing**: Network connectivity verification
- **Error Handling**: Comprehensive error management

#### Views
- **ImageProcessorPage**: Main application interface
- **Responsive Design**: Adaptive UI for different screen sizes
- **State Management**: Efficient state handling with StatefulWidget

## 📦 Dependencies

### Core Dependencies
- **flutter**: Framework
- **cupertino_icons**: iOS-style icons
- **image_picker**: Image selection from camera/gallery
- **http**: HTTP client for API communication
- **permission_handler**: Runtime permission management
- **provider**: State management solution

### Development Dependencies
- **flutter_test**: Testing framework
- **flutter_lints**: Code quality and linting rules

## 🔧 Configuration

### Environment Setup
- Configure API endpoint in `ImageProcessingService`
- Adjust app configuration in `AppConfig`
- Customize theme in `AppTheme`

### Permissions

#### Android
```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture document images</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select document images</string>
```

## 🐛 Troubleshooting

### Common Issues

1. **API Connection Failed**
   - Check internet connectivity
   - Verify API endpoint URL
   - Check server status

2. **Permission Denied**
   - Grant camera and storage permissions in device settings
   - Restart the application

3. **Build Errors**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter and Dart SDK versions
   - Verify NDK version compatibility

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🚀 Future Enhancements

- [ ] Offline processing capabilities
- [ ] Multiple document format support (PDF, etc.)
- [ ] Batch processing functionality
- [ ] Advanced OCR configurations
- [ ] Data export options (CSV, JSON)
- [ ] User authentication and cloud sync
- [ ] Machine learning model improvements

---

<div align="center">

**Built with ❤️ using Flutter**

[Report Bug](mailto:support@datalens.app) • [Request Feature](mailto:feature@datalens.app)

</div>