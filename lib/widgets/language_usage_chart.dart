import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LanguageUsageChart extends StatelessWidget {
  final Map<String, int> languageCounts;
  final int totalSubmissions;

  const LanguageUsageChart({super.key, required this.languageCounts, required this.totalSubmissions});

  @override
  Widget build(BuildContext context) {
    if (languageCounts.isEmpty || totalSubmissions == 0) {
      return const Text('No submission data available.');
    }
    final colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange, Colors.purple, Colors.cyan, Colors.amber, Colors.teal, Colors.pink, Colors.brown
    ];
    final entries = languageCounts.entries.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Languages Used', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: [
                for (int i = 0; i < entries.length; i++)
                  PieChartSectionData(
                    color: colors[i % colors.length],
                    value: entries[i].value.toDouble(),
                    title: '${((entries[i].value / totalSubmissions) * 100).toStringAsFixed(1)}%',
                    radius: 60,
                    titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 32,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            for (int i = 0; i < entries.length; i++)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 14, height: 14, color: colors[i % colors.length]),
                  const SizedBox(width: 6),
                  Text('${entries[i].key} (${entries[i].value})'),
                ],
              ),
          ],
        ),
      ],
    );
  }
} 