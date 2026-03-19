import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/widgets/theme_switcher.dart';
import '../../../../app/widgets/staggered_entry.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  late AnimationController _entryController;
  
  bool practicReminders = true;
  bool waterReminders = false;
  bool sleepReminders = true;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white70 : Colors.black54;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            StaggeredEntry(
              controller: _entryController,
              index: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white70 : Colors.black54, size: 20),
                          onPressed: () => context.pop(),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          "Vitali App",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black54),
                        ),
                      ],
                    ),
                    const Row(
                      children: [
                        ThemeSwitcher(),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    StaggeredEntry(
                      controller: _entryController,
                      index: 1,
                      child: Text(
                        "AJUSTES",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: primaryTextColor),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // SECTION: PERFIL DE USUARIO
                    StaggeredEntry(
                      controller: _entryController,
                      index: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PERFIL DE USUARIO", style: _sectionTitleStyle(primaryTextColor)),
                          const SizedBox(height: 12),
                          _buildCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 30,
                                    backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE0E7FF),
                                    child: Icon(Icons.person, size: 36, color: isDark ? Colors.white54 : const Color(0xFF6366F1)),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text("Elena Ramírez", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTextColor)),
                                        const SizedBox(height: 4),
                                        Text("Correo: elena.r@vitalimail.com", style: TextStyle(fontSize: 13, color: secondaryTextColor)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            child: ListTile(
                              leading: Icon(Icons.lock_outline, color: secondaryTextColor),
                              title: Text("CAMBIAR CONTRASEÑA", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primaryTextColor)),
                              trailing: Icon(Icons.chevron_right, color: secondaryTextColor),
                              onTap: () {},
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // SECTION: PREFERENCIAS DE RUTINA
                    StaggeredEntry(
                      controller: _entryController,
                      index: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("PREFERENCIAS DE RUTINA", style: _sectionTitleStyle(primaryTextColor)),
                          const SizedBox(height: 12),
                          _buildCard(
                            isDark: isDark,
                            cardColor: cardColor,
                            child: Column(
                              children: [
                                _buildToggleRow(
                                  title: "RECORDATORIOS DIARIOS:",
                                  subtitle: "Notificaciones de práctica",
                                  icon: Icons.notifications_none_rounded,
                                  value: practicReminders,
                                  isDark: isDark,
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                  onChanged: (val) => setState(() => practicReminders = val),
                                ),
                                Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                                _buildToggleRow(
                                  title: "RECORDATORIOS DE AGUA:",
                                  subtitle: "Hidratación constante",
                                  icon: Icons.water_drop_outlined,
                                  value: waterReminders,
                                  isDark: isDark,
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                  onChanged: (val) => setState(() => waterReminders = val),
                                ),
                                Divider(height: 1, color: isDark ? Colors.white12 : Colors.black12),
                                _buildToggleRow(
                                  title: "RECORDATORIOS DE SUEÑO:",
                                  subtitle: "Higiene del sueño",
                                  icon: Icons.nights_stay_outlined,
                                  value: sleepReminders,
                                  isDark: isDark,
                                  primaryTextColor: primaryTextColor,
                                  secondaryTextColor: secondaryTextColor,
                                  onChanged: (val) => setState(() => sleepReminders = val),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),

                    // BOTON CERRAR SESION
                    StaggeredEntry(
                      controller: _entryController,
                      index: 4,
                      child: GestureDetector(
                        onTap: () {
                           context.go('/login');
                        },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: isDark ? const Color(0xFF334155) : const Color(0xFFA5B4FC),
                          ),
                          alignment: Alignment.center,
                          child: const Text("CERRAR SESIÓN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1.1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle(Color color) {
    return TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 1.0,
    );
  }

  Widget _buildCard({required bool isDark, required Color cardColor, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: isDark ? Border.all(color: Colors.white12) : Border.all(color: Colors.white, width: 2),
      ),
      child: child,
    );
  }

  Widget _buildToggleRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.white54 : const Color(0xFFA5B4FC), size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryTextColor)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 13, color: secondaryTextColor)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF6366F1),
            activeTrackColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE0E7FF),
          ),
        ],
      ),
    );
  }
}
