import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  late double x;
  late double y;
  late double size;
  late double speedY;
  late double opacity;
  late double wobbleSpeed;
  late double wobbleAmplitude;

  Particle({required Random random}) {
    reset(random, initialPlacement: true);
  }

  void reset(Random random, {bool initialPlacement = false}) {
    x = random.nextDouble();
    y = initialPlacement ? random.nextDouble() : 1.0 + random.nextDouble() * 0.2;
    size = 2.0 + random.nextDouble() * 5.0;
    speedY = 0.0005 + random.nextDouble() * 0.0015;
    opacity = 0.15 + random.nextDouble() * 0.35;
    wobbleSpeed = 0.5 + random.nextDouble() * 2.0;
    wobbleAmplitude = 0.01 + random.nextDouble() * 0.03;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animValue;
  final bool isPaused;
  static final Random _random = Random();

  final Paint _particlePaint = Paint();

  ParticlePainter({
    required this.particles,
    required this.animValue,
    required this.isPaused,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (!isPaused) {
        p.y -= p.speedY;
        p.x += sin(animValue * pi * 2 * p.wobbleSpeed) * p.wobbleAmplitude * 0.1;
      }

      if (p.y < -0.05) {
        p.reset(_random);
      }

      _particlePaint
        ..color = Colors.white.withOpacity(p.opacity * (isPaused ? 0.4 : 1.0))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.5);

      canvas.drawCircle(
        Offset(p.x * size.width, p.y * size.height),
        p.size,
        _particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) => true;
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  late final Paint _trackPaint;
  late final Paint _progressPaint;

  CircularProgressPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  }) {
    _trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    _progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    const startAngle = -pi / 2;
    const arcSweep = 2 * pi * 0.78;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      arcSweep,
      false,
      _trackPaint,
    );

    final progressSweep = arcSweep * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      progressSweep,
      false,
      _progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.progressColor != progressColor;
}

class ProgressDotPainter extends CustomPainter {
  final double progress;
  final Color dotColor;
  final double dotSize;

  late final Paint _glowPaint;
  late final Paint _dotPaint;

  ProgressDotPainter({
    required this.progress,
    required this.dotColor,
    required this.dotSize,
  }) {
    _glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    _dotPaint = Paint()..color = dotColor;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 8) / 2;

    const startAngle = -pi / 2;
    const arcSweep = 2 * pi * 0.78;

    final angle = startAngle + arcSweep * progress.clamp(0.0, 1.0);
    final dotCenter = Offset(
      center.dx + radius * cos(angle),
      center.dy + radius * sin(angle),
    );

    canvas.drawCircle(dotCenter, dotSize * 0.8, _glowPaint);
    canvas.drawCircle(dotCenter, dotSize / 2, _dotPaint);
  }

  @override
  bool shouldRepaint(covariant ProgressDotPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
