import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  ApiService._();

  static const String _rawUrl = String.fromEnvironment('API_BASE_URL');
  static String get baseUrl {
    if (_rawUrl.isNotEmpty) {
      return _rawUrl.trim();
    }
    // Default localhost for Web and Desktop
    return 'http://localhost:5272/api';
  }

  static final http.Client _client = http.Client();
  static String? _token;
  static late SharedPreferences prefs;

  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('jwt_token');
  }

  static Future<void> setToken(String token) async {
    _token = token;
    await prefs.setString('jwt_token', token);
  }

  static Future<void> clearToken() async {
    _token = null;
    await prefs.remove('jwt_token');
    await prefs.remove('user_profile');
  }
  
  static bool get isAuthenticated => _token != null;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static Future<dynamic> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(const Duration(seconds: 15));
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return null;
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      clearToken();
      throw StateError('Sesi telah berakhir. Silakan login ulang.');
    }

    String errorMsg = 'Permintaan gagal (Status ${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map && body.containsKey('error')) {
        errorMsg = body['error'];
      } else if (body is Map && body.containsKey('title')) {
        errorMsg = body['title']; // Handle ProblemDetails format
      }
    } catch (_) {}

    throw StateError(errorMsg);
  }
}
