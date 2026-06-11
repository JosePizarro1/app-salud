import 'package:flutter/material.dart';
import '../widgets/module_header.dart';

class Module6Page extends StatelessWidget {
  const Module6Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background
          Image.asset(
            'assets/images/fondo_modulo6.png',
            fit: BoxFit.cover,
          ),

          // Shared Header with Home Button
          const ModuleHeader(showHome: true),
        ],
      ),
    );
  }
}
