import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class SupabaseService {
  SupabaseService._();

  static const String _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const String _supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static final http.Client _httpClient = http.Client();

  static bool get isConfigured =>
      _supabaseUrl.trim().isNotEmpty && _supabaseAnonKey.trim().isNotEmpty;

  static bool get isReady => isConfigured && Supabase.instance.isInitialized;

  static String get supabaseUrl {
    if (_supabaseUrl.trim().isEmpty) {
      throw StateError(
        'SUPABASE_URL belum dikonfigurasi. Gunakan --dart-define saat build.',
      );
    }
    return _supabaseUrl.trim();
  }

  static String get anonKey {
    if (_supabaseAnonKey.trim().isEmpty) {
      throw StateError(
        'SUPABASE_ANON_KEY belum dikonfigurasi. Gunakan --dart-define saat build.',
      );
    }
    return _supabaseAnonKey.trim();
  }

  static SupabaseClient get client {
    if (!isReady) {
      throw StateError('Supabase belum siap atau belum dikonfigurasi.');
    }
    return Supabase.instance.client;
  }

  static User? get currentUser => isReady ? client.auth.currentUser : null;

  static Session? get currentSession => isReady ? client.auth.currentSession : null;

  static SupabaseQueryBuilder from(String table) => client.from(table);

  static SupabaseStorageClient get storage => client.storage;

  static Uri edgeFunctionUri(String functionName) {
    final base = Uri.parse(supabaseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.hasPort ? base.port : null,
      path: '/functions/v1/$functionName',
    );
  }

  static Map<String, String> authenticatedFunctionHeaders() {
    final session = currentSession;
    final token = session?.accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Sesi login tidak valid. Silakan login ulang.');
    }

    return <String, String>{
      'Content-Type': 'application/json',
      'apikey': anonKey,
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> invokeFunction(
    String functionName, {
    required Map<String, dynamic> body,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final response = await _httpClient
        .post(
          edgeFunctionUri(functionName),
          headers: authenticatedFunctionHeaders(),
          body: jsonEncode(body),
        )
        .timeout(timeout);

    final decoded = _decodeJsonObject(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['error'] ?? decoded['message'] ?? response.body;
      throw StateError(message.toString());
    }
    return decoded;
  }

  static Map<String, dynamic> _decodeJsonObject(String responseBody) {
    if (responseBody.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{'data': decoded};
  }

  static Future<UserProfile?> fetchCurrentProfile() async {
    final user = currentUser;
    if (user == null) return null;
    return fetchProfileById(user.id);
  }

  static Future<UserProfile?> fetchProfileById(String id) async {
    final response = await client
        .from('profiles')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(response));
  }

  static Future<UserProfile?> signIn(String email, String password) async {
    if (!isConfigured) {
      throw StateError(
        'Supabase belum dikonfigurasi. Build app dengan --dart-define=SUPABASE_URL dan --dart-define=SUPABASE_ANON_KEY.',
      );
    }

    await client.auth.signInWithPassword(email: email, password: password);
    return fetchCurrentProfile();
  }

  static Future<AuthResponse> signInWithEmail(
    String email,
    String password,
  ) {
    if (!isConfigured) {
      throw StateError('Supabase belum dikonfigurasi.');
    }
    return client.auth.signInWithPassword(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) {
    if (!isConfigured) {
      throw StateError('Supabase belum dikonfigurasi.');
    }
    return client.auth.signUp(email: email, password: password, data: data);
  }

  static Future<AuthResponse> signUp(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) {
    return signUpWithEmail(email, password, data: data);
  }

  static Future<void> signOut() async {
    if (!isReady) return;
    await client.auth.signOut();
  }

  /// Creates an account through the server-side Edge Function.
  /// Only an authenticated admin should be allowed by the function.
  static Future<Map<String, dynamic>> createAccount({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? specialty,
    String? assignedDoctorId,
  }) {
    return invokeFunction(
      'create-account',
      body: <String, dynamic>{
        'email': email,
        'password': password,
        'full_name': fullName,
        'role': role,
        if (specialty != null && specialty.trim().isNotEmpty)
          'specialty': specialty.trim(),
        if (assignedDoctorId != null && assignedDoctorId.trim().isNotEmpty)
          'assigned_doctor_id': assignedDoctorId.trim(),
      },
    );
  }
}
