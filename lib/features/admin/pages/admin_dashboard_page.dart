import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';

import '../../../app/theme/app_colors.dart';
import '../../emotions/models/emotion_entry.dart';
import '../../../app/services/background_music_manager.dart';

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
  List<Map<String, dynamic>> _forumPosts = [];
  Map<String, int> _moduleAccessStats = {};
  int _meditations1Min = 0;
  int _meditations3Min = 0;
  int _meditations5Min = 0;
  int _totalYogaDays = 0;
  int _totalEmergencyClicks = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadMetrics();
    BackgroundMusicManager().suspendMusic();
  }

  @override
  void dispose() {
    BackgroundMusicManager().unsuspendMusic();
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

        // Fetch Forum Posts via SECURITY DEFINER RPC
        List<Map<String, dynamic>> parsedPosts = [];
        try {
          final forumResponse = await client.rpc('get_admin_forum_posts', params: {
            'admin_pass': 'admin123',
          });
          if (forumResponse != null && forumResponse is Map && forumResponse['success'] == true) {
            if (forumResponse['posts'] != null) {
              parsedPosts = List<Map<String, dynamic>>.from(forumResponse['posts']);
            }
          }
        } catch (fe) {
          debugPrint("Error fetching forum posts for admin: $fe");
        }

        // Fetch Module Access Stats directly from the table
        final Map<String, int> tempStats = {};
        try {
          final logsResponse = await client.from('module_access_logs').select('module_name, times_accessed');
          if (logsResponse.isNotEmpty) {
            for (var row in logsResponse) {
              final modName = row['module_name'] as String? ?? 'Desconocido';
              final times = row['times_accessed'] as int? ?? 1;
              tempStats[modName] = (tempStats[modName] ?? 0) + times;
            }
          }
        } catch (le) {
          debugPrint("Error fetching module access logs for admin: $le");
        }

        // Fetch Meditation Sessions Breakdown (1, 3, 5 mins)
        int m1 = 0;
        int m3 = 0;
        int m5 = 0;
        try {
          final medResponse = await client.from('meditation_sessions').select('duration_minutes, times_meditated');
          if (medResponse.isNotEmpty) {
            for (var row in medResponse) {
              final duration = row['duration_minutes'] as int? ?? 0;
              final completed = row['times_meditated'] as int? ?? 1;
              if (duration == 1) {
                m1 += completed;
              } else if (duration == 3) {
                m3 += completed;
              } else if (duration == 5) {
                m5 += completed;
              }
            }
          }
        } catch (me) {
          debugPrint("Error fetching meditation sessions breakdown for admin: $me");
        }

        // Fetch Yoga days directly from the table
        int yogaDays = 0;
        try {
          final yogaResponse = await client.from('yoga_practice_history').select('user_id, practice_date');
          if (yogaResponse.isNotEmpty) {
            yogaDays = yogaResponse.length;
          }
        } catch (ye) {
          debugPrint("Error fetching yoga practice stats for admin: $ye");
        }

        // Fetch Emergency clicks directly from the table
        int emergencyClicks = 0;
        try {
          final emergencyResponse = await client.from('emergency_clicks').select('times_clicked');
          if (emergencyResponse.isNotEmpty) {
            for (var row in emergencyResponse) {
              emergencyClicks += row['times_clicked'] as int? ?? 1;
            }
          }
        } catch (ee) {
          debugPrint("Error fetching emergency clicks stats for admin: $ee");
        }

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

          _forumPosts = parsedPosts;
          _moduleAccessStats = tempStats;
          _meditations1Min = m1;
          _meditations3Min = m3;
          _meditations5Min = m5;
          _totalYogaDays = yogaDays;
          _totalEmergencyClicks = emergencyClicks;
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
                              Tab(text: "Foro"),
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
                            _buildForumTab(isDark),
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
              FadeInUp(
                duration: const Duration(milliseconds: 750),
                child: _buildMetricCard(
                  title: 'Días Práctica Yoga',
                  value: _totalYogaDays.toString(),
                  icon: Icons.self_improvement_rounded,
                  color: const Color(0xFF2E7D32),
                  isDark: isDark,
                ),
              ),
              FadeInUp(
                duration: const Duration(milliseconds: 800),
                child: _buildMetricCard(
                  title: 'Clicks Emergencia',
                  value: _totalEmergencyClicks.toString(),
                  icon: Icons.warning_amber_rounded,
                  color: const Color(0xFFD32F2F),
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

          const SizedBox(height: 20),

          // Module Access Stats Card
          FadeInUp(
            duration: const Duration(milliseconds: 950),
            child: _buildModuleAccessStatsCard(isDark),
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
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
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
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
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
          const Divider(height: 32),
          Text(
            'Distribución por Duración:',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          _buildDurationRow('Meditaciones de 1 Minuto ⏱️', _meditations1Min, Colors.teal.shade300, isDark),
          const SizedBox(height: 8),
          _buildDurationRow('Meditaciones de 3 Minutos ⏱️', _meditations3Min, Colors.teal, isDark),
          const SizedBox(height: 8),
          _buildDurationRow('Meditaciones de 5 Minutos ⏱️', _meditations5Min, Colors.teal.shade700, isDark),
        ],
      ),
    );
  }

  Widget _buildDurationRow(String label, int count, Color barColor, bool isDark) {
    final total = _meditations1Min + _meditations3Min + _meditations5Min;
    final double percent = total > 0 ? count / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            Text(
              '$count sesiones',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: barColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 8,
            backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }

  Widget _buildModuleAccessStatsCard(bool isDark) {
    final moduleLabels = {
      '/module1': 'Módulo 1\nGestión Emocional',
      '/module2': 'Módulo 2\nBienestar Físico',
      '/module3': 'Módulo 3\nMeditación',
      '/module4': 'Módulo 4\nSueño y Descanso',
      '/module5': 'Módulo 5\nHorarios',
      '/module6': 'Módulo 6\nLecciones Hábitos',
    };

    // Prepare data for chart - sorted by access count descending
    final List<MapEntry<String, int>> sortedEntries = _moduleAccessStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));


    // Colors for each bar (gradient-like)
    final List<Color> barColors = [
      const Color(0xFF6366F1), // Indigo
      const Color(0xFF8B5CF6), // Violet
      const Color(0xFFEC4899), // Pink
      const Color(0xFFF97316), // Orange
      const Color(0xFF22C55E), // Green
      const Color(0xFF06B6D4), // Cyan
    ];

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
              const Icon(Icons.bar_chart_rounded, color: Colors.indigo, size: 24),
              const SizedBox(width: 8),
              Text(
                'Accesos por Módulo',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (_moduleAccessStats.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.bar_chart_rounded,
                      size: 48,
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No hay registros de accesos aún',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                      textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los datos aparecerán aquí cuando los usuarios\naccedan a los módulos desde la Home',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
          else ...[
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.02) : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.shade100,
                  width: 1.5,
                ),
              ),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(30),  // Dot
                  1: FlexColumnWidth(),      // Name
                  2: FixedColumnWidth(90),  // Count
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: moduleLabels.entries.map((entry) {
                  final route = entry.key;
                  final label = entry.value.replaceAll('\n', ': ');
                  final count = _moduleAccessStats[route] ?? 0;
                  final index = sortedEntries.indexWhere((e) => e.key == route);
                  final color = index != -1 ? barColors[index % barColors.length] : Colors.grey;

                  return TableRow(
                    children: [
                      // Column 1: Color Dot
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Column 2: Module Name
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                          child: Text(
                            label,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                        ),
                      ),
                      // Column 3: Count Badge
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            alignment: Alignment.centerRight,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$count ${count == 1 ? 'acc.' : 'acc.'}',
                                style: GoogleFonts.outfit(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Summary row with totals
          if (_moduleAccessStats.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatChip(
                    'Total',
                    '${_moduleAccessStats.values.fold(0, (a, b) => a + b)}',
                    Colors.indigo,
                    isDark,
                  ),
                  _buildStatChip(
                    'Máximo',
                    '${sortedEntries.first.value}',
                    barColors[0],
                    isDark,
                  ),
                  _buildStatChip(
                    'Módulos',
                    '${_moduleAccessStats.length}/6',
                    Colors.teal,
                    isDark,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            color: isDark ? Colors.white60 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  // ── Tab 4: Forum Posts & Master Reply Console ──
  Widget _buildForumTab(bool isDark) {
    if (_forumPosts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.forum_outlined, size: 60, color: isDark ? Colors.white30 : Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No hay publicaciones en el foro',
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _forumPosts.length,
      itemBuilder: (context, index) {
        final post = _forumPosts[index];
        final postId = post['id'] as int;
        final repliesList = List<dynamic>.from(post['replies'] ?? []);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Avatar and Metadata
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: isDark ? Colors.white10 : const Color(0xFFF3E9DC),
                        child: Text(
                          post['author_name'][0].toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: isDark ? Colors.white70 : const Color(0xFF8C7355),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post['author_name'],
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            _formatAdminTime(post['created_at']),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "${post['likes_count']}",
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Post Body
              Text(
                post['content'],
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: isDark ? Colors.white70 : const Color(0xFF4A3B32),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),

              // Divider and nested replies
              if (repliesList.isNotEmpty) ...[
                const Divider(color: Colors.black12, height: 1),
                const SizedBox(height: 10),
                ...repliesList.map((rep) {
                  final isAdminRep = rep['is_admin'] == true;
                  final authorName = rep['author_name'] == 'Titi (Maestro)' ? 'Titi' : rep['author_name'];
                  return Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isAdminRep 
                          ? (isDark ? const Color(0xFF2C2415) : const Color(0xFFFCF8F2))
                          : (isDark ? Colors.white.withValues(alpha: 0.03) : const Color(0xFFFAF6F0)),
                      borderRadius: BorderRadius.circular(12),
                      border: isAdminRep ? Border.all(color: const Color(0xFFFFD966), width: 1.2) : null,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isAdminRep ? Icons.stars : Icons.face,
                              size: 14,
                              color: isAdminRep ? const Color(0xFFD6A000) : Colors.grey,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              authorName,
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: isAdminRep ? const Color(0xFFD6A000) : (isDark ? Colors.white70 : const Color(0xFF6B4F35)),
                              ),
                            ),
                            if (isAdminRep) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD966),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'MAESTRO',
                                  style: GoogleFonts.outfit(fontSize: 7, fontWeight: FontWeight.bold, color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rep['content'],
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: isDark ? Colors.white70 : const Color(0xFF4A3B32),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],

              const SizedBox(height: 12),

              // Button to Reply as Admin
              Align(
                alignment: Alignment.bottomRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showAdminReplyDialog(postId, isDark),
                  icon: const Icon(Icons.reply_rounded, size: 14),
                  label: Text('Responder como Titi', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFF2CC),
                    foregroundColor: const Color(0xFF8A6D00),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAdminReplyDialog(int postId, bool isDark) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : const Color(0xFFFAF6F0),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE6D5C3), width: 2),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Responder como Maestro (Titi)',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF6B4F35),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Escribe tu respuesta...',
                  labelStyle: GoogleFonts.outfit(color: isDark ? Colors.white60 : const Color(0xFF8C7355)),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: isDark ? Colors.white70 : const Color(0xFF6B4F35)),
                  ),
                ),
                style: GoogleFonts.outfit(color: isDark ? Colors.white : Colors.black),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancelar',
                      style: GoogleFonts.outfit(color: isDark ? Colors.white60 : const Color(0xFF8C7355)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () async {
                      if (textController.text.trim().isEmpty) return;
                      Navigator.pop(context);
                      await _submitAdminReply(postId, textController.text.trim());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF2CC),
                      foregroundColor: const Color(0xFF8A6D00),
                      elevation: 0,
                    ),
                    child: Text('Enviar', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitAdminReply(int postId, String content) async {
    setState(() => _isLoading = true);
    try {
      final client = Supabase.instance.client;
      final response = await client.rpc('reply_to_forum_post_as_admin', params: {
        'admin_pass': 'admin123',
        'target_post_id': postId,
        'reply_content': content,
      });

      if (response != null && response is Map && response['success'] == true) {
        HapticFeedback.mediumImpact();
      } else {
        throw Exception(response?['error'] ?? 'Error desconocido');
      }
    } catch (e) {
      debugPrint("Error submitting admin reply: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar respuesta: $e'), backgroundColor: AppColors.error),
        );
      }
    }
    // Reload metrics/posts
    await _loadMetrics();
  }

  String _formatAdminTime(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      final diff = DateTime.now().difference(date);

      if (diff.inMinutes < 60) {
        return 'Hace ${diff.inMinutes} ${diff.inMinutes == 1 ? 'min' : 'mins'}';
      } else if (diff.inHours < 24) {
        return 'Hace ${diff.inHours} ${diff.inHours == 1 ? 'hora' : 'horas'}';
      } else {
        return 'Hace ${diff.inDays} ${diff.inDays == 1 ? 'día' : 'días'}';
      }
    } catch (_) {
      return 'Reciente';
    }
  }
}
