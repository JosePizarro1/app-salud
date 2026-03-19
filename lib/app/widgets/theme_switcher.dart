import 'package:flutter/material.dart';
import '../theme_controller.dart';

class ThemeSwitcher extends StatelessWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeController.instance,
      builder: (context, _) {
        final isDark = ThemeController.instance.isDarkMode;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? Colors.white70 : Colors.black54,
              size: 20,
            ),
            const SizedBox(width: 8),
            Switch(
              value: isDark,
              onChanged: (v) => ThemeController.instance.toggleTheme(),
              activeThumbColor: const Color(0xFFA5B4FC),
              activeTrackColor: const Color(0xFF1E293B),
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.black12,
            ),
          ],
        );
      },
    );
  }
}
