import 'package:flutter/material.dart';
import '../widgets/module_header.dart';

class Module4Page extends StatelessWidget {
  const Module4Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo modulo4 sueño titi.png',
            fit: BoxFit.cover,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),
        ],
      ),
    );
  }
}
