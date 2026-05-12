import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';

class ModuleHeader extends StatefulWidget {
  final bool showHome;
  const ModuleHeader({super.key, this.showHome = false});

  @override
  State<ModuleHeader> createState() => _ModuleHeaderState();
}

class _ModuleHeaderState extends State<ModuleHeader> {
  bool _isPulsing = false;
  bool _isConfigPressed = false;
  bool _isEmergencyPressed = false;
  bool _isHomePressed = false;
  late final StreamSubscription _pulseSubscription;

  @override
  void initState() {
    super.initState();
    _pulseSubscription = Stream.periodic(const Duration(milliseconds: 2500)).listen((_) {
      if (mounted) {
        setState(() => _isPulsing = !_isPulsing);
      }
    });
  }

  @override
  void dispose() {
    _pulseSubscription.cancel();
    super.dispose();
  }

  void _triggerConfig() async {
    setState(() => _isConfigPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isConfigPressed = false);
    }
  }

  void _triggerEmergency() async {
    setState(() => _isEmergencyPressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isEmergencyPressed = false);
    }
  }

  void _triggerHome() async {
    setState(() => _isHomePressed = true);
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isHomePressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Botón Configuración (Tuerca) ──
        if (!widget.showHome)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * 0.05,
          child: AnimatedScale(
            scale: _isConfigPressed ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                _triggerConfig();
                context.push('/settings');
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.12,
                height: MediaQuery.of(context).size.width * 0.12,
                child: Image.asset(
                  'assets/images/Bconfiguracion.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // ── Botón Emergencia ──
        Positioned(
          right: MediaQuery.of(context).size.width * 0.05,
          top: MediaQuery.of(context).size.height * 0.035,
          child: AnimatedScale(
            scale: _isEmergencyPressed ? 1.3 : (_isPulsing ? 1.1 : 1.0),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                _triggerEmergency();
                context.push('/emergency');
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.166,
                height: MediaQuery.of(context).size.width * 0.166,
                child: Image.asset(
                  'assets/images/Bemergencia.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ),

        // ── Botón Home (Solo si showHome es true) ──
        if (widget.showHome)
          Positioned(
            left: MediaQuery.of(context).size.width * 0.05,
            top: MediaQuery.of(context).size.height * 0.041,
            child: AnimatedScale(
              scale: _isHomePressed ? 1.3 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: GestureDetector(
                onTap: () {
                  _triggerHome();
                  context.go('/home');
                },
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.15,
                  height: MediaQuery.of(context).size.width * 0.15,
                  child: Image.asset(
                    'assets/images/Bhome.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
