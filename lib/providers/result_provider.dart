import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/result_model.dart';
import '../services/token_manager.dart';
import '../services/aws_service.dart';
import '../services/moderation_service.dart';

class ResultProvider with ChangeNotifier {
  List<ResultModel> _results = [];
  List<XFile> _selectedImages = [];
  final AwsService _awsService = AwsService();
  String _description = '';
  double _weight = 70.0;
  bool _isLoading = false;
  bool _isUploading = false;

  // Backend configuration
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';
  static const String _resultsEndpoint = 'results/s3';

  // Getters
  List<ResultModel> get results => _results;
  List<XFile> get selectedImages => _selectedImages;
  String get description => _description;
  double get weight => _weight;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get canUpload =>
      _selectedImages.isNotEmpty && _description.trim().isNotEmpty;

  // Initialize the provider
  Future<void> initialize() async {
    await fetchResults();
  }

  // Update form fields
  void updateDescription(String value) {
    _description = value;
    notifyListeners();
  }

  void updateWeight(double value) {
    _weight = value;
    notifyListeners();
  }

  // Pick image from camera
  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        _selectedImages.add(image);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
    }
  }

  // Pick image from gallery
  Future<void> pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        _selectedImages.addAll(images);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking images from gallery: $e');
    }
  }

  // Remove image from selection
  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages.removeAt(index);
      notifyListeners();
    }
  }

  // Fetch results from backend
  Future<void> fetchResults() async {
    _isLoading = true;
    notifyListeners();

    try {
      final headers = await TokenManager.getAuthHeaders();
      final response = await http.get(
        Uri.parse('${baseUrl}results'), // Use base results endpoint for GET
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _results.clear();

        // Convert backend response to our format
        if (data['items'] != null) {
          for (var item in data['items']) {
            // Add S3 URL to the item data
            final String s3Key = item['s3Key']?.toString() ?? '';
            final String imageUrl = s3Key.isNotEmpty
                ? 'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$s3Key'
                : '';

            final String? itemId = item['_id']?.toString();
            final String? userId = item['userId']?.toString();

            // Check if content should be hidden
            if (itemId != null) {
              final shouldHide = await ModerationService.shouldHideContent(
                contentType: 'result',
                contentId: itemId,
                userId: userId,
              );
              
              if (!shouldHide) {
                final Map<String, dynamic> itemWithUrl = {
                  ...Map<String, dynamic>.from(item),
                  'imageUrl': imageUrl,
                };

                _results.add(ResultModel.fromJson(itemWithUrl));
              }
            }
          }
        }
      } else {
        debugPrint('Failed to fetch results: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching results: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Upload result to backend
  Future<Map<String, dynamic>> uploadResult() async {
    if (!canUpload) {
      return {
        'success': false,
        'error': 'Cannot upload: Missing images or description',
      };
    }

    _isUploading = true;
    notifyListeners();

    try {
      // Process each image and upload to S3 then save to MongoDB
      List<Map<String, dynamic>> uploadResults = [];

      for (int i = 0; i < _selectedImages.length; i++) {
        try {
          // STEP 1 & 2: Upload image to S3 using AWS Service
          final s3Result = await _awsService.uploadFileToS3(
            file: _selectedImages[i],
            folder: 'results',
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
            "s3Key": s3Key,
            "weight": _weight,
          };

          final result = await _callUploadAPI(requestBody);
          uploadResults.add(result);

          // Store successful uploads locally for UI
          if (result['success']) {
            final responseData = result['data'];
            // Create ResultModel with S3 URL
            final resultModel = ResultModel.fromJson({
              ...responseData,
              'imageUrl':
                  'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$s3Key',
            });
            _results.insert(0, resultModel);
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
          'message': 'All results uploaded successfully',
          'results': uploadResults,
        };
      } else {
        // Some uploads failed
        List<String> errors = uploadResults
            .where((result) => !result['success'])
            .map((result) => result['error'].toString())
            .toList();

        return {
          'success': false,
          'error': 'Some uploads failed: ${errors.join(', ')}',
          'results': uploadResults,
        };
      }
    } catch (e) {
      debugPrint('Error uploading results: $e');
      return {
        'success': false,
        'error': 'Upload failed: $e',
      };
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // API call method
  Future<Map<String, dynamic>> _callUploadAPI(
      Map<String, dynamic> requestBody) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$_resultsEndpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('API Response Status: ${response.statusCode}');
      debugPrint('API Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        return {
          'success': false,
          'error': 'API Error: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      debugPrint('Network error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  // Delete result from backend
  Future<bool> deleteResult(String resultId) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      final response = await http.delete(
        Uri.parse(
            '${baseUrl}results/$resultId'), // Use base results endpoint for delete
        headers: headers,
      );

      if (response.statusCode == 200) {
        _results.removeWhere((result) => result.id == resultId);
        notifyListeners();
        return true;
      } else {
        debugPrint('Failed to delete result: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Error deleting result: $e');
      return false;
    }
  }

  // Clear selection and reset form
  void clearSelection() {
    _selectedImages.clear();
    _description = '';
    _weight = 70.0;
    notifyListeners();
  }
}
