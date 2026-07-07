import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Cerrar sesión',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D3142),
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas cerrar sesión?',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actionsPadding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: GoogleFonts.outfit(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8A71),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Cerrar sesión',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        );
      },
    );
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
            top: MediaQuery.of(context).size.height * 0.10,
          child: AnimatedScale(
            scale: _isConfigPressed ? 1.3 : 1.0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: GestureDetector(
              onTap: () {
                _triggerConfig();
                _showLogoutDialog(context);
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
          top: MediaQuery.of(context).size.height * 0.085,
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
            top: MediaQuery.of(context).size.height * 0.091,
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
                    'assets/images/Bhome.PNG',
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
