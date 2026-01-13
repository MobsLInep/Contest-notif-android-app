import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/user_provider.dart';
import 'dart:math';

class RankGraph extends StatelessWidget {
  final List<ContestResult> contestResults;

  const RankGraph({super.key, required this.contestResults});

  @override
  Widget build(BuildContext context) {
    if (contestResults.isEmpty) {
      return const Text('No rating history available.');
    }
    // Prepare data
    final spots = <FlSpot>[];
    for (int i = 0; i < contestResults.length; i++) {
      spots.add(FlSpot(i.toDouble(), contestResults[i].newRating.toDouble()));
    }
    
    // Codeforces rating bands (updated to end at 2800)
    final bands = [
      _Band(0, 1199, Colors.grey[300]!),
      _Band(1200, 1399, Colors.green[200]!),
      _Band(1400, 1599, Colors.cyan[200]!),
      _Band(1600, 1899, Colors.blue[200]!),
      _Band(1900, 2099, Colors.purple[100]!),
      _Band(2100, 2299, Colors.orange[200]!),
      _Band(2300, 2399, Colors.orange[400]!),
      _Band(2400, 2599, Colors.red[200]!),
      _Band(2600, 2799, Colors.red[400]!),
    ];
    
    // Line color by last rating
    Color lineColor = _getRatingColor(contestResults.last.newRating);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rank Graph', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: max(0, contestResults.length - 1).toDouble(),
              minY: 0,
              maxY: 2800,
              gridData: FlGridData(show: true, horizontalInterval: 400, verticalInterval: 5),
              borderData: FlBorderData(show: true, border: Border.all(color: Colors.grey[400]!, width: 1)),
              backgroundColor: Colors.transparent,
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) {
                      if (value % 400 == 0) {
                        return Text(value.toInt().toString(), style: const TextStyle(fontSize: 12));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 24,
                    getTitlesWidget: (value, meta) {
                      if (value % 5 == 0 || value == contestResults.length - 1) {
                        return Text((value.toInt() + 1).toString(), style: const TextStyle(fontSize: 10));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              // Add rating bands as background
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: bands.map((band) => HorizontalRangeAnnotation(
                  y1: band.min.toDouble(),
                  y2: band.max.toDouble(),
                  color: band.color,
                )).toList(),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    for (int i = 0; i < contestResults.length; i++)
                      FlSpot(i.toDouble(), contestResults[i].newRating.toDouble()),
                  ],
                  isCurved: false,
                  color: lineColor,
                  barWidth: 2.5,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                enabled: true,
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.white,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.x.toInt();
                      if (idx < 0 || idx >= contestResults.length) return null;
                      final c = contestResults[idx];
                      final diff = c.newRating - c.oldRating;
                      return LineTooltipItem(
                        '${c.contestName}\nRank: ${c.rank}\nΔ: ${diff > 0 ? '+' : ''}$diff\nRating: ${c.newRating}',
                        TextStyle(
                          color: _getRatingColor(c.newRating),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      );
                    }).whereType<LineTooltipItem>().toList();
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Band {
  final int min;
  final int max;
  final Color color;
  _Band(this.min, this.max, this.color);
}

Color _getRatingColor(int rating) {
  if (rating >= 3000) return Colors.black;
  if (rating >= 2600) return Colors.red[900]!;
  if (rating >= 2400) return Colors.red;
  if (rating >= 2300) return Colors.orange[700]!;
  if (rating >= 2100) return Colors.orange;
  if (rating >= 1900) return Colors.purple;
  if (rating >= 1600) return Colors.blue;
  if (rating >= 1400) return Colors.cyan[700]!;
  if (rating >= 1200) return Colors.green;
  return Colors.grey;
}