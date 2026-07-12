import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import '../../home/widgets/module_header.dart';
import '../../../app/theme/app_colors.dart';
import '../../../app/services/sfx_manager.dart';
import '../models/emotion_entry.dart';
import '../services/emotion_storage.dart';
import '../services/diary_storage.dart';
import '../widgets/emotion_calendar.dart';
import '../widgets/emotion_picker_modal.dart';

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

  late String _selectedDateStr;
  Timer? _debounceTimer;

  // Single text controller for the entire diary free text
  final TextEditingController _diaryContentCtrl = TextEditingController();

  // Load local diary content from SharedPreferences (100% private and offline-first)
  Future<void> _loadLocalDiaryForSelectedDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'diary_text_$_selectedDateStr';
      final savedText = prefs.getString(key) ?? '';
      _diaryContentCtrl.text = savedText;
    } catch (_) {
      // Local fallback safety
    }
  }

  // Save diary content locally (100% offline and private)
  Future<void> _saveLocalDiary(String text) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'diary_text_$_selectedDateStr';
      if (text.trim().isEmpty) {
        await prefs.remove(key);
      } else {
        await prefs.setString(key, text);
      }
    } catch (_) {
      // Local fallback safety
    }
  }

  void _onDiaryTextChanged(String val) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _saveLocalDiary(val);
    });
  }

  void _flushLocalSave() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      _saveLocalDiary(_diaryContentCtrl.text);
    }
  }

  @override
  void dispose() {
    _flushLocalSave();
    _diaryContentCtrl.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentYear = now.year;
    _currentMonth = now.month;
    _selectedDateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    _loadData();
  }

  Future<void> _loadData() async {
    final targetMonthPrefix = '$_currentYear-${_currentMonth.toString().padLeft(2, '0')}-';
    final alreadyHasData = _emotions.keys.any((key) => key.startsWith(targetMonthPrefix));

    if (!alreadyHasData) {
      setState(() => _isLoading = true);
    }

    try {
      final emotionsMap = await EmotionStorage.getEmotionsForMonth(_currentYear, _currentMonth);

      if (mounted) {
        setState(() {
          _emotions.addAll(emotionsMap);
          _isLoading = false;
        });
        await _loadLocalDiaryForSelectedDate();
        
        // Pre-fetch adjacent months in the background
        _preFetchMonths(_currentYear, _currentMonth);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        await _loadLocalDiaryForSelectedDate();
      }
    }
  }

  Future<void> _preFetchMonths(int currentYear, int currentMonth) async {
    // Calculate prev month
    int prevYear = currentYear;
    int prevMonth = currentMonth - 1;
    if (prevMonth == 0) {
      prevMonth = 12;
      prevYear--;
    }

    // Calculate next month
    int nextYear = currentYear;
    int nextMonth = currentMonth + 1;
    if (nextMonth == 13) {
      nextMonth = 1;
      nextYear++;
    }

    // Pre-fetch both in background
    try {
      final prevMap = await EmotionStorage.getEmotionsForMonth(prevYear, prevMonth);
      final nextMap = await EmotionStorage.getEmotionsForMonth(nextYear, nextMonth);
      
      if (mounted) {
        setState(() {
          _emotions.addAll(prevMap);
          _emotions.addAll(nextMap);
        });
      }
    } catch (_) {}
  }

  void _prevMonth() {
    _flushLocalSave();
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
    _flushLocalSave();
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
    _flushLocalSave();

    // 1. Play click sound instantly
    SfxManager().playClick();

    setState(() {
      _selectedDateStr = dateStr;
    });

    // 2. Open picker modal instantly without waiting for disk read
    final currentEmotion = _emotions[dateStr];
    final selected = await EmotionPickerModal.show(
      context,
      currentEmotion: currentEmotion,
    );

    if (mounted) {
      FocusScope.of(context).unfocus();
    }

    // 3. Load local diary after modal closes
    await _loadLocalDiaryForSelectedDate();

    if (selected != null) {
      // Optimistic update
      setState(() {
        _emotions[dateStr] = selected;
      });

      await EmotionStorage.saveEmotion(dateStr, selected);
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

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: Scaffold(
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
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                      children: [
                        const SizedBox(height: 10),

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
                                selectedDateStr: _selectedDateStr,
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

                        // ── Vista de Diario Personal (Interactiva) ──
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: _buildDiarioView(todayEmotion),
                        ),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Header (Home, Back + Emergency) ──
            const ModuleHeader(showHome: true, showBack: true),
          ],
        ),
      ),
    ),
  ),
),
    ),
  );
  }

  // ── Vista Interactiva: Simulación de Diario Personal (Opción 10) ──
  Widget _buildDiarioView(EmotionType? todayEmotion) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF2), // Papel crema elegante
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 25,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8E5CE), width: 1.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Línea roja vertical típica de margen de cuaderno
            Positioned(
              left: 45,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1.5,
                color: Colors.red.withValues(alpha: 0.25),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 60, right: 20, top: 24, bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Mi Diario Personal',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5C5440),
                        ),
                      ),
                      const Icon(Icons.menu_book_rounded, color: Color(0xFF8C8470), size: 22),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Unified Notebook Page (Free Text Area with Invisible Guides)
                  TextField(
                    controller: _diaryContentCtrl,
                    maxLines: 8,
                    minLines: 5,
                    keyboardType: TextInputType.multiline,
                    onChanged: _onDiaryTextChanged,
                    style: GoogleFonts.caveat(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF2B4C7E),
                      height: 1.2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Escribe aquí tu sentir o vivencias de hoy...\n\n'
                          'Guías de reflexión (opcional):\n'
                          '• ¿Por qué me siento de esta manera?\n'
                          '• ¿Cuál es mi gran meta para hoy?\n'
                          '• ¿Cuáles son mis prioridades?\n'
                          '• ¿Por qué estoy agradecido/a hoy?',
                      hintStyle: GoogleFonts.caveat(
                        fontSize: 20,
                        color: Colors.grey.shade400,
                        height: 1.2,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _diaryContentCtrl.clear();
                          _saveLocalDiary('');
                        });
                      },
                      icon: const Icon(Icons.cleaning_services_rounded, size: 16, color: Color(0xFF8C8470)),
                      label: Text(
                        'Limpiar diario',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF8C8470),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
