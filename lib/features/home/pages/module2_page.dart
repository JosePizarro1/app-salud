import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/module_header.dart';

class Module2Page extends StatelessWidget {
  const Module2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo2.PNG',
            fit: BoxFit.cover,
          ),

          // ── GIF Character (Mismas dimensiones del Módulo 3) ──
          Positioned(
            left: MediaQuery.of(context).size.width * 0.203,
            top: MediaQuery.of(context).size.height * 0.32,
            child: FadeIn(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.673,
                height: MediaQuery.of(context).size.height * 0.673,
                child: Image.asset(
                  'assets/images/Video.gif',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),


        ],
      ),
    );
  }
}
