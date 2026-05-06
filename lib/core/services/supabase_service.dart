import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static bool _initialized = false;
  static bool _configured = false;

  static const String _url = String.fromEnvironment('SUPABASE_URL');
  static const String _anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static bool get isConfigured => _configured;

  static Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    if (_url.isEmpty || _anonKey.isEmpty) {
      _configured = false;
      return;
    }

    await Supabase.initialize(url: _url, anonKey: _anonKey);
    _configured = true;
  }

  static SupabaseClient get client {
    if (!_configured) {
      throw StateError('Supabase belum dikonfigurasi.');
    }
    return Supabase.instance.client;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) {
    return client.auth.signUp(email: email, password: password, data: data);
  }
}
