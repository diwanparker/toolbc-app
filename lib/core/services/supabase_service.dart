import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Lightweight Supabase helper service.
/// - Call `SupabaseService.initializeFromEnv()` in `main()` before `runApp()`.
class SupabaseService {
  SupabaseService._();

  static bool _initialized = false;

  static bool get isConfigured {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];
    return url != null && url.isNotEmpty && anonKey != null && anonKey.isNotEmpty;
  }

  /// Initialize Supabase using `.env` values loaded by `flutter_dotenv`.
  static Future<void> initializeFromEnv() async {
    if (_initialized) return;
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || anonKey == null) {
      throw StateError('SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env');
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) throw StateError('Supabase not initialized.');
    return Supabase.instance.client;
  }

  // Auth helpers
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

  static Future<AuthResponse> signInWithEmail(String email, String password) async {
    return signIn(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return signUp(email: email, password: password);
  }

  static Future<void> signOut() async => client.auth.signOut();

  // Database helpers - return dynamic builder to avoid tight typing issues
  static dynamic from(String table) => client.from(table);

  // Storage helpers
  static SupabaseStorageClient storage() => client.storage;
}
