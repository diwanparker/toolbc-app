import '../models/app_mode.dart';
import 'api_service.dart';
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
  static const int _maxHistoryTurns = 8;

  static bool get isConfigured => ApiService.isAuthenticated;

  static Future<String> generateReply({
    required List<GeminiChatTurn> history,
    AppMode mode = AppMode.patient,
  }) async {
    if (!ApiService.isAuthenticated) {
      throw const GeminiChatException(
        'Sesi telah habis. Silakan login ulang.',
      );
    }

    try {
      final roleString = mode.name.toLowerCase() == 'doctor' ? 'Doctor'
                       : mode.name.toLowerCase() == 'admin' ? 'Admin'
                       : 'Patient';

      final response = await ApiService.post(
        '/chat/reply',
        body: <String, dynamic>{
          'mode': roleString,
          'history': _toPayloadHistory(history),
        },
      );

      if (response != null && response['reply'] != null) {
        final text = response['reply'];
        if (text is String && text.trim().isNotEmpty) {
          return text.trim();
        }
      }

      throw const GeminiChatException(
        'AI tidak mengirim jawaban. Coba tanya ulang dengan kalimat yang lebih jelas.',
      );
    } catch (error) {
      if (error is StateError) {
        throw GeminiChatException(error.message);
      }
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
