// lib/services/google_auth_service.dart
import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Sign in with Google
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Sign out first to ensure account picker shows
      await _googleSignIn.signOut();

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User canceled the sign-in
        return {
          'success': false,
          'error': 'Sign in cancelled',
          'cancelled': true,
        };
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get user information
      final userData = {
        'id': googleUser.id,
        'email': googleUser.email,
        'name': googleUser.displayName ?? '',
        'photoUrl': googleUser.photoUrl ?? '',
        'accessToken': googleAuth.accessToken,
        'idToken': googleAuth.idToken,
      };

      print('Google Sign-In successful for: ${googleUser.email}');

      return {'success': true, 'userData': userData};
    } catch (error) {
      print('Google Sign-In error: $error');
      return {'success': false, 'error': error.toString()};
    }
  }

  // Check if user exists in database and handle accordingly
  static Future<Map<String, dynamic>> handleGoogleSignIn() async {
    try {
      // First, get Google user data
      final googleResult = await signInWithGoogle();

      if (!googleResult['success']) {
        return googleResult; // Return the error from Google sign-in
      }

      final googleUserData = googleResult['userData'];
      final email = googleUserData['email'];

      // Try to login with this email (check if user exists)
      final loginResult = await _tryGoogleLogin(googleUserData);

      if (loginResult['success']) {
        // User exists, login successful
        return {
          'success': true,
          'action': 'login',
          'message': 'Welcome back!',
          'userData': loginResult['data']['user'],
        };
      } else {
        // User doesn't exist, need to register
        return {
          'success': true,
          'action': 'register',
          'message': 'Complete your profile',
          'googleUserData': googleUserData,
        };
      }
    } catch (error) {
      return {'success': false, 'error': error.toString()};
    }
  }

  // Try to login user with Google data
  static Future<Map<String, dynamic>> _tryGoogleLogin(
    Map<String, dynamic> googleUserData,
  ) async {
    try {
      final result = await ApiService.googleAuth(
        email: googleUserData['email'],
        name: googleUserData['name'],
        id: googleUserData['id'],
        photoUrl: googleUserData['photoUrl'],
      );

      return result;
    } catch (e) {
      return {'success': false, 'error': 'User not found'};
    }
  }

  // Register Google user with additional details
  static Future<Map<String, dynamic>> registerGoogleUser({
    required Map<String, dynamic> googleUserData,
    required String dateOfBirth,
    required String gender,
    required String weight,
    required String height,
    required String phone,
    required String countryCode,
    String? gymCode,
  }) async {
    try {
      final registerResult = await ApiService.googleRegister(
        googleUserData: googleUserData,
        dateOfBirth: dateOfBirth,
        gender: gender,
        weight: weight,
        height: height,
        phone: phone,
        countryCode: countryCode,
        gymCode: gymCode,
      );

      if (registerResult['success']) {
        // Save Google-specific data
        await _saveGoogleUserData(googleUserData);
      }

      return registerResult;
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Save Google-specific user data
  static Future<void> _saveGoogleUserData(
    Map<String, dynamic> googleUserData,
  ) async {
    // You can save additional Google data like profile picture URL
    // This could be saved to your database or local storage
    print('Saving Google user data: ${googleUserData['photoUrl']}');
  }

  // Sign out from Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (e) {
      print('Google sign out error: $e');
    }
  }

  // Check if currently signed in to Google
  static Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }

  // Get current Google user
  static Future<GoogleSignInAccount?> getCurrentUser() async {
    return _googleSignIn.currentUser;
  }
}
