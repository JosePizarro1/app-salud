import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import '../../../app/theme/app_colors.dart';
import '../../emotions/models/emotion_entry.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  // Metric Values
  int _totalUsers = 0;
  int _totalSessions = 0;
  int _totalDiaries = 0;
  int _totalMeditations = 0;
  int _meditationTotalMinutes = 0;
  double _meditationAvgMinutes = 0.0;
  int _totalTasks = 0;
  int _completedTasks = 0;
  double _taskCompletionRate = 0.0;

  Map<String, int> _emotions = {
    'happy': 0,
    'relaxed': 0,
    'sad': 0,
    'anxious': 0,
    'stressed': 0,
    'overwhelmed': 0,
  };

  List<Map<String, dynamic>> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMetrics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      // Llama a la función PL/pgSQL creada con SECURITY DEFINER
      final response = await client.rpc('get_admin_metrics', params: {
        'admin_pass': 'admin123',
      });

      if (response != null && response is Map) {
        final data = Map<String, dynamic>.from(response);

        setState(() {
          _totalUsers = data['total_users'] as int? ?? 0;
          _totalSessions = data['total_sessions'] as int? ?? 0;
          _totalDiaries = data['total_diaries'] as int? ?? 0;
          _totalMeditations = data['total_meditations'] as int? ?? 0;
          _meditationTotalMinutes = data['meditation_total_minutes'] as int? ?? 0;
          _meditationAvgMinutes = (data['meditation_avg_minutes'] as num? ?? 0.0).toDouble();
          _totalTasks = data['total_tasks'] as int? ?? 0;
          _completedTasks = data['completed_tasks'] as int? ?? 0;
          _taskCompletionRate = (data['task_completion_rate'] as num? ?? 0.0).toDouble();

          if (data['emotions'] != null) {
            _emotions = Map<String, int>.from(data['emotions']);
          }

          if (data['users'] != null) {
            _users = List<Map<String, dynamic>>.from(data['users']);
          }

          _isLoading = false;
        });
      } else {
        throw Exception("Respuesta nula o inválida de Supabase");
      }
    } catch (e) {
      debugPrint("Error fetching admin metrics: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar datos del servidor: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.bgDark : AppColors.bgLight;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : Stack(
              children: [
                // ── Background header shape ──
                Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: AppColors.wavyGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                  ),
                ),

                // ── Scrollable Dashboard Content ──
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),

                      // ── Header Title & Actions ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Panel de Control',
                                  style: GoogleFonts.outfit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Administración General de Vitali',
                                  style: GoogleFonts.outfit(
                                    fontSize: 14,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                // Refresh Button
                                IconButton(
                                  icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    _loadMetrics();
                                  },
                                ),
                                const SizedBox(width: 8),
                                // Logout Button
                                IconButton(
                                  icon: const Icon(Icons.power_settings_new_rounded, color: Colors.white),
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    context.go('/login');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // ── Tab Bar (Custom Premium Design) ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TabBar(
                            controller: _tabController,
                            indicator: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            labelColor: Colors.white,
                            unselectedLabelColor: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13),
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: const [
                              Tab(text: "Métricas"),
                              Tab(text: "Emociones"),
                              Tab(text: "Usuarios"),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // ── Tab Bar Views ──
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildGeneralMetricsTab(isDark),
                            _buildEmotionsTab(isDark),
                            _buildUsersListTab(isDark),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // ── Tab 1: General Metrics ──
  Widget _buildGeneralMetricsTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Grid Stats Cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.3,
            children: [
              FadeInUp(
                duration: const Duration(milliseconds: 400),
                child: _buildMetricCard(
                  title: 'Total Usuarios',
                  value: _totalUsers.toString(),
                  icon: Icons.people_outline_rounded,
                  color: AppColors.secondary,
                  isDark: isDark,
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 500),
                child: _buildMetricCard(
                  title: 'Inicios de Sesión',
                  value: _totalSessions.toString(),
                  icon: Icons.login_rounded,
                  color: AppColors.primary,
                  isDark: isDark,
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                child: _buildMetricCard(
                  title: 'Registros Diario',
                  value: _totalDiaries.toString(),
                  icon: Icons.book_outlined,
                  color: AppColors.accent,
                  isDark: isDark,
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 700),
                child: _buildMetricCard(
                  title: 'Meditaciones',
                  value: _totalMeditations.toString(),
                  icon: Icons.spa_outlined,
                  color: const Color(0xFFF9A825),
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tareas Card
          FadeInUp(
            duration: const Duration(milliseconds: 800),
            child: _buildTasksSectionCard(isDark),
          ),

          const SizedBox(height: 20),

          // Meditacion Stats Card
          FadeInUp(
            duration: const Duration(milliseconds: 900),
            child: _buildMeditationStatsCard(isDark),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ── Tab 2: Emotions ──
  Widget _buildEmotionsTab(bool isDark) {
    final int totalEmotionEntries = _emotions.values.fold(0, (sum, val) => sum + val);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: FadeInUp(
        duration: const Duration(milliseconds: 500),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Distribución del Estado Emocional',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                'Total de entradas evaluadas: $totalEmotionEntries',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 20),
              
              // Recorrer los tipos de emoción
              ...EmotionType.values.map((type) {
                final count = _emotions[type.name] ?? 0;
                final double percent = totalEmotionEntries > 0 ? count / totalEmotionEntries : 0.0;
                final percentText = "${(percent * 100).toStringAsFixed(1)}%";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(type.emoji, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 8),
                              Text(
                                type.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "$count ($percentText)",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: type.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: percent,
                          minHeight: 10,
                          backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(type.color),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ── Tab 3: Users List ──
  Widget _buildUsersListTab(bool isDark) {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          'No hay usuarios registrados.',
          style: GoogleFonts.outfit(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final name = user['full_name'] as String? ?? 'N/A';
        final email = user['email'] as String? ?? 'N/A';
        final code = user['student_code'] as String? ?? 'N/A';
        final points = user['points'] as int? ?? 0;
        final createdAtStr = user['created_at'] as String?;
        
        String formattedDate = 'N/A';
        if (createdAtStr != null) {
          try {
            final date = DateTime.parse(createdAtStr);
            formattedDate = "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
          } catch (_) {}
        }

        final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

        return FadeInLeft(
          delay: Duration(milliseconds: index * 50),
          child: Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: isDark ? AppColors.surfaceDark : Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.15),
                    child: Text(
                      initial,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : AppColors.surfaceAccent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Código: $code',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white10 : const Color(0xFFFFF2ED),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⭐ $points pts',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Reg: $formattedDate',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: isDark ? Colors.white38 : Colors.grey.shade400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Helper Widgets ──

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksSectionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.check_box_outlined, color: AppColors.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                'Tasa de Cumplimiento de Hábitos',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(_taskCompletionRate * 100).toStringAsFixed(1)}% completadas',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$_completedTasks tareas hechas de $_totalTasks creadas',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 60,
                height: 60,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: _taskCompletionRate,
                      strokeWidth: 6,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    Center(
                      child: Text(
                        "${(_taskCompletionRate * 100).round()}%",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeditationStatsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_outlined, color: Colors.teal, size: 24),
              const SizedBox(width: 8),
              Text(
                'Estadísticas de Meditación Guiada',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    _meditationTotalMinutes.toString(),
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Minutos Totales',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
              Container(width: 1, height: 40, color: isDark ? Colors.white10 : Colors.grey.shade200),
              Column(
                children: [
                  Text(
                    "${_meditationAvgMinutes.toStringAsFixed(1)} min",
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  Text(
                    'Duración Promedio',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
