import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../models/user_profile.dart';

/// Lightweight Supabase helper service.
/// - Call `SupabaseService.initializeFromEnv()` in `main()` before `runApp()`.
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

  static final Map<String, _ProfileCacheEntry> _profileByIdCache = {};

  static String? _envValue(String key) {
    final dartDefineValue = switch (key) {
      'SUPABASE_URL' => _dartDefineSupabaseUrl,
      'SUPABASE_ANON_KEY' => _dartDefineSupabaseAnonKey,
      _ => '',
    };
    if (dartDefineValue.isNotEmpty) return dartDefineValue;

    try {
      final value = dotenv.env[key];
      return value != null && value.isNotEmpty ? value : null;
    } catch (_) {
      return null;
    }
  }

  static bool get isConfigured {
    final url = _envValue('SUPABASE_URL');
    final anonKey = _envValue('SUPABASE_ANON_KEY');
    return url != null && anonKey != null;
  }

  static bool get isReady => _initialized;

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

  /// Initialize Supabase using `.env` values loaded by `flutter_dotenv`.
  static Future<void> initializeFromEnv() async {
    if (_initialized) return;
    final url = _envValue('SUPABASE_URL');
    final anonKey = _envValue('SUPABASE_ANON_KEY');

    if (url == null || anonKey == null) {
      throw StateError(
        'SUPABASE_URL and SUPABASE_ANON_KEY must be set in .env',
      );
    }

    await Supabase.initialize(url: url, anonKey: anonKey);
    _initialized = true;
  }

  static SupabaseClient get client {
    if (!_initialized) throw StateError('Supabase not initialized.');
    return Supabase.instance.client;
  }

  static User? get currentUser => isReady ? client.auth.currentUser : null;

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

  static Future<AuthResponse> signInWithEmail(
    String email,
    String password,
  ) async {
    return signIn(email: email, password: password);
  }

  static Future<AuthResponse> signUpWithEmail(
    String email,
    String password,
  ) async {
    return signUp(email: email, password: password);
  }

  static Future<void> signOut() async {
    _clearProfileCache();
    await client.auth.signOut();
  }

  // Database helpers - return dynamic builder to avoid tight typing issues
  static dynamic from(String table) => client.from(table);

  // Storage helpers
  static SupabaseStorageClient storage() => client.storage;
}

class _ProfileCacheEntry {
  const _ProfileCacheEntry(this.profile, this.fetchedAt);

  final UserProfile profile;
  final DateTime fetchedAt;
}
