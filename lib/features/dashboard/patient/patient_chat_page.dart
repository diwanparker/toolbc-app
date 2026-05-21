import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/app_mode.dart';
import '../../../core/services/gemini_chat_service.dart';
import '../../../core/widgets/ui_components.dart';

const List<_QuickPrompt> _quickPrompts = [
  _QuickPrompt(
    label: 'Jelaskan aplikasi ini',
    prompt: 'Jelaskan aplikasi ToolBC ini untuk pasien baru.',
  ),
  _QuickPrompt(
    label: 'Lupa minum obat',
    prompt:
        'Kalau saya lupa minum obat TBC, apa yang harus saya lakukan di aplikasi ini?',
  ),
  _QuickPrompt(
    label: 'Batuk dan demam',
    prompt:
        'Saya masih batuk dan demam. Fitur mana yang harus saya pakai dan kapan perlu hubungi dokter?',
  ),
  _QuickPrompt(
    label: 'Minta akun pasien',
    prompt: 'Bagaimana alur dokter meminta admin membuat akun pasien?',
  ),
];

class PatientChatPage extends StatefulWidget {
  const PatientChatPage({super.key});

  @override
  State<PatientChatPage> createState() => _PatientChatPageState();
}

class _PatientChatPageState extends State<PatientChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_PatientChatMessage> _messages = const [
    _PatientChatMessage(
      text:
          'Halo, aku AI ToolBC. Aku bisa bantu jelaskan fitur aplikasi, alur akun, reminder obat, checkup gejala, dan kapan perlu menghubungi dokter.',
      fromUser: false,
      includeInPrompt: false,
    ),
  ].toList();

  bool _sending = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? quickPrompt]) async {
    final text = (quickPrompt ?? _messageController.text).trim();
    if (text.isEmpty || _sending) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _messages.add(_PatientChatMessage(text: text, fromUser: true));
      _messageController.clear();
      _sending = true;
    });
    _scrollToBottom();

    try {
      final reply = await GeminiChatService.generateReply(
        mode: AppMode.patient,
        history: _messages
            .where((message) => message.includeInPrompt)
            .map(
              (message) => GeminiChatTurn(
                text: message.text,
                fromUser: message.fromUser,
              ),
            )
            .toList(growable: false),
      );
      if (!mounted) return;
      setState(
        () => _messages.add(_PatientChatMessage(text: reply, fromUser: false)),
      );
    } on TimeoutException {
      _addSystemMessage(
        'AI terlalu lama merespons. Coba kirim ulang, atau periksa koneksi internet kamu.',
      );
    } on GeminiChatException catch (error) {
      _addSystemMessage(error.message);
    } catch (_) {
      _addSystemMessage(
        'Maaf, chatbot sedang belum bisa menjawab. Coba lagi sebentar lagi.',
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
        _scrollToBottom();
      }
    }
  }

  void _addSystemMessage(String text) {
    if (!mounted) return;
    setState(
      () => _messages.add(_PatientChatMessage(text: text, fromUser: false)),
    );
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final messageCount = _messages.length + (_sending ? 1 : 0);

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _ChatIntro(onQuickPrompt: _sendMessage),
                    const SizedBox(height: 16),
                    const Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
                sliver: SliverList.builder(
                  itemCount: messageCount,
                  itemBuilder: (context, index) {
                    final message = index < _messages.length
                        ? _messages[index]
                        : _PatientChatMessage.typing;
                    return _MessageListItem(message: message);
                  },
                ),
              ),
            ],
          ),
        ),
        _ChatComposer(
          controller: _messageController,
          sending: _sending,
          onSend: () => _sendMessage(),
        ),
      ],
    );
  }
}

class _ChatIntro extends StatelessWidget {
  const _ChatIntro({required this.onQuickPrompt});

  final ValueChanged<String> onQuickPrompt;

  @override
  Widget build(BuildContext context) {
    final aiReady = GeminiChatService.isConfigured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chat Support',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kText,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Ask ToolBC AI about treatment reminders, checkup flow, and app roles.',
          style: TextStyle(fontSize: 12, color: kMuted),
        ),
        const SizedBox(height: 16),
        SectionCard(
          background: aiReady
              ? const Color(0xFFF0FDF4)
              : const Color(0xFFFFF7ED),
          borderColor: aiReady
              ? const Color(0xFFBBF7D0)
              : const Color(0xFFFDBA74),
          title: aiReady ? 'AI siap' : 'AI perlu setup',
          trailing: StatusPill(
            text: aiReady ? 'AI' : 'Setup',
            bg: aiReady ? const Color(0xFF22C55E) : const Color(0xFFF97316),
            fg: Colors.white,
          ),
          child: Text(
            aiReady
                ? 'Respons dibuat oleh AI dengan konteks aplikasi ToolBC.'
                : 'Konfigurasi AI belum aktif. Hubungi admin untuk mengaktifkan chatbot.',
            style: const TextStyle(fontSize: 9.8, color: kMuted),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Quick Prompts',
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final item in _quickPrompts)
                _QuickPromptButton(
                  label: item.label,
                  prompt: item.prompt,
                  onTap: onQuickPrompt,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MessageListItem extends StatelessWidget {
  const _MessageListItem({required this.message});

  final _PatientChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: RepaintBoundary(
        child: ChatBubble(text: message.text, incoming: !message.fromUser),
      ),
    );
  }
}

class _QuickPromptButton extends StatelessWidget {
  const _QuickPromptButton({
    required this.label,
    required this.prompt,
    required this.onTap,
  });

  final String label;
  final String prompt;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(prompt),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        constraints: const BoxConstraints(minHeight: 40),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: kSoftBlue,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBFDBFE)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: kPrimary,
          ),
        ),
      ),
    );
  }
}

class _ChatComposer extends StatelessWidget {
  const _ChatComposer({
    required this.controller,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      child: Row(
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 48),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 3,
                enabled: !sending,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tulis pertanyaan...',
                  hintStyle: TextStyle(fontSize: 12, color: kMuted),
                ),
                style: const TextStyle(fontSize: 13, color: kText),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: sending ? null : onSend,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: sending ? const Color(0xFF93C5FD) : kPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: sending
                  ? const Padding(
                      padding: EdgeInsets.all(13),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PatientChatMessage {
  const _PatientChatMessage({
    required this.text,
    required this.fromUser,
    this.includeInPrompt = true,
  });

  static const typing = _PatientChatMessage(
    text: 'Tolong tunggu sebentar...',
    fromUser: false,
    includeInPrompt: false,
  );

  final String text;
  final bool fromUser;
  final bool includeInPrompt;
}

class _QuickPrompt {
  const _QuickPrompt({required this.label, required this.prompt});

  final String label;
  final String prompt;
}
