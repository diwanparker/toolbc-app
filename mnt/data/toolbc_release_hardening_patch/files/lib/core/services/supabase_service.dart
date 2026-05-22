import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/user_profile.dart';

class SupabaseService {
  SupabaseService._();

  static const String _dartDefineSupabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
  );
  static const String _dartDefineSupabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
  );

  static bool _initialized = false;
  static const Duration _profileCacheTtl = Duration(seconds: 60);
  static const Duration _profileByIdCacheTtl = Duration(minutes: 2);
  static UserProfile? _cachedProfile;
  static String? _cachedProfileUserId;
  static DateTime? _cachedProfileAt;
  static final Map<String, _ProfileCacheEntry> _profileByIdCache =
      <String, _ProfileCacheEntry>{};
  static final http.Client _httpClient = http.Client();

  static String? _envValue(String key) {
    final dartDefineValue = switch (key) {
      'SUPABASE_URL' => _dartDefineSupabaseUrl,
      'SUPABASE_ANON_KEY' => _dartDefineSupabaseAnonKey,
      _ => '',
    };
    return dartDefineValue.trim().isNotEmpty ? dartDefineValue.trim() : null;
  }

  static bool get isConfigured {
    final url = _envValue('SUPABASE_URL');
    final anonKey = _envValue('SUPABASE_ANON_KEY');
    return url != null && anonKey != null;
  }

  static bool get isReady => _initialized;

  static String get supabaseUrl {
    final value = _envValue('SUPABASE_URL');
    if (value == null) {
      throw StateError(
        'SUPABASE_URL belum dikonfigurasi. Gunakan --dart-define saat build.',
      );
    }
    return value;
  }

  static String get anonKey {
    final value = _envValue('SUPABASE_ANON_KEY');
    if (value == null) {
      throw StateError(
        'SUPABASE_ANON_KEY belum dikonfigurasi. Gunakan --dart-define saat build.',
      );
    }
    return value;
  }

  static bool _isFresh(DateTime? fetchedAt, Duration ttl) {
    if (fetchedAt == null) return false;
    return DateTime.now().difference(fetchedAt) <= ttl;
  }

  static void _clearProfileCache() {
    _cachedProfile = null;
    _cachedProfileUserId = null;
    _cachedProfileAt = null;
    _profileByIdCache.clear();
  }

  /// Initialize Supabase using compile-time dart defines.
  ///
  /// Example:
  /// flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...
  static Future<void> initializeFromEnv() async {
    if (_initialized) return;

    if (!isConfigured) {
      throw StateError(
        'SUPABASE_URL dan SUPABASE_ANON_KEY wajib dikirim dengan --dart-define.',
      );
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!isReady) throw StateError('Supabase belum diinisialisasi.');
    return Supabase.instance.client;
  }

  static User? get currentUser => isReady ? client.auth.currentUser : null;

  static Session? get currentSession => isReady ? client.auth.currentSession : null;

  static Future<UserProfile?> fetchCurrentProfile({
    bool forceRefresh = false,
  }) async {
    final user = currentUser;
    if (user == null) {
      _clearProfileCache();
      return null;
    }

    if (!forceRefresh &&
        _cachedProfile != null &&
        _cachedProfileUserId == user.id &&
        _isFresh(_cachedProfileAt, _profileCacheTtl)) {
      return _cachedProfile;
    }

    final response = await client
        .from('profiles')
        .select('id, full_name, email, role, specialty, assigned_doctor_id')
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      _clearProfileCache();
      return null;
    }

    final profile = UserProfile.fromJson(response);
    _cachedProfile = profile;
    _cachedProfileUserId = user.id;
    _cachedProfileAt = DateTime.now();
    _profileByIdCache[user.id] = _ProfileCacheEntry(profile, _cachedProfileAt!);
    return profile;
  }

  static Future<UserProfile?> fetchProfileById(
    String id, {
    bool forceRefresh = false,
  }) async {
    if (!isReady) return null;

    if (!forceRefresh) {
      final cached = _profileByIdCache[id];
      if (cached != null && _isFresh(cached.fetchedAt, _profileByIdCacheTtl)) {
        return cached.profile;
      }
    }

    final response = await client
        .from('profiles')
        .select('id, full_name, email, role, specialty, assigned_doctor_id')
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    final profile = UserProfile.fromJson(response);
    _profileByIdCache[id] = _ProfileCacheEntry(profile, DateTime.now());
    return profile;
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

  static Future<AuthResponse> signInWithEmail(
    String email,
    String password,
  ) {
    return signIn(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
  ) {
    return signUp(email: email, password: password);
  }

  static Future<void> signOut() async {
    _clearProfileCache();
    if (isReady) await client.auth.signOut();
  }

  static dynamic from(String table) => client.from(table);

  static SupabaseStorageClient storage() => client.storage;

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

  static Map<String, dynamic> _decodeJsonObject(String responseBody) {
    if (responseBody.trim().isEmpty) return <String, dynamic>{};
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) return decoded;
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
    return <String, dynamic>{'data': decoded};
  }
}

class _ProfileCacheEntry {
  const _ProfileCacheEntry(this.profile, this.fetchedAt);

  final UserProfile profile;
  final DateTime fetchedAt;
}
