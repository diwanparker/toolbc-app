import 'dart:convert';
import 'api_service.dart';
import '../models/user_profile.dart';

class AuthService {
  AuthService._();

  static UserProfile? _currentUserProfile;
  
  static UserProfile? get currentUser => _currentUserProfile;

  static bool get isConfigured => true; // Always true for API

  static Future<void> loadSavedProfile() async {
    final saved = ApiService.prefs.getString('user_profile');
    if (saved != null) {
      try {
        _currentUserProfile = UserProfile.fromJson(jsonDecode(saved));
      } catch (_) {}
    }
  }

  static Future<UserProfile?> signIn(String email, String password) async {
    try {
      final response = await ApiService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });
      
      if (response != null && response['accessToken'] != null) {
        await ApiService.setToken(response['accessToken']);
        final user = UserProfile.fromJson(response['user']);
        _currentUserProfile = user;
        await ApiService.prefs.setString('user_profile', jsonEncode(response['user']));
        return user;
      }
      
      throw StateError('Format response login tidak valid.');
    } catch (e) {
      // Allow specific error messages to pass through, or fallback
      if (e is StateError) rethrow;
      throw StateError('Login gagal: Email atau password salah.');
    }
  }

  static Future<void> signOut() async {
    await ApiService.clearToken();
    _currentUserProfile = null;
  }
}
