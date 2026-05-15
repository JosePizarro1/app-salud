import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/emotion_entry.dart';

class EmotionPickerModal extends StatelessWidget {
  final EmotionType? currentEmotion;
  final void Function(EmotionType) onSelected;

  const EmotionPickerModal({
    super.key,
    this.currentEmotion,
    required this.onSelected,
  });

  static Future<EmotionType?> show(BuildContext context, {EmotionType? currentEmotion}) {
    return showModalBottomSheet<EmotionType>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => EmotionPickerModal(
        currentEmotion: currentEmotion,
        onSelected: (emotion) => Navigator.pop(context, emotion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Title ──
          Text(
            currentEmotion != null
                ? '¿Cambiar tu emoción de hoy?'
                : '¿Cómo te sientes hoy?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2D3142),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Selecciona la emoción que mejor te represente',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),

          const SizedBox(height: 24),

          // ── Emotion Grid ──
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: EmotionType.values.map((emotion) {
              final isSelected = currentEmotion == emotion;
              return _EmotionButton(
                emotion: emotion,
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onSelected(emotion);
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _EmotionButton extends StatefulWidget {
  final EmotionType emotion;
  final bool isSelected;
  final VoidCallback onTap;

  const _EmotionButton({
    required this.emotion,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_EmotionButton> createState() => _EmotionButtonState();
}

class _EmotionButtonState extends State<_EmotionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 1.2 : (widget.isSelected ? 1.1 : 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? widget.emotion.color.withValues(alpha: 0.2)
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
                border: widget.isSelected
                    ? Border.all(color: widget.emotion.color, width: 3)
                    : null,
                boxShadow: widget.isSelected
                    ? [
                        BoxShadow(
                          color: widget.emotion.color.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: Text(
                  widget.emotion.emoji,
                  style: const TextStyle(fontSize: 30),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.emotion.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: widget.isSelected ? FontWeight.w600 : FontWeight.w400,
                color: widget.isSelected
                    ? widget.emotion.color
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
