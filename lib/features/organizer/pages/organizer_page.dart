import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../app/theme/app_colors.dart';
import '../../home/widgets/module_header.dart';
import '../services/organizer_task_storage.dart';

class OrganizerPage extends StatefulWidget {
  const OrganizerPage({super.key});

  @override
  State<OrganizerPage> createState() => _OrganizerPageState();
}

class _OrganizerPageState extends State<OrganizerPage> {
  late int _currentYear;
  late int _currentMonth;
  late String _selectedDateStr;
  bool _isLoading = true;

  // Monthly tasks list for calendar dots
  Map<String, List<Map<String, dynamic>>> _monthTasks = {};
  // Selected date tasks
  List<Map<String, dynamic>> _dateTasks = [];

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String assetPath) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.setSource(AssetSource(assetPath));
      await _audioPlayer.setVolume(0.8);
      await _audioPlayer.resume();
    } catch (_) {
      // Ignorar errores de carga de audio
    }
  }

  void _showCustomSuccessNotification(String title, String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF2), // Premium wellness cream
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8F6F1), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F6F1), // Soft wellness green
                  shape: BoxShape.circle,
                ),
                child: const Text('🐱', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E523A),
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      message,
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF4A4D55),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height * 0.78, // show at the top of screen!
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    _selectedDateStr = _CustomDateFormat.yyyyMMdd(now);
    _checkOnboardingAndLoad();
  }

  Future<void> _checkOnboardingAndLoad() async {
    final prefs = await SharedPreferences.getInstance();
    final onboardingShown = prefs.getBool('organizer_onboarding_shown') ?? false;

    if (!onboardingShown && mounted) {
      await prefs.setBool('organizer_onboarding_shown', true);
      if (mounted) {
        await context.push('/organizer/onboarding');
      }
    }
    await _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final monthData = await OrganizerTaskStorage.getTasksForMonth(_currentYear, _currentMonth);
      final dateData = await OrganizerTaskStorage.getTasksForDate(_selectedDateStr);

      if (mounted) {
        setState(() {
          _monthTasks = monthData;
          _dateTasks = dateData;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar actividades de Supabase')),
        );
      }
    }
  }

  void _prevMonth() {
    setState(() {
      if (_currentMonth == 1) {
        _currentMonth = 12;
        _currentYear--;
      } else {
        _currentMonth--;
      }
    });
    _loadData();
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth == 12) {
        _currentMonth = 1;
        _currentYear++;
      } else {
        _currentMonth++;
      }
    });
    _loadData();
  }

  void _selectDay(String dateStr) {
    setState(() {
      _selectedDateStr = dateStr;
    });
    _loadData();
  }

  Future<void> _toggleTaskCompletion(int taskId, bool currentStatus) async {
    final newStatus = !currentStatus;

    // Optimistic update locally
    setState(() {
      final idx = _dateTasks.indexWhere((t) => t['id'] == taskId);
      if (idx != -1) {
        _dateTasks[idx]['is_completed'] = newStatus;
      }
    });

    final pointsAwarded = await OrganizerTaskStorage.toggleTask(taskId, _selectedDateStr, newStatus);
    
    if (pointsAwarded && mounted) {
      _playSound('audio/completado_sonid.mp3');
      _showPointsCelebrationDialog();
    }
    _loadData();
  }

  Future<void> _deleteTask(int taskId) async {
    // Optimistic delete
    setState(() {
      _dateTasks.removeWhere((t) => t['id'] == taskId);
    });

    await OrganizerTaskStorage.deleteTask(taskId);
    _loadData();
  }

  void _showPointsCelebrationDialog() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Celebration',
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 54)),
                  const SizedBox(height: 16),
                  Text(
                    '¡Buen trabajo!',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Has cumplido tu primera actividad de hoy y Titi te otorga:',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF2ED),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('⭐', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 8),
                        Text(
                          '+5 Puntos Vitali',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      '¡Genial!',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: FadeTransition(opacity: anim1, child: child),
        );
      },
    );
  }

  void _showAddTaskSheet() {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    DateTime taskDateTime = DateTime.parse(_selectedDateStr);
    TimeOfDay taskTime = TimeOfDay.fromDateTime(DateTime.now());
    int selectedDimension = 1; // Default: Urgent/Important

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final formattedTime = _CustomDateFormat.hhmmA(
              DateTime(taskDateTime.year, taskDateTime.month, taskDateTime.day, taskTime.hour, taskTime.minute),
            );

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Nueva actividad',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Image.asset(
                        'assets/images/gato1.png',
                        height: 80,
                        errorBuilder: (context, err, stack) => const Text('🐱', style: TextStyle(fontSize: 48)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Title
                    Text(
                      '¿Qué vas a hacer?',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: titleController,
                        style: GoogleFonts.outfit(fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Ej. Estudiar para el examen',
                          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date & Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: taskDateTime,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime(2030),
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      taskDateTime = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _CustomDateFormat.ddMMMMyyyy(taskDateTime),
                                        style: GoogleFonts.outfit(fontSize: 14),
                                      ),
                                      const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha y hora',
                                style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () async {
                                  final picked = await showTimePicker(
                                    context: context,
                                    initialTime: taskTime,
                                  );
                                  if (picked != null) {
                                    setSheetState(() {
                                      taskTime = picked;
                                    });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formattedTime,
                                        style: GoogleFonts.outfit(fontSize: 14),
                                      ),
                                      const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Eisenhower Dimension
                    Text(
                      'Dimensión de Eisenhower',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    GestureDetector(
                      onTap: () => _showDimensionSelector(context, selectedDimension, (dim) {
                        setSheetState(() {
                          selectedDimension = dim;
                        });
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _getDimensionName(selectedDimension),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getDimensionColor(selectedDimension),
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    Text(
                      'Notas (opcional)',
                      style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: notesController,
                        style: GoogleFonts.outfit(fontSize: 14),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Agrega detalles adicionales...',
                          hintStyle: GoogleFonts.outfit(color: Colors.grey.shade400, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Por favor escribe qué vas a hacer')),
                            );
                            return;
                          }

                          final dateStr = _CustomDateFormat.yyyyMMdd(taskDateTime);
                          final navigator = Navigator.of(context);

                          await OrganizerTaskStorage.addTask(
                            dateStr: dateStr,
                            title: titleController.text.trim(),
                            timeStr: formattedTime,
                            dimension: selectedDimension,
                            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          );

                          navigator.pop(); // Close sheet
                          _loadData(); // Reload
                          _playSound('audio/success_cheerful.mp3');
                          _showCustomSuccessNotification(
                            '¡Actividad Guardada!',
                            'Titi guardó tu actividad en tu horario.',
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Guardar actividad',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDimensionSelector(BuildContext context, int current, ValueChanged<int> onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Dimensión de Eisenhower',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Elige la dimensión que mejor describe tu actividad:',
                    style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  _buildDimensionOption(
                    context,
                    value: 1,
                    title: 'Urgente e importante',
                    desc: 'Hazlo ahora. Son tareas críticas que no pueden esperar.',
                    color: const Color(0xFFFFECEF),
                    textColor: const Color(0xFF9E2A3B),
                    icon: Icons.notifications_active_outlined,
                    isSelected: current == 1,
                    onSelect: onSelect,
                  ),
                  _buildDimensionOption(
                    context,
                    value: 2,
                    title: 'Importante pero no urgente',
                    desc: 'Planifícalo. Son tareas importantes para tus metas.',
                    color: const Color(0xFFE8F6F1),
                    textColor: const Color(0xFF1E523A),
                    icon: Icons.calendar_today_outlined,
                    isSelected: current == 2,
                    onSelect: onSelect,
                  ),
                  _buildDimensionOption(
                    context,
                    value: 3,
                    title: 'Urgente pero no importante',
                    desc: 'Pide ayuda o delégalo. Son tareas que pueden esperar o las puede hacer otra persona.',
                    color: const Color(0xFFE6F0FF),
                    textColor: const Color(0xFF1F4A85),
                    icon: Icons.people_outline_rounded,
                    isSelected: current == 3,
                    onSelect: onSelect,
                  ),
                  _buildDimensionOption(
                    context,
                    value: 4,
                    title: 'No urgente ni importante',
                    desc: 'Puedes dejarlo para después. Son tareas que no aportan valor ahora.',
                    color: const Color(0xFFF3EDFF),
                    textColor: const Color(0xFF532E91),
                    icon: Icons.bedtime_outlined,
                    isSelected: current == 4,
                    onSelect: onSelect,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDimensionOption(
    BuildContext context, {
    required int value,
    required String title,
    required String desc,
    required Color color,
    required Color textColor,
    required IconData icon,
    required bool isSelected,
    required ValueChanged<int> onSelect,
  }) {
    return GestureDetector(
      onTap: () {
        onSelect(value);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? textColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: textColor.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: textColor, size: 20)
            else
              Icon(Icons.radio_button_off_rounded, color: textColor.withValues(alpha: 0.4), size: 20),
          ],
        ),
      ),
    );
  }

  String _getDimensionName(int dim) {
    switch (dim) {
      case 1:
        return '🚨 Urgente e importante';
      case 2:
        return '📅 Importante pero no urgente';
      case 3:
        return '👥 Urgente pero no importante';
      case 4:
        return '🛋️ No urgente ni importante';
      default:
        return 'Urgente e importante';
    }
  }

  Color _getDimensionColor(int dim) {
    switch (dim) {
      case 1:
        return const Color(0xFF9E2A3B);
      case 2:
        return const Color(0xFF1E523A);
      case 3:
        return const Color(0xFF1F4A85);
      case 4:
        return const Color(0xFF532E91);
      default:
        return const Color(0xFF9E2A3B);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppColors.bgDark : const Color(0xFFFAF9F6);

    // Group tasks
    final tasksByDim = <int, List<Map<String, dynamic>>>{};
    for (var i = 1; i <= 4; i++) {
      tasksByDim[i] = _dateTasks.where((t) => t['dimension'] == i).toList();
    }

    // Counts for footer
    final countP1 = tasksByDim[1]!.length;
    final countP2 = tasksByDim[2]!.length;
    final countP3 = tasksByDim[3]!.length;
    final countP4 = tasksByDim[4]!.length;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/fondo_sudoku.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
            child: Container(
              color: Colors.white.withOpacity(0.4),
              child: Stack(
                children: [
                  SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 130),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.primary,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 12),

                            // Centered Title
                            Center(
                              child: Text(
                                'Organizador Personal',
                                style: GoogleFonts.outfit(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Calendar grid card
                            FadeInDown(
                              child: _buildCalendarCard(isDark),
                            ),
                            const SizedBox(height: 16),

                            // Mascot greeting card
                            FadeInUp(
                              delay: const Duration(milliseconds: 150),
                              child: _buildMascotGreetingCard(),
                            ),
                            const SizedBox(height: 20),

                            // Tasks list grouped by priority
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Actividades del día',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: _showAddTaskSheet,
                                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                                  label: Text(
                                    'Agregar tarea',
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            if (_dateTasks.isEmpty)
                              FadeInUp(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(32),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                                  ),
                                  child: Column(
                                    children: [
                                      const Text('📝', style: TextStyle(fontSize: 36)),
                                      const SizedBox(height: 8),
                                      Text(
                                        'No hay actividades programadas',
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white70 : Colors.grey.shade600,
                                        ),
                                      ),
                                      Text(
                                        'Registra tu primera tarea del día',
                                        style: GoogleFonts.outfit(
                                          fontSize: 12,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  if (tasksByDim[1]!.isNotEmpty)
                                    _buildPrioritySection(
                                      isDark,
                                      dimension: 1,
                                      name: 'Urgente e importante',
                                      tag: 'Hazlo ahora',
                                      tasks: tasksByDim[1]!,
                                      headerColor: const Color(0xFFFFECEF),
                                      tagColor: const Color(0xFF9E2A3B),
                                    ),
                                  if (tasksByDim[2]!.isNotEmpty)
                                    _buildPrioritySection(
                                      isDark,
                                      dimension: 2,
                                      name: 'Importante pero no urgente',
                                      tag: 'Planifícalo',
                                      tasks: tasksByDim[2]!,
                                      headerColor: const Color(0xFFE8F6F1),
                                      tagColor: const Color(0xFF1E523A),
                                    ),
                                  if (tasksByDim[3]!.isNotEmpty)
                                    _buildPrioritySection(
                                      isDark,
                                      dimension: 3,
                                      name: 'Urgente pero no importante',
                                      tag: 'Pide ayuda o delégalo',
                                      tasks: tasksByDim[3]!,
                                      headerColor: const Color(0xFFE6F0FF),
                                      tagColor: const Color(0xFF1F4A85),
                                    ),
                                  if (tasksByDim[4]!.isNotEmpty)
                                    _buildPrioritySection(
                                      isDark,
                                      dimension: 4,
                                      name: 'No urgente ni importante',
                                      tag: 'Puedes dejarlo para después',
                                      tasks: tasksByDim[4]!,
                                      headerColor: const Color(0xFFF3EDFF),
                                      tagColor: const Color(0xFF532E91),
                                    ),
                                ],
                              ),

                            const SizedBox(height: 16),

                            // Titi Tip
                            FadeInUp(
                              delay: const Duration(milliseconds: 300),
                              child: _buildTitiTipCard(),
                            ),
                            const SizedBox(height: 16),

                            // Resumen de tu día footer
                            FadeInUp(
                              delay: const Duration(milliseconds: 350),
                              child: _buildSummaryFooter(isDark, countP1, countP2, countP3, countP4),
                            ),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // Shared Header (Home + Emergency)
          const ModuleHeader(showHome: true),

          // Help Button (Interrogación) - Using Container placeholder to avoid 404 fetch error until asset is added
          Positioned(
            right: MediaQuery.of(context).size.width * 0.24, // to the left of the emergency button
            top: MediaQuery.of(context).size.height * 0.093, // vertically aligned with the header buttons
            child: GestureDetector(
              onTap: () => context.push('/organizer/onboarding'),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.14,
                height: MediaQuery.of(context).size.width * 0.14,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                  border: Border.all(
                    color: isDark ? Colors.white24 : const Color(0xFFF1EEFB),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '❓',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  ),
),
),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCalendarCard(bool isDark) {
    final now = DateTime.now();
    final firstDay = DateTime(_currentYear, _currentMonth, 1);
    final totalDays = DateTime(_currentYear, _currentMonth + 1, 0).day;
    final startWeekday = firstDay.weekday; // 1=Mon, 7=Sun

    final months = [
      '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                onPressed: _prevMonth,
              ),
              Text(
                '${months[_currentMonth]} $_currentYear',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                onPressed: _nextMonth,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Days labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 6),

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: (startWeekday - 1) + totalDays,
            itemBuilder: (context, index) {
              if (index < startWeekday - 1) {
                return const SizedBox.shrink();
              }

              final day = index - (startWeekday - 1) + 1;
              final dateStr = '$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final isSelected = _selectedDateStr == dateStr;
              final isToday = now.year == _currentYear && now.month == _currentMonth && now.day == day;

              final dayTasks = _monthTasks[dateStr] ?? [];
              final hasTasks = dayTasks.isNotEmpty;
              final allDone = hasTasks && dayTasks.every((t) => t['is_completed'] == true);

              // Indicator color
              Color? dotColor;
              if (hasTasks) {
                if (allDone) {
                  dotColor = AppColors.accent; // Mint for completed
                } else {
                  // Find highest priority dimension
                  int highestDim = 4;
                  for (var t in dayTasks) {
                    final d = t['dimension'] as int;
                    if (d < highestDim) highestDim = d;
                  }
                  dotColor = _getDimensionColor(highestDim);
                }
              }

              return GestureDetector(
                onTap: () => _selectDay(dateStr),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : (isToday ? Border.all(color: AppColors.secondary, width: 1.5) : null),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$day',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : (isToday ? AppColors.secondary : (isDark ? Colors.white : AppColors.textPrimaryLight)),
                          ),
                        ),
                        if (dotColor != null) ...[
                          const SizedBox(height: 2),
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMascotGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6), // Soft yellowish
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFE3B3), width: 1),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/images/gato1.png',
            height: 60,
            errorBuilder: (context, err, stack) => const Text('🐱', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¡Hola!',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8A6200),
                  ),
                ),
                Text(
                  'Organiza tu día y cumple tus metas sin estrés.',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF8A6200),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrioritySection(
    bool isDark, {
    required int dimension,
    required String name,
    required String tag,
    required List<Map<String, dynamic>> tasks,
    required Color headerColor,
    required Color tagColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.black.withValues(alpha: 0.03)),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: tagColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$dimension',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: tagColor,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: tagColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Section Tasks
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: tasks.map((task) {
                final isDone = task['is_completed'] as bool? ?? false;
                final taskId = task['id'] as int;
                final title = task['title'] as String;
                final time = task['task_time'] as String;
                final notes = task['notes'] as String? ?? '';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      // Checkbox
                      GestureDetector(
                        onTap: () => _toggleTaskCompletion(taskId, isDone),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: isDone ? tagColor : Colors.transparent,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDone ? tagColor : Colors.grey.shade300,
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Title & Time
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isDone
                                    ? Colors.grey.shade400
                                    : (isDark ? Colors.white : AppColors.textPrimaryLight),
                                decoration: isDone ? TextDecoration.lineThrough : null,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: 12, color: Colors.grey.shade400),
                                const SizedBox(width: 4),
                                Text(
                                  time,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                if (notes.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      notes,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.outfit(
                                        fontSize: 10,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Delete
                      IconButton(
                        icon: Icon(Icons.delete_outline_rounded, color: Colors.grey.shade400, size: 20),
                        onPressed: () => _deleteTask(taskId),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitiTipCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3EDFF), // Soft purple
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD4BFFF), width: 1),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tip de Titi:',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: const Color(0xFF532E91),
                  ),
                ),
                Text(
                  'Recuerda revisar tu día al final y celebrar tus logros, por pequeños que sean.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: const Color(0xFF532E91),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/gato2.png',
            height: 50,
            errorBuilder: (context, err, stack) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryFooter(bool isDark, int c1, int c2, int c3, int c4) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
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
          Text(
            'Resumen de tu día',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryBubble('🚨', c1, const Color(0xFFFFECEF), const Color(0xFF9E2A3B)),
              _buildSummaryBubble('📅', c2, const Color(0xFFE8F6F1), const Color(0xFF1E523A)),
              _buildSummaryBubble('👥', c3, const Color(0xFFE6F0FF), const Color(0xFF1F4A85)),
              _buildSummaryBubble('🛋️', c4, const Color(0xFFF3EDFF), const Color(0xFF532E91)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBubble(String emoji, int count, Color bg, Color textC) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            '$count',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textC,
            ),
          ),
        ],
      ),
    );
  }
}

class _CustomDateFormat {
  static String yyyyMMdd(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  static String ddMMMMyyyy(DateTime dt) {
    const months = ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  static String hhmmA(DateTime dt) {
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }
}
