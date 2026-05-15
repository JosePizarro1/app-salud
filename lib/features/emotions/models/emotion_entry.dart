import 'package:flutter/material.dart';

enum EmotionType {
  happy,
  relaxed,
  sad,
  anxious,
  stressed,
  overwhelmed,
}

extension EmotionTypeExtension on EmotionType {
  String get emoji {
    switch (this) {
      case EmotionType.happy:
        return '😊';
      case EmotionType.relaxed:
        return '😌';
      case EmotionType.sad:
        return '😢';
      case EmotionType.anxious:
        return '😰';
      case EmotionType.stressed:
        return '😤';
      case EmotionType.overwhelmed:
        return '🤯';
    }
  }

  String get label {
    switch (this) {
      case EmotionType.happy:
        return 'Feliz';
      case EmotionType.relaxed:
        return 'Relajado';
      case EmotionType.sad:
        return 'Triste';
      case EmotionType.anxious:
        return 'Ansioso';
      case EmotionType.stressed:
        return 'Estresado';
      case EmotionType.overwhelmed:
        return 'Desbordado';
    }
  }

  Color get color {
    switch (this) {
      case EmotionType.happy:
        return const Color(0xFF4CAF50);
      case EmotionType.relaxed:
        return const Color(0xFF42A5F5);
      case EmotionType.sad:
        return const Color(0xFF7986CB);
      case EmotionType.anxious:
        return const Color(0xFFFFA726);
      case EmotionType.stressed:
        return const Color(0xFFEF5350);
      case EmotionType.overwhelmed:
        return const Color(0xFFAB47BC);
    }
  }
}

class EmotionEntry {
  final String date; // yyyy-MM-dd
  final EmotionType emotion;

  EmotionEntry({required this.date, required this.emotion});

  Map<String, dynamic> toJson() => {
        'date': date,
        'emotion': emotion.name,
      };

  factory EmotionEntry.fromJson(Map<String, dynamic> json) {
    return EmotionEntry(
      date: json['date'] as String,
      emotion: EmotionType.values.firstWhere(
        (e) => e.name == json['emotion'],
        orElse: () => EmotionType.happy,
      ),
    );
  }
}
