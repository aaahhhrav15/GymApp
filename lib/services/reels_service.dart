import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:gym_app_2/models/reel_model.dart';
import 'package:gym_app_2/services/token_manager.dart';
import 'package:gym_app_2/services/aws_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReelsService {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';
  static const String _reelsEndpoint = 'reels/s3';
  static const String _reelsGetEndpoint = 'reels';

  final AwsService _awsService = AwsService();

  /// Fetch all reels from backend
  Future<List<ReelModel>> fetchReels() async {
    try {
      debugPrint(
          'ReelsService: Fetching reels from $baseUrl$_reelsGetEndpoint');

      final headers = await TokenManager.getAuthHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$_reelsGetEndpoint'),
        headers: headers,
      );

      debugPrint('ReelsService: Response status ${response.statusCode}');
      debugPrint('ReelsService: Response body ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Convert the data - backend now provides videoUrl and gym information
        List<ReelModel> reels = [];
        for (var reelData in data) {
          debugPrint('ReelsService: Processing reel data: $reelData');
          reels.add(ReelModel.fromJson(reelData));
        }

        debugPrint('ReelsService: Successfully parsed ${reels.length} reels');
        return reels;
      } else {
        throw Exception('Failed to load reels: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ReelsService: Error fetching reels: $e');
      throw Exception('Failed to fetch reels: $e');
    }
  }

  /// Upload reel video to S3 and save metadata to backend
  Future<Map<String, dynamic>> uploadReel({
    required XFile videoFile,
    required String caption,
  }) async {
    try {
      debugPrint('ReelsService: Starting reel upload process');
      debugPrint('ReelsService: Caption: $caption');
      debugPrint('ReelsService: Video file path: ${videoFile.path}');

      // STEP 1 & 2: Upload video to S3 using AWS Service with video content type
      debugPrint('ReelsService: Uploading video to S3...');
      final s3Result = await _awsService.uploadFileToS3(
        file: videoFile,
        folder: 'reels',
        contentType: 'video/mp4',
      );

      debugPrint('ReelsService: S3 upload result: $s3Result');

      if (!s3Result['success']) {
        debugPrint('ReelsService: S3 upload failed: ${s3Result['error']}');
        return {
          'success': false,
          'error': s3Result['error'],
        };
      }

      final String s3Key = s3Result['s3Key'];
      debugPrint('ReelsService: S3 upload successful, s3Key: $s3Key');

      // STEP 3: Save metadata to MongoDB
      debugPrint('ReelsService: Saving metadata to backend...');
      final Map<String, dynamic> requestBody = {
        "caption": caption.trim(),
        "s3Key": s3Key,
      };

      final result = await _callUploadAPI(requestBody);
      debugPrint('ReelsService: Backend save result: $result');

      return result;
    } catch (e) {
      debugPrint('ReelsService: Upload error: $e');
      return {
        'success': false,
        'error': 'Upload failed: $e',
      };
    }
  }

  /// API call method for uploading reel metadata
  Future<Map<String, dynamic>> _callUploadAPI(
      Map<String, dynamic> requestBody) async {
    try {
      debugPrint('ReelsService: Making API call to upload metadata');
      debugPrint('ReelsService: Request body: $requestBody');

      final headers = await TokenManager.getAuthHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$_reelsEndpoint'),
        headers: headers,
        body: jsonEncode(requestBody),
      );

      debugPrint('ReelsService: API Response Status: ${response.statusCode}');
      debugPrint('ReelsService: API Response Body: ${response.body}');

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
      debugPrint('ReelsService: Network error: $e');
      return {
        'success': false,
        'error': 'Network error: $e',
      };
    }
  }

  /// Delete reel from backend (which should handle both S3 and MongoDB deletion)
  static Future<bool> deleteReel(String reelId) async {
    try {
      debugPrint('ReelsService: Deleting reel with ID: $reelId');

      final headers = await TokenManager.getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$_reelsGetEndpoint/$reelId'),
        headers: headers,
      );

      debugPrint(
          'ReelsService: Delete response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        debugPrint('ReelsService: Reel deleted successfully');
        return true;
      } else {
        debugPrint(
            'ReelsService: Failed to delete reel: ${response.statusCode}');
        debugPrint('ReelsService: Response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('ReelsService: Error deleting reel: $e');
      return false;
    }
  }

  /// Convert S3 URL to direct playable URL for video_player
  static String getDirectVideoUrl(String s3Key) {
    if (s3Key.isEmpty) return '';
    return 'https://musclecrm-images.s3.ap-south-1.amazonaws.com/$s3Key';
  }
}
