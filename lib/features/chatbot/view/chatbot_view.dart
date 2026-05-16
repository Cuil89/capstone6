import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_ui_components.dart';
import '../controller/chatbot_controller.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({super.key});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final ChatbotController controller = Get.find<ChatbotController>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send([String? value]) {
    final text = (value ?? _inputController.text).trim();
    if (text.isEmpty) return;

    controller.sendMessage(text);
    _inputController.clear();
    Future.delayed(const Duration(milliseconds: 80), _scrollToBottom);
    Future.delayed(const Duration(milliseconds: 760), _scrollToBottom);
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Asisten SEHATI'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            tooltip: 'Hapus chat',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: controller.clearChat,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const _AssistantHero(),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  itemCount:
                      controller.messages.length +
                      (controller.isTyping.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= controller.messages.length) {
                      return const _TypingBubble();
                    }
                    return _MessageBubble(message: controller.messages[index]);
                  },
                ),
              ),
            ),
            Obx(() {
              final shouldShow =
                  controller.messages.length <= 1 && !controller.isTyping.value;
              if (!shouldShow) return const SizedBox.shrink();
              return _SuggestionChips(onSelected: _send);
            }),
            _InputBar(
              controller: _inputController,
              onSubmitted: _send,
              onSend: _send,
            ),
          ],
        ),
      ),
    );
  }
}

class _AssistantHero extends StatelessWidget {
  const _AssistantHero();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: LiquidCard(
        borderRadius: BorderRadius.circular(26),
        padding: const EdgeInsets.all(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1F1A), Color(0xFF0B6E4F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        child: Row(
          children: [
            const GradientIconBox(
              icon: Icons.auto_awesome_rounded,
              color: AppColors.primaryGlow,
              size: 52,
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asisten obat & gejala',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arahan umum, bukan pengganti konsultasi medis.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withValues(alpha: 0.74),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[const _BotAvatar(), const SizedBox(width: 8)],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: BoxDecoration(
                color: isUser ? AppColors.ink : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 7),
                  bottomRight: Radius.circular(isUser ? 7 : 20),
                ),
                border: isUser ? null : Border.all(color: AppColors.outline),
                boxShadow: isUser ? AppTheme.softShadow : null,
              ),
              child: Text(
                message.content,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: isUser ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _BotAvatar(),
          SizedBox(width: 8),
          StatusPill(
            label: 'Sedang menyiapkan jawaban',
            color: AppColors.primary,
            icon: Icons.more_horiz_rounded,
          ),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  const _BotAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Icon(
        Icons.health_and_safety_rounded,
        color: Colors.white,
        size: 19,
      ),
    );
  }
}

class _SuggestionChips extends StatelessWidget {
  final ValueChanged<String> onSelected;

  const _SuggestionChips({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final suggestions = [
      'Saya demam sejak kemarin',
      'Bolehkah minum dua obat flu?',
      'Batuk pilek perlu obat apa?',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: suggestions
            .map(
              (text) => ActionChip(
                label: Text(text),
                avatar: const Icon(Icons.add_rounded, size: 16),
                onPressed: () => onSelected(text),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.onSubmitted,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              minLines: 1,
              maxLines: 4,
              textInputAction: TextInputAction.send,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                hintText: 'Tulis keluhan atau pertanyaan obat',
                prefixIcon: Icon(Icons.chat_bubble_outline_rounded),
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 50,
            height: 50,
            child: FilledButton(
              onPressed: onSend,
              style: FilledButton.styleFrom(padding: EdgeInsets.zero),
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
