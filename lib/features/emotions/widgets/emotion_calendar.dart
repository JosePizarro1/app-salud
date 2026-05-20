import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/theme/app_colors.dart';
import '../models/emotion_entry.dart';
import '../services/emotion_storage.dart';

class EmotionCalendar extends StatelessWidget {
  final int year;
  final int month;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final SharedPreferences? prefs; // Not used anymore but kept for compatibility if needed
  final Map<String, EmotionType> emotions;
  final void Function(String dateStr) onDayTap;
  final String? selectedDateStr;
  final String selectedSection;
  final Map<String, List<Map<String, dynamic>>> diarioTasks;

  const EmotionCalendar({
    super.key,
    required this.year,
    required this.month,
    required this.onPrevMonth,
    required this.onNextMonth,
    this.prefs,
    required this.emotions,
    required this.onDayTap,
    this.selectedDateStr,
    required this.selectedSection,
    required this.diarioTasks,
  });

  static const List<String> _dayLabels = ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do'];
  static const List<String> _monthNames = [
    '', 'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
    'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'
  ];

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Monday = 1, Sunday = 7 → offset for grid
    final startWeekday = firstDayOfMonth.weekday; // 1=Mon

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Month Navigation ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: onPrevMonth,
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                color: const Color(0xFF2D3142),
              ),
              Text(
                '${_monthNames[month]} $year',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2D3142),
                ),
              ),
              IconButton(
                onPressed: onNextMonth,
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                color: const Color(0xFF2D3142),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ── Day Labels ──
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _dayLabels
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(
                          d,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),

          const SizedBox(height: 4),

          // ── Calendar Grid ──
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemCount: (startWeekday - 1) + daysInMonth,
            itemBuilder: (context, index) {
              // Empty cells before the first day
              if (index < startWeekday - 1) {
                return const SizedBox.shrink();
              }

              final day = index - (startWeekday - 1) + 1;
              final dateStr =
                  '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
              final emotion = emotions[dateStr];
              final isToday = now.year == year && now.month == month && now.day == day;
              final isSelected = selectedDateStr == dateStr;

              final dayDate = DateTime(year, month, day);
              final isFuture = dayDate.isAfter(now);

              final dayTasks = diarioTasks[dateStr];
              final hasTasks = dayTasks != null && dayTasks.isNotEmpty;
              final hasPending = hasTasks && dayTasks.any((t) => !t['done']);
              final allDone = hasTasks && dayTasks.every((t) => t['done']);

              // Color de fondo
              Color circleColor = Colors.transparent;
              if (selectedSection == 'diario' && emotion != null) {
                circleColor = emotion.color.withValues(alpha: 0.85);
              } else if (selectedSection == 'tareas') {
                if (allDone) {
                  circleColor = AppColors.accent.withValues(alpha: 0.15);
                } else if (hasPending) {
                  circleColor = Colors.red.withValues(alpha: 0.1);
                } else if (isSelected) {
                  circleColor = AppColors.primary.withValues(alpha: 0.15);
                }
              } else if (isSelected) {
                circleColor = AppColors.primary.withValues(alpha: 0.15);
              }

              return GestureDetector(
                onTap: isFuture ? null : () => onDayTap(dateStr),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: circleColor,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: AppColors.primary,
                              width: 2.5,
                            )
                          : (isToday
                              ? Border.all(
                                  color: const Color(0xFFFF8A71),
                                  width: 1.5,
                                )
                              : null),
                    ),
                    child: Center(
                      child: (selectedSection == 'diario' && emotion != null)
                          ? Text(
                              emotion.emoji,
                              style: const TextStyle(fontSize: 16),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$day',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w400,
                                    color: isSelected
                                        ? AppColors.primary
                                        : (isToday
                                            ? const Color(0xFFFF8A71)
                                            : const Color(0xFF2D3142)),
                                  ),
                                ),
                                if (selectedSection == 'tareas' && hasTasks) ...[
                                  const SizedBox(height: 2),
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      color: allDone ? AppColors.accent : Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ],
                            ),
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
}
