import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:animate_do/animate_do.dart';
import 'dart:async';
import '../../home/widgets/module_header.dart';
import '../../../app/theme/app_colors.dart';
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

  // ── Nuevas variables de estado ──
  late String _selectedDateStr;
  Timer? _debounceTimer;

  // Almacén en memoria de los diarios por fecha
  final Map<String, Map<String, String>> _diarioEntries = {};

  // Controladores para la simulación del Diario Personal
  final TextEditingController _emocionElegidaCtrl = TextEditingController();
  final TextEditingController _porqueCtrl = TextEditingController();
  final TextEditingController _metaCtrl = TextEditingController();
  final TextEditingController _prioridadesCtrl = TextEditingController();
  final TextEditingController _logrosCtrl = TextEditingController();

  // ── Auxiliares para Diario ──
  void _saveDiarioField(String key, String value) {
    if (!_diarioEntries.containsKey(_selectedDateStr)) {
      _diarioEntries[_selectedDateStr] = {};
    }
    _diarioEntries[_selectedDateStr]![key] = value;

    // Debounce del guardado en Supabase
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      await DiaryStorage.saveDiaryEntry(_selectedDateStr, _diarioEntries[_selectedDateStr]!);
    });
  }

  void _flushDebounceSave() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
      DiaryStorage.saveDiaryEntry(_selectedDateStr, _diarioEntries[_selectedDateStr] ?? {});
    }
  }

  void _loadDiarioForSelectedDate() {
    final entry = _diarioEntries[_selectedDateStr] ?? {};
    
    // Si ya existe una emoción registrada en Supabase para este día, y la del diario está vacía, pre-rellenamos
    final selectedDayEmotion = _emotions[_selectedDateStr];
    String defaultEmocion = '';
    if (selectedDayEmotion != null) {
      defaultEmocion = '${selectedDayEmotion.emoji} ${selectedDayEmotion.label}';
    }
    
    _emocionElegidaCtrl.text = entry['emocion'] ?? defaultEmocion;
    _porqueCtrl.text = entry['porque'] ?? '';
    _metaCtrl.text = entry['meta'] ?? '';
    _prioridadesCtrl.text = entry['prioridades'] ?? '';
    _logrosCtrl.text = entry['logros'] ?? '';
  }

  @override
  void dispose() {
    _flushDebounceSave();
    _emocionElegidaCtrl.dispose();
    _porqueCtrl.dispose();
    _metaCtrl.dispose();
    _prioridadesCtrl.dispose();
    _logrosCtrl.dispose();
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
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        EmotionStorage.getEmotionsForMonth(_currentYear, _currentMonth),
        DiaryStorage.getDiaryForMonth(_currentYear, _currentMonth),
      ]);

      if (mounted) {
        setState(() {
          _emotions = results[0] as Map<String, EmotionType>;

          _diarioEntries.clear();
          _diarioEntries.addAll(results[1] as Map<String, Map<String, String>>);

          _isLoading = false;
          _loadDiarioForSelectedDate();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar datos de Supabase')),
        );
      }
    }
  }

  void _prevMonth() {
    _flushDebounceSave();
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
    _flushDebounceSave();
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
    _flushDebounceSave();
    setState(() {
      _selectedDateStr = dateStr;
      _loadDiarioForSelectedDate();
    });

    final currentEmotion = _emotions[dateStr];

    final selected = await EmotionPickerModal.show(
      context,
      currentEmotion: currentEmotion,
    );

    if (selected != null) {
      // Optimistic update
      setState(() {
        _emotions[dateStr] = selected;
        // Auto-update the diary emotion if it's empty or placeholder
        if (_emocionElegidaCtrl.text.isEmpty || _emocionElegidaCtrl.text == 'Ej. Feliz 🌸') {
          _emocionElegidaCtrl.text = '${selected.emoji} ${selected.label}';
          _saveDiarioField('emocion', '${selected.emoji} ${selected.label}');
        }
      });

      try {
        await EmotionStorage.saveEmotion(dateStr, selected);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar emoción en Supabase')),
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
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: AppColors.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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
            ),

            // ── Header (Home + Emergency) ──
            const ModuleHeader(showHome: true),
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
                  const SizedBox(height: 20),
                  _buildNotebookLine('1. ¿Qué emoción elegí hoy?', _emocionElegidaCtrl, hint: 'Ej. Feliz 🌸', fieldKey: 'emocion', readOnly: true),
                  _buildNotebookLine('2. ¿Por qué me siento de esta manera?', _porqueCtrl, hint: 'Escribe tu motivo aquí...', fieldKey: 'porque'),
                  _buildNotebookLine('3. ¿Cuál es mi gran meta para hoy?', _metaCtrl, hint: 'Ej. Terminar mi tarea pendiente', fieldKey: 'meta'),
                  _buildNotebookLine('4. ¿Cuáles son mis prioridades hoy?', _prioridadesCtrl, hint: 'Ej. Mi salud, estudiar y descansar', fieldKey: 'prioridades'),
                  _buildNotebookLine('5. ¿Qué logré hoy por lo que estoy agradecido/a?', _logrosCtrl, hint: 'Ej. Organizar mi tiempo', fieldKey: 'logros'),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          // Mantener la emoción del día si existe en el calendario
                          final selectedDayEmotion = _emotions[_selectedDateStr];
                          if (selectedDayEmotion != null) {
                            _emocionElegidaCtrl.text = '${selectedDayEmotion.emoji} ${selectedDayEmotion.label}';
                            _saveDiarioField('emocion', '${selectedDayEmotion.emoji} ${selectedDayEmotion.label}');
                          } else {
                            _emocionElegidaCtrl.clear();
                            _saveDiarioField('emocion', '');
                          }

                          _porqueCtrl.clear();
                          _metaCtrl.clear();
                          _prioridadesCtrl.clear();
                          _logrosCtrl.clear();

                          _saveDiarioField('porque', '');
                          _saveDiarioField('meta', '');
                          _saveDiarioField('prioridades', '');
                          _saveDiarioField('logros', '');
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

  Widget _buildNotebookLine(String question, TextEditingController controller, {required String hint, required String fieldKey, bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF7D7259),
            ),
          ),
          const SizedBox(height: 2),
          TextField(
            controller: controller,
            readOnly: readOnly,
            onChanged: readOnly ? null : (val) => _saveDiarioField(fieldKey, val),
            // Estilo de letra a mano alzada en azul tinta hermoso
            style: GoogleFonts.caveat(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF2B4C7E),
              height: 1.1,
            ),
            maxLines: null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.caveat(
                fontSize: 20,
                color: Colors.grey.shade400,
              ),
              isDense: true,
              border: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDBC2), width: 1),
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFDDDBC2), width: 1),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 1.5),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
            ),
          ),
        ],
      ),
    );
  }
}
