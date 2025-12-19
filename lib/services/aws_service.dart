import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/token_manager.dart';

class AwsService {
  
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://65.0.5.24/';

  // STEP 1: Get presigned URL from backend
  Future<Map<String, dynamic>> getPresignedUrl({
    required String folder,
    required String fileName,
    required String fileType,
  }) async {
    try {
      final headers = await TokenManager.getAuthHeaders();
      final url = '${baseUrl}s3/presigned-url';

      print('=== DEBUG: Requesting presigned URL ===');
      print('URL: $url');
      print('Headers: $headers');
      print('Body: ${json.encode({
            'folder': folder,
            'fileName': fileName,
            'fileType': fileType,
          })}');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode({
          'folder': folder,
          'fileName': fileName,
          'fileType': fileType,
        }),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      print('Response Headers: ${response.headers}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'url': data['url'],
          'key': data['key'],
        };
      } else {
        return {
          'success': false,
          'error':
              'Failed to get presigned URL: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Exception in getPresignedUrl: $e');
      return {
        'success': false,
        'error': 'Error getting presigned URL: $e',
      };
    }
  }

  // STEP 2: Upload file to S3 using presigned URL
  Future<bool> uploadToS3({
    required String presignedUrl,
    required Uint8List fileBytes,
    required String contentType,
  }) async {
    try {
      print('=== DEBUG: Uploading to S3 ===');
      print('Presigned URL: $presignedUrl');
      print('Content-Type: $contentType');
      print('File size: ${fileBytes.length} bytes');

      // Add timeout to prevent hanging
      print('Starting S3 PUT request...');
      print('Request URL parsed successfully: ${Uri.parse(presignedUrl)}');

      final stopwatch = Stopwatch()..start();

      final response = await http
          .put(
        Uri.parse(presignedUrl),
        headers: {
          'Content-Type': contentType,
        },
        body: fileBytes,
      )
          .timeout(const Duration(minutes: 3), onTimeout: () {
        stopwatch.stop();
        print(
            'S3 Upload timed out after ${stopwatch.elapsed.inSeconds} seconds');
        throw TimeoutException(
            'S3 upload timed out', const Duration(minutes: 3));
      });

      stopwatch.stop();
      print(
          'S3 PUT request completed in ${stopwatch.elapsed.inSeconds} seconds!');
      print('S3 Upload Response Status: ${response.statusCode}');
      print('S3 Upload Response Headers: ${response.headers}');
      print('S3 Upload Response Body: ${response.body}');

      // S3 PUT operations return 200 for success
      bool success = response.statusCode == 200;
      print('S3 Upload Success: $success');

      if (!success) {
        print('S3 Upload failed with status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }

      return success;
    } on TimeoutException catch (e) {
      print('S3 Upload timeout exception: $e');
      return false;
    } catch (e) {
      print('Error uploading to S3: $e');
      print('Exception type: ${e.runtimeType}');
      return false;
    }
  }

  // COMBINED METHOD: Get presigned URL and upload file to S3
  Future<Map<String, dynamic>> uploadFileToS3({
    required XFile file,
    required String folder,
    required String contentType,
  }) async {
    try {
      print('=== DEBUG: Starting S3 upload process ===');
      print('Folder: $folder');
      print('File path: ${file.path}');
      print('Content-Type: $contentType');

      // Read file bytes
      final Uint8List fileBytes = await file.readAsBytes();
      print('File bytes read: ${fileBytes.length} bytes');

      // Get file name
      final String fileName = file.name;
      print('File name: $fileName');

      // STEP 1: Get presigned URL
      print('=== DEBUG: Getting presigned URL ===');
      final presignedResult = await getPresignedUrl(
        folder: folder,
        fileName: fileName,
        fileType: contentType,
      );

      if (!presignedResult['success']) {
        print('Failed to get presigned URL: ${presignedResult['error']}');
        return presignedResult;
      }

      final String presignedUrl = presignedResult['url'];
      final String s3Key = presignedResult['key'];
      print('Presigned URL obtained: $presignedUrl');
      print('S3 Key: $s3Key');

      // STEP 2: Upload to S3
      print('=== DEBUG: Starting S3 upload step ===');
      final bool uploadSuccess = await uploadToS3(
        presignedUrl: presignedUrl,
        fileBytes: fileBytes,
        contentType: contentType,
      );

      print('=== DEBUG: S3 upload completed ===');
      print('Upload success: $uploadSuccess');

      if (uploadSuccess) {
        print('=== DEBUG: S3 upload successful! ===');
        return {
          'success': true,
          's3Key': s3Key,
          'message': 'File uploaded successfully to S3',
        };
      } else {
        print('=== DEBUG: S3 upload failed! ===');
        return {
          'success': false,
          'error': 'Failed to upload file to S3',
        };
      }
    } catch (e) {
      print('Upload process failed with exception: $e');
      return {
        'success': false,
        'error': 'Upload process failed: $e',
      };
    }
  }

  // Legacy method for backward compatibility (deprecated)
  @deprecated
  Future<Map<String, dynamic>> uploadImageToS3({
    required XFile imageFile,
    required String folder,
  }) async {
    return uploadFileToS3(
      file: imageFile,
      folder: folder,
      contentType: 'image/jpeg',
    );
  }

  // DELETE method for S3 files
  Future<bool> deleteFromS3({required String s3Key}) async {
    try {
      final headers = await TokenManager.getAuthHeaders();

      final response = await http.delete(
        Uri.parse('${baseUrl}s3/delete'),
        headers: headers,
        body: json.encode({
          'key': s3Key,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting from S3: $e');
      return false;
    }
  }
}
