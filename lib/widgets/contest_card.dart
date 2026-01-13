import 'package:flutter/material.dart';
import '../providers/contest_provider.dart';
import '../screens/contest_details_screen.dart';
import 'countdown_timer.dart';

class ContestCard extends StatelessWidget {
  final Contest contest;
  const ContestCard({super.key, required this.contest});

  String formatDateTime(int timestampSeconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000).toUtc().add(const Duration(hours: 5, minutes: 30));
    final dayName = _dayName(date.weekday);
    final dateStr = "$dayName, ${date.day.toString().padLeft(2, '0')} ${_monthShort(date.month)} ${date.year}";
    final timeStr = "${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
    return '$dateStr | $timeStr IST';
  }

  String _dayName(int weekday) {
    const days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    return days[weekday - 1];
  }

  String _monthShort(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  String formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Color getContestTypeColor(BuildContext context, String type) {
    final lowerType = type.toLowerCase();
    if (lowerType.contains('cf')) return Colors.red;
    if (lowerType.contains('icpc')) return Colors.amber.shade800;
    if (lowerType.contains('global')) return Colors.purple;
    if (lowerType.contains('kotlin')) return Colors.indigo;
    if (lowerType.contains('div. 1')) return Theme.of(context).colorScheme.error;
    if (lowerType.contains('div. 2')) return Theme.of(context).colorScheme.primary;
    if (lowerType.contains('div. 3')) return Colors.green;
    if (lowerType.contains('div. 4')) return Colors.cyan;
    if (lowerType.contains('educational')) return Colors.orange;
    return Theme.of(context).colorScheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final startTime = contest.startTimeSeconds ?? 0;
    final typeColor = getContestTypeColor(context, contest.type);
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ContestDetailsScreen(),
            settings: RouteSettings(arguments: contest),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contest.name,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: typeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            contest.type,
                            style: TextStyle(fontSize: 12, color: typeColor, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                  CountdownTimer(startTimeSeconds: startTime, size: CountdownTimerSize.small),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(formatDateTime(startTime), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.timer, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(formatDuration(contest.durationSeconds), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 