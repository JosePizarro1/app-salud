import 'package:flutter/material.dart';

class BounceableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const BounceableScale({super.key, required this.child, required this.onTap});

  @override
  State<BounceableScale> createState() => _BounceableScaleState();
}

class _BounceableScaleState extends State<BounceableScale> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
