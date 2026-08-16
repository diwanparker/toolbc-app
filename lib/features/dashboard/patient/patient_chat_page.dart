import 'dart:async';

import 'package:flutter/material.dart';

import '../../../app/theme/app_theme.dart';
import '../../../core/models/app_mode.dart';
import '../../../core/services/gemini_chat_service.dart';
import '../../../core/widgets/ui_components.dart';

const List<_QuickPrompt> _quickPrompts = [
  _QuickPrompt(
    label: 'Lupa Minum Obat',
    prompt:
        'Kalau saya lupa minum obat TBC hari ini, apa yang harus saya lakukan?',
    icon: Icons.medication_outlined,
  ),
  _QuickPrompt(
    label: 'Efek Samping Obat',
    prompt:
        'Apa saja efek samping umum obat TBC (seperti urine berwarna merah) dan apakah itu normal?',
    icon: Icons.healing_outlined,
  ),
  _QuickPrompt(
    label: 'Makanan Bergizi',
    prompt:
        'Makanan dan nutrisi apa saja yang baik untuk mempercepat pemulihan pasien TBC?',
    icon: Icons.restaurant_outlined,
  ),
  _QuickPrompt(
    label: 'Batuk & Demam',
    prompt:
        'Saya masih merasa batuk dan demam. Kapan waktu yang tepat untuk segera berkonsultasi ke dokter?',
    icon: Icons.thermostat_outlined,
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
  final List<_PatientChatMessage> _messages = [
    const _PatientChatMessage(
      text:
          'Halo! Saya Asisten AI ToolBC. Saya siap membantu menjawab pertanyaan seputar pengobatan TBC, jadwal obat, efek samping, dan tips pemulihan kesehatan.',
      fromUser: false,
      includeInPrompt: false,
    ),
  ];

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
        'AI terlalu lama merespons. Coba periksa koneksi internet dan kirim ulang.',
      );
    } on GeminiChatException catch (error) {
      _addSystemMessage(error.message);
    } catch (_) {
      _addSystemMessage(
        'Maaf, asisten sedang belum bisa menjawab. Coba lagi dalam beberapa saat.',
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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _confirmClearChat() {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Percakapan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: const Text('Apakah Anda ingin mereset riwayat percakapan dengan Asisten AI?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kDanger,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _messages.clear();
                  _messages.add(
                    const _PatientChatMessage(
                      text:
                          'Halo! Saya Asisten AI ToolBC. Silakan tanyakan hal seputar obat TBC, jadwal, efek samping, atau tips pemulihan.',
                      fromUser: false,
                      includeInPrompt: false,
                    ),
                  );
                });
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
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
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate.fixed([
                    _AssistantInfoCard(),
                    const SizedBox(height: 16),
                    _QuickPromptsSection(onQuickPrompt: _sendMessage),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Percakapan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: kText,
                          ),
                        ),
                        if (_messages.length > 1)
                          InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: _confirmClearChat,
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline_rounded, size: 16, color: kMuted),
                                  SizedBox(width: 4),
                                  Text(
                                    'Reset Chat',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: kMuted),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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

class _AssistantInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kSoftBlue,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderBlue),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: kPrimary,
            child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'AI Asisten Medis TBC',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: kPrimary,
                      ),
                    ),
                    SizedBox(width: 6),
                    StatusPill(
                      text: 'Online',
                      bg: Color(0xFFDCFCE7),
                      fg: kSuccess,
                    ),
                  ],
                ),
                SizedBox(height: 2),
                Text(
                  'Konsultasi edukatif 24/7 seputar TBC & pengobatan.',
                  style: TextStyle(fontSize: 11, color: kMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickPromptsSection extends StatelessWidget {
  const _QuickPromptsSection({required this.onQuickPrompt});

  final ValueChanged<String> onQuickPrompt;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Topik Populer',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: kMuted,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final item in _quickPrompts)
              InkWell(
                onTap: () => onQuickPrompt(item.prompt),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder),
                    boxShadow: kCardShadow,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 16, color: kPrimary),
                      const SizedBox(width: 6),
                      Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: kText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
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
      child: ChatBubble(text: message.text, incoming: !message.fromUser),
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
        border: Border(top: BorderSide(color: kBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: kBorder),
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
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: 'Ketik pertanyaan seputar TBC...',
                  hintStyle: TextStyle(fontSize: 13, color: kMuted),
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                style: const TextStyle(fontSize: 13.5, color: kText),
              ),
            ),
          ),
          const SizedBox(width: 10),
          InkWell(
            onTap: sending ? null : onSend,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: sending
                    ? null
                    : const LinearGradient(
                        colors: [kPrimaryGradientStart, kPrimaryGradientEnd],
                      ),
                color: sending ? const Color(0xFF93C5FD) : null,
                borderRadius: BorderRadius.circular(16),
                boxShadow: sending ? const [] : kButtonShadow,
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
    text: 'Sedang mengetik jawaban...',
    fromUser: false,
    includeInPrompt: false,
  );

  final String text;
  final bool fromUser;
  final bool includeInPrompt;
}

class _QuickPrompt {
  const _QuickPrompt({
    required this.label,
    required this.prompt,
    required this.icon,
  });

  final String label;
  final String prompt;
  final IconData icon;
}
