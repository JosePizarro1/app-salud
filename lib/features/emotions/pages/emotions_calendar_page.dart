import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import '../../home/widgets/module_header.dart';
import '../../../app/theme/app_colors.dart';
import '../models/emotion_entry.dart';
import '../services/emotion_storage.dart';
import '../widgets/emotion_calendar.dart';
import '../widgets/emotion_picker_modal.dart';
import '../widgets/emotion_statistics.dart';

class EmotionsCalendarPage extends StatefulWidget {
  const EmotionsCalendarPage({super.key});

  @override
  State<EmotionsCalendarPage> createState() => _EmotionsCalendarPageState();
}

class _EmotionsCalendarPageState extends State<EmotionsCalendarPage> {
  late int _currentYear;
  late int _currentMonth;
  Map<String, EmotionType> _emotions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await EmotionStorage.getEmotionsForMonth(_currentYear, _currentMonth);
      if (mounted) {
        setState(() {
          _emotions = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar datos emocionales')),
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

  Future<void> _registerEmotion(String dateStr) async {
    final currentEmotion = _emotions[dateStr];

    final selected = await EmotionPickerModal.show(
      context,
      currentEmotion: currentEmotion,
    );

    if (selected != null) {
      // Optimistic update
      setState(() {
        _emotions[dateStr] = selected;
      });

      try {
        await EmotionStorage.saveEmotion(dateStr, selected);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar en Supabase')),
          );
          _loadData(); // Revert to server state
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayEmotion = _emotions[todayStr];

    // Dynamic background tint based on today's emotion
    final Color bgTop = todayEmotion != null
        ? Color.lerp(const Color(0xFFFFF5F2), todayEmotion.color.withValues(alpha: 0.15), 0.5)!
        : const Color(0xFFFFF5F2);
    final Color bgBottom = todayEmotion != null
        ? Color.lerp(const Color(0xFFF5F0FF), todayEmotion.color.withValues(alpha: 0.08), 0.5)!
        : const Color(0xFFF5F0FF);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgTop, bgBottom],
          ),
        ),
        child: Stack(
          children: [
            // ── Scrollable Content ──
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 70),
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),

                        // ── Title ──
                        FadeInDown(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Text('🎭', style: TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Registro Emocional',
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2D3142),
                                        ),
                                      ),
                                      Text(
                                        '¿Cómo te sientes hoy?',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Calendar ──
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: _isLoading 
                            ? const SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                              )
                            : EmotionCalendar(
                                year: _currentYear,
                                month: _currentMonth,
                                onPrevMonth: _prevMonth,
                                onNextMonth: _nextMonth,
                                emotions: _emotions,
                                onDayTap: _registerEmotion,
                              ),
                        ),

                        const SizedBox(height: 16),

                        // ── Emotion Legend ──
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(
                                vertical: 12, horizontal: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: EmotionType.values.map((e) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(e.emoji,
                                        style: const TextStyle(fontSize: 22)),
                                    const SizedBox(height: 2),
                                    Text(
                                      e.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w500,
                                        color: e.color,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // ── Register Button ──
                        FadeInUp(
                          delay: const Duration(milliseconds: 400),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: GestureDetector(
                              onTap: () => _registerEmotion(todayStr),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      Color(0xFFFFB09C),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (todayEmotion != null) ...[
                                      Text(todayEmotion.emoji,
                                          style: const TextStyle(fontSize: 22)),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Hoy te sientes: ${todayEmotion.label}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.edit_rounded,
                                          color: Colors.white70, size: 18),
                                    ] else ...[
                                      const Icon(Icons.add_circle_outline_rounded,
                                          color: Colors.white, size: 22),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Registrar cómo te sientes hoy',
                                        style: GoogleFonts.poppins(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Statistics ──
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: EmotionStatistics(
                            monthlyStats: EmotionStorage.calculateMonthlyStats(_emotions),
                            weeklyStats: EmotionStorage.calculateWeeklyStats(_emotions),
                            year: _currentYear,
                            month: _currentMonth,
                          ),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Header (Home + Emergency) ──
            const ModuleHeader(showHome: true),
          ],
        ),
      ),
    );
  }
}
