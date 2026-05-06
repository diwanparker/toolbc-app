import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/app_mode.dart';

class GeminiChatTurn {
  const GeminiChatTurn({required this.text, required this.fromUser});

  final String text;
  final bool fromUser;
}

class GeminiChatException implements Exception {
  const GeminiChatException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiChatService {
  static final http.Client _client = http.Client();

  static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String _model = String.fromEnvironment(
    'GEMINI_MODEL',
    defaultValue: 'gemini-2.5-flash',
  );
  static const Duration _timeout = Duration(seconds: 28);
  static const int _maxHistoryTurns = 8;

  static bool get isConfigured => _apiKey.isNotEmpty;

  static Future<String> generateReply({
    required List<GeminiChatTurn> history,
    AppMode mode = AppMode.patient,
  }) async {
    if (!isConfigured) {
      throw const GeminiChatException(
        'Chatbot belum aktif. Hubungi admin untuk mengaktifkan AI.',
      );
    }

    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$_model:generateContent',
      {'key': _apiKey},
    );

    final response = await _client
        .post(
          uri,
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({
            'systemInstruction': {
              'parts': [
                {'text': _systemPrompt(mode)},
              ],
            },
            'contents': _toGeminiContents(history),
            'generationConfig': {
              'temperature': 0.45,
              'topP': 0.9,
              'maxOutputTokens': 360,
            },
          }),
        )
        .timeout(_timeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GeminiChatException(_errorMessageFrom(response));
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractText(decoded);
    if (text == null || text.trim().isEmpty) {
      throw const GeminiChatException(
        'AI tidak mengirim jawaban. Coba tanya ulang dengan kalimat yang lebih jelas.',
      );
    }
    return text.trim();
  }

  static List<Map<String, dynamic>> _toGeminiContents(
    List<GeminiChatTurn> history,
  ) {
    final recentHistory = history.length > _maxHistoryTurns
        ? history.sublist(history.length - _maxHistoryTurns)
        : history;
    return [
      for (final turn in recentHistory)
        {
          'role': turn.fromUser ? 'user' : 'model',
          'parts': [
            {'text': turn.text},
          ],
        },
    ];
  }

  static String? _extractText(Map<String, dynamic> body) {
    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final first = candidates.first;
    if (first is! Map<String, dynamic>) return null;
    final content = first['content'];
    if (content is! Map<String, dynamic>) return null;
    final parts = content['parts'];
    if (parts is! List) return null;

    final chunks = <String>[];
    for (final part in parts) {
      if (part is Map<String, dynamic> && part['text'] is String) {
        chunks.add(part['text'] as String);
      }
    }
    return chunks.join('\n');
  }

  static String _errorMessageFrom(http.Response response) {
    try {
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final error = decoded['error'];
      if (error is Map<String, dynamic> && error['message'] is String) {
        return 'Layanan AI bermasalah (${response.statusCode}). Coba lagi sebentar lagi.';
      }
    } catch (_) {
      // Keep the user-facing fallback below if the API response is not JSON.
    }
    return 'Layanan AI bermasalah (${response.statusCode}). Periksa koneksi internet atau konfigurasi AI.';
  }

  static String _systemPrompt(AppMode mode) {
    final roleName = switch (mode) {
      AppMode.patient => 'pasien/user',
      AppMode.doctor => 'dokter',
      AppMode.admin => 'admin/resepsionis',
    };

    return '''
Kamu AI ToolBC/TBC Care untuk role $roleName. Jawab singkat, ramah, Bahasa Indonesia.

Konteks: ToolBC memantau pengobatan TBC, kepatuhan minum obat, checkup harian, reminder, riwayat progres, dan komunikasi perawatan. Role login dari email: @admin.com admin/resepsionis, @dokter.com dokter, @pasien.com pasien/user. Tidak ada register publik; admin membuat akun pasien/user dan dokter. Dokter bisa meminta admin membuat akun pasien. Pasien memakai Home, Checkup, Chatbot, History, Notifikasi, Profile. Dokter memantau pasien, adherence, missed dose, reminder/escalation. Admin fokus tambah akun pasien/user dan dokter.

Safety: beri edukasi umum, bukan diagnosis atau pengganti dokter. Jangan ubah dosis/obat. Untuk sesak berat, batuk darah, nyeri dada berat, pingsan, alergi berat, atau demam tinggi menetap, sarankan bantuan medis segera. Masalah akun diarahkan ke admin/resepsionis.
''';
  }
}
