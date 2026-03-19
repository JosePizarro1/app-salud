import 'package:flutter/material.dart';

class ModuleModel {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String route;
  final String lottieUrl;
  final double lottieSpeed; // Nuevo campo

  ModuleModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.route,
    required this.lottieUrl,
    this.lottieSpeed = 1.0, // Valor por defecto
  });
}

final List<ModuleModel> healthModules = [
  ModuleModel(
    title: 'Relajación y manejo emocional',
    description: 'Técnicas de respiración, meditación y gestión del estrés.',
    icon: Icons.self_improvement_rounded,
    color: const Color(0xFF9B51E0),
    route: '/relajacion',
    lottieUrl: "https://lottie.host/7d00631c-156a-48b2-8b48-30136ab82532/v5cKcgeEXM.lottie",
    lottieSpeed: 1.0,
  ),
  ModuleModel(
    title: 'Actividad física adaptada',
    description: 'Ejercicios personalizados para tu bienestar físico.',
    icon: Icons.fitness_center_rounded,
    color: const Color(0xFF27AE60),
    route: '/actividad-fisica',
    lottieUrl: "https://lottie.host/d24add7b-f0ff-4396-aabd-367e1c8ce1b4/SQZGdie3lq.lottie",
    lottieSpeed: 0.8, // Más lenta porque el usuario dijo que iba rápido
  ),
  ModuleModel(
    title: 'Sueño y descanso',
    description: 'Mejora la calidad de tu sueño con hábitos saludables.',
    icon: Icons.bedtime_rounded,
    color: const Color(0xFF4A6CF7),
    route: '/sueno',
    lottieUrl: "https://lottie.host/16c7201c-db52-4008-bc8c-aaee543eb9c2/33uyM9nBYf.lottie",
    lottieSpeed: 1.0,
  ),
  ModuleModel(
    title: 'Autocuidado y organización',
    description: 'Rutinas de cuidado personal y planificación diaria.',
    icon: Icons.spa_rounded,
    color: const Color(0xFFF2994A),
    route: '/autocuidado',
    lottieUrl: "https://lottie.host/606a9bba-d3a6-436b-8efc-017dd84a450c/tIjiH0b7Ja.lottie",
    lottieSpeed: 1.0,
  ),
];
