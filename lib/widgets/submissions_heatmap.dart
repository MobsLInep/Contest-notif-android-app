import 'package:flutter/material.dart';
import 'dart:math';

class SubmissionsHeatMap extends StatelessWidget {
  final Map<DateTime, int> submissionsPerDay;

  const SubmissionsHeatMap({super.key, required this.submissionsPerDay});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 181)); // Last 182 days (26 weeks)
    final days = List.generate(182, (i) => start.add(Duration(days: i)));
    final weeks = <List<DateTime>>[];
    for (int i = 0; i < days.length; i += 7) {
      weeks.add(days.skip(i).take(7).toList());
    }
    int maxCount = 1;
    for (final count in submissionsPerDay.values) {
      if (count > maxCount) maxCount = count;
    }
    final monthLabels = <int, String>{};
    for (int w = 0; w < weeks.length; w++) {
      final firstDay = weeks[w].first;
      if (firstDay.day <= 7) {
        monthLabels[w] = _monthShort(firstDay.month);
      }
    }
    // Dynamically calculate cell size to fit the screen exactly
    final screenWidth = MediaQuery.of(context).size.width;
    final weekCount = weeks.length;
    final leftMargin = 24.0;
    final spacing = 2.0;
    final cellSize = ((screenWidth - leftMargin - (weekCount * spacing)) / weekCount)*0.94;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Submissions Heatmap', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: screenWidth,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int w = 0; w < weeks.length; w++)
                      Column(
                        children: [
                          for (int d = 0; d < 7; d++)
                            Builder(
                              builder: (context) {
                                if (w < weeks.length && d < weeks[w].length) {
                                  final day = weeks[w][d];
                                  final count = submissionsPerDay[DateTime(day.year, day.month, day.day)] ?? 0;
                                  final color = count == 0
                                      ? Colors.grey[200]
                                      : Color.lerp(Colors.green[100], Colors.green[800], min(count / maxCount, 1.0));
                                  return Tooltip(
                                    message: '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}: $count',
                                    child: Container(
                                      width: cellSize,
                                      height: cellSize,
                                      margin: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                    ),
                                  );
                                } else {
                                  return SizedBox(width: cellSize, height: cellSize);
                                }
                              },
                            ),
                        ],
                      ),
                  ],
                ),
              const SizedBox(height: 4),
              const Text(
                '(roughly of last 6 months)',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
              ],
          ),
        ),
      ],
    );
  }
}

String _monthShort(int month) {
  const months = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  return months[month];
} 