import '../models/app_mode.dart';
import 'supabase_service.dart';

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
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxHistoryTurns = 8;

  /// The AI key is intentionally server-side only.
  /// Client readiness means Supabase is initialized and a user session exists.
  static bool get isConfigured => SupabaseService.isReady;

  static Future<String> generateReply({
    required List<GeminiChatTurn> history,
    AppMode mode = AppMode.patient,
  }) async {
    if (!SupabaseService.isReady) {
      throw const GeminiChatException(
        'Chatbot belum aktif. Hubungi admin untuk mengaktifkan AI.',
      );
    }

    try {
      final body = await SupabaseService.invokeFunction(
        'gemini-chat',
        body: <String, dynamic>{
          'mode': mode.name,
          'history': _toPayloadHistory(history),
        },
        timeout: _timeout,
      );

      final text = body['text'];
      if (text is String && text.trim().isNotEmpty) {
        return text.trim();
      }

      throw const GeminiChatException(
        'AI tidak mengirim jawaban. Coba tanya ulang dengan kalimat yang lebih jelas.',
      );
    } on GeminiChatException {
      rethrow;
    } catch (error) {
      throw GeminiChatException('Layanan AI gagal: $error');
    }
  }

  static List<Map<String, dynamic>> _toPayloadHistory(
    List<GeminiChatTurn> history,
  ) {
    final recentHistory = history.length > _maxHistoryTurns
        ? history.sublist(history.length - _maxHistoryTurns)
        : history;

    return <Map<String, dynamic>>[
      for (final turn in recentHistory)
        <String, dynamic>{
          'text': turn.text,
          'fromUser': turn.fromUser,
        },
    ];
  }
}
