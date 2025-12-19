import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gym_app_2/services/token_manager.dart';
import 'package:gym_app_2/services/aws_service.dart';
import 'package:gym_app_2/services/moderation_service.dart';

class AccountabilityProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _selectedImages = [];
  final AwsService _awsService = AwsService();
  String _description = '';
  bool _isLoading = false;

  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';
  static const String _accountabilityEndpoint = 'accountability/s3';
  static const String _accountabilityGetEndpoint = 'accountability';

  // Getters
  List<XFile> get selectedImages => _selectedImages;
  String get description => _description;
  bool get isLoading => _isLoading;
  bool get canUpload =>
      _selectedImages.isNotEmpty && _description.trim().isNotEmpty;

  // Store uploaded images data
  final List<Map<String, dynamic>> _uploadedImages = [];
  List<Map<String, dynamic>> get uploadedImages => _uploadedImages;
  bool _isLoadingUploaded = false;
  bool get isLoadingUploaded => _isLoadingUploaded;

  // Fetch uploaded images from backend
  Future<void> fetchUploadedImages() async {
    _isLoadingUploaded = true;
    notifyListeners();

    try {
      final headers = await TokenManager.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$_accountabilityGetEndpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _uploadedImages.clear();

        // Convert backend response to our format with null safety
        if (data != null && data['items'] != null) {
          for (var item in data['items']) {
            // Add null safety checks for all fields using helper method
            final String? id = _safeStringExtract(item?['_id']);
            final String? s3Key = _safeStringExtract(item?['s3Key']);
            final String? description =
                _safeStringExtract(item?['description']);
            final String? createdAt = _safeStringExtract(item?['createdAt']);
            final String? userId = _safeStringExtract(item?['userId']);

            // Only add if required fields are not null
            if (id != null &&
                s3Key != null &&
                description != null &&
                createdAt != null) {
              
              // Check if content should be hidden
              final shouldHide = await ModerationService.shouldHideContent(
                contentType: 'accountability',
                contentId: id,
                userId: userId,
              );
              
              if (!shouldHide) {
                // Convert S3 key to full URL
                final String imageUrl =
                    'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$s3Key';

                _uploadedImages.add({
                  'id': id,
                  'imageUrl': imageUrl, // This is now S3 URL
                  's3Key': s3Key, // Store S3 key for deletion
                  'description': description,
                  'uploadDate': createdAt,
                  'userId': userId,
                });
              }
            } else {
              debugPrint(
                  'Skipping item with null fields: id=$id, s3Key=${s3Key != null ? 'present' : 'null'}, description=$description, createdAt=$createdAt');
            }
          }
        }

        // Final sanitization to ensure no invalid data made it through
        _sanitizeUploadedImages();
      } else {
        debugPrint(
            'Failed to fetch accountability posts: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching accountability posts: $e');
      debugPrint('Stack trace: $stackTrace');
    } finally {
      _isLoadingUploaded = false;
      notifyListeners();
    }
  }

  // Delete uploaded image (from both S3 and MongoDB)
  Future<bool> deleteUploadedImage(String imageId) async {
    try {
      // Validate input
      if (imageId.trim().isEmpty) {
        debugPrint('Cannot delete image: imageId is empty');
        return false;
      }

      // Find the image to get its S3 key
      final imageToDelete = _uploadedImages.firstWhere(
        (image) => image['id'] == imageId,
        orElse: () => {},
      );

      if (imageToDelete.isEmpty) {
        debugPrint('Cannot find image with id: $imageId');
        return false;
      }

      final String? s3Key = imageToDelete['s3Key'];
      if (s3Key == null) {
        debugPrint('S3 key not found for image: $imageId');
      }

      // Delete from backend (which should handle both S3 and MongoDB deletion)
      final headers = await TokenManager.getAuthHeaders();
      final response = await http.delete(
        Uri.parse(
            '${baseUrl}accountability/$imageId'), // Use base accountability endpoint for delete
        headers: headers,
      );

      if (response.statusCode == 200) {
        // Remove from local list
        _uploadedImages.removeWhere((image) => image['id'] == imageId);
        notifyListeners();
        return true;
      } else {
        debugPrint(
            'Failed to delete accountability post: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e, stackTrace) {
      debugPrint('Error deleting accountability post: $e');
      debugPrint('Stack trace: $stackTrace');
      return false;
    }
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImages.add(image);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Error picking image from camera: $e');
      debugPrint('Stack trace: $stackTrace');
      // You might want to show a user-friendly error message here
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        _selectedImages.addAll(images);
        notifyListeners();
      }
    } catch (e, stackTrace) {
      debugPrint('Error picking images from gallery: $e');
      debugPrint('Stack trace: $stackTrace');
      // You might want to show a user-friendly error message here
    }
  }

  // Remove image from selection
  void removeImage(int index) {
    try {
      if (index >= 0 && index < _selectedImages.length) {
        _selectedImages.removeAt(index);
        notifyListeners();
      } else {
        debugPrint(
            'Cannot remove image: index $index is out of bounds (length: ${_selectedImages.length})');
      }
    } catch (e, stackTrace) {
      debugPrint('Error removing image at index $index: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // Update description
  void updateDescription(String value) {
    try {
      _description = value; // Value is already non-null due to String type
      notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error updating description: $e');
      debugPrint('Stack trace: $stackTrace');
      _description = ''; // Fallback to empty string
      notifyListeners();
    }
  }

  // Upload images to S3 and save to MongoDB
  Future<Map<String, dynamic>> uploadImages() async {
    if (!canUpload) {
      return {
        'success': false,
        'error': 'Cannot upload: Missing images or description',
      };
    }

    _isLoading = true;
    notifyListeners();

    try {
      List<Map<String, dynamic>> uploadResults = [];

      for (int i = 0; i < _selectedImages.length; i++) {
        try {
          // STEP 1 & 2: Upload image to S3 using AWS Service
          final s3Result = await _awsService.uploadFileToS3(
            file: _selectedImages[i],
            folder: 'accountability',
            contentType: 'image/jpeg',
          );

          if (!s3Result['success']) {
            uploadResults.add({
              'success': false,
              'error': s3Result['error'],
            });
            continue;
          }

          final String s3Key = s3Result['s3Key'];

          // STEP 3: Save metadata to MongoDB
          final Map<String, dynamic> requestBody = {
            "description": _description.trim(),
            "s3Key": s3Key, // camelCase to match schema
          };

          final result = await _callUploadAPI(requestBody);
          uploadResults.add(result);

          // Store successful uploads locally for UI
          if (result['success']) {
            final responseData = result['data'];
            if (responseData != null) {
              final String? id = _safeStringExtract(responseData['_id']);
              final String? description =
                  _safeStringExtract(responseData['description']);
              final String? s3KeyResponse =
                  _safeStringExtract(responseData['s3Key']);
              final String? createdAt =
                  _safeStringExtract(responseData['createdAt']);

              // Only add if all required fields are present
              if (id != null &&
                  description != null &&
                  s3KeyResponse != null &&
                  createdAt != null) {
                // Convert S3 key to full URL
                final String imageUrl =
                    'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$s3KeyResponse';

                _uploadedImages.insert(0, {
                  "id": id,
                  "description": description,
                  "imageUrl": imageUrl,
                  "s3Key": s3KeyResponse,
                  "uploadDate": createdAt,
                });
              } else {
                debugPrint(
                    'Warning: Response data has null fields: id=$id, description=$description, s3Key=${s3KeyResponse != null ? 'present' : 'null'}, createdAt=$createdAt');
              }
            }
          }
        } catch (e) {
          uploadResults.add({
            'success': false,
            'error': 'Upload failed for image ${i + 1}: $e',
          });
        }
      }

      // Check if all uploads were successful
      bool allSuccessful = uploadResults.every((result) => result['success']);

      if (allSuccessful) {
        // Clear the form on successful upload
        clearSelection();

        return {
          'success': true,
          'message': 'All images uploaded successfully',
          'results': uploadResults,
        };
      } else {
        // Some uploads failed
        List<String> errors = uploadResults
            .where((result) => !result['success'])
            .map((result) => result['error']?.toString() ?? 'Unknown error')
            .toList();

        return {
          'success': false,
          'error': 'Some uploads failed: ${errors.join(', ')}',
          'results': uploadResults,
        };
      }
    } catch (e, stackTrace) {
      debugPrint('Error uploading images: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'Upload failed: $e',
      };
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _callUploadAPI(
      Map<String, dynamic> requestBody) async {
    try {
      // Validate request body
      final String? description =
          _safeStringExtract(requestBody['description']);
      final String? s3Key =
          _safeStringExtract(requestBody['s3Key']); // camelCase to match schema

      if (description == null) {
        return {
          'success': false,
          'error': 'Description is required',
        };
      }

      if (s3Key == null) {
        return {
          'success': false,
          'error': 'S3 key is required',
        };
      }

      final headers = await TokenManager.getAuthHeaders();

      print('=== DEBUG: Saving to MongoDB ===');
      print('URL: $baseUrl$_accountabilityEndpoint');
      print('Headers: $headers');
      print('Request Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        Uri.parse('$baseUrl$_accountabilityEndpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = jsonDecode(response.body);
          return {
            'success': true,
            'data': responseData,
          };
        } catch (e) {
          debugPrint('Error parsing response JSON: $e');
          return {
            'success': false,
            'error': 'Invalid response format from server',
          };
        }
      } else {
        debugPrint('API Error Details:');
        debugPrint('Status: ${response.statusCode}');
        debugPrint('Body: ${response.body}');
        debugPrint('Headers: ${response.headers}');

        // Try to parse error response for more details
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['details'] ?? errorData['error'] ?? 'Unknown error';
          return {
            'success': false,
            'error': 'API Error: ${response.statusCode} - $errorMessage',
          };
        } catch (e) {
          return {
            'success': false,
            'error': 'API Error: ${response.statusCode} - ${response.body}',
          };
        }
      }
    } catch (e, stackTrace) {
      debugPrint('Network error: $e');
      debugPrint('Stack trace: $stackTrace');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Clear selection and reset form
  void clearSelection() {
    _selectedImages.clear();
    _description = '';
    notifyListeners();
  }

  // Get uploaded images data (for testing purposes)
  List<Map<String, dynamic>> get uploadedData => _uploadedImages;

  // Initialize the provider (load existing data)
  Future<void> initialize() async {
    await fetchUploadedImages();
  }

  // Helper method to safely extract string from dynamic value
  String? _safeStringExtract(dynamic value) {
    if (value == null) return null;
    return value.toString().trim().isEmpty ? null : value.toString();
  }

  // Sanitize uploaded images data to remove any entries with null values
  void _sanitizeUploadedImages() {
    _uploadedImages.removeWhere((image) {
      final String? id = image['id']?.toString();
      final String? imageUrl = image['imageUrl']?.toString();
      final String? description = image['description']?.toString();
      final String? uploadDate = image['uploadDate']?.toString();

      // Remove entries with null or empty essential fields
      if (id == null || id.isEmpty || imageUrl == null || imageUrl.isEmpty) {
        debugPrint(
            'Removing invalid image entry: id=$id, imageUrl=${imageUrl == null ? 'null' : 'present'}');
        return true;
      }

      // Fix null description or uploadDate
      if (description == null || description.isEmpty) {
        image['description'] = 'No description';
      }
      if (uploadDate == null || uploadDate.isEmpty) {
        image['uploadDate'] = DateTime.now().toIso8601String();
      }

      return false;
    });
  }

  // Get sanitized uploaded images
  List<Map<String, dynamic>> get uploadedImagesSafe {
    _sanitizeUploadedImages();
    return _uploadedImages;
  }
}
