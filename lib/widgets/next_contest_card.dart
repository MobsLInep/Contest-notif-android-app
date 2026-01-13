import 'package:flutter/material.dart';
import '../providers/contest_provider.dart';
import '../screens/contest_details_screen.dart';
import 'countdown_timer.dart';

class NextContestCard extends StatelessWidget {
  final Contest contest;
  const NextContestCard({super.key, required this.contest});

  Map<String, String> formatDateTime(int timestampSeconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestampSeconds * 1000).toUtc().add(const Duration(hours: 5, minutes: 30));
    final dayName = _dayName(date.weekday);
    final dateStr = "$dayName, ${date.day.toString().padLeft(2, '0')} ${_monthShort(date.month)} ${date.year}";
    final timeStr = "${date.hour % 12 == 0 ? 12 : date.hour % 12}:${date.minute.toString().padLeft(2, '0')} ${date.hour >= 12 ? 'PM' : 'AM'}";
    return {'date': dateStr, 'time': timeStr};
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
    if (lowerType.contains('cf')) return Colors.red.shade300;
    if (lowerType.contains('icpc')) return Colors.amber.shade300;
    if (lowerType.contains('global')) return Colors.purple.shade300;
    if (lowerType.contains('kotlin')) return Colors.indigo.shade300;
    if (lowerType.contains('div. 1')) return Colors.red.shade300;
    if (lowerType.contains('div. 2')) return Colors.blue.shade300;
    if (lowerType.contains('div. 3')) return Colors.green.shade300;
    if (lowerType.contains('div. 4')) return Colors.cyan.shade300;
    if (lowerType.contains('educational')) return Colors.orange.shade300;
    return Colors.white70;
  }

  @override
  Widget build(BuildContext context) {
    final startTime = contest.startTimeSeconds ?? 0;
    final dateTime = formatDateTime(startTime);
    final date = dateTime['date']!;
    final time = dateTime['time']!;
    final duration = formatDuration(contest.durationSeconds);
    final gradientColors = Theme.of(context).brightness == Brightness.dark
        ? [const Color(0xFF1e40af), const Color(0xFF3b82f6)]
        : [const Color(0xFF3b82f6), const Color(0xFF60a5fa)];
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ContestDetailsScreen(),
            settings: RouteSettings(arguments: contest),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: gradientColors),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.primary.withAlpha(38),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Next Contest',
                  style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                contest.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: getContestTypeColor(context, contest.type).withAlpha(50),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  contest.type,
                  style: TextStyle(
                    fontSize: 14,
                    color: getContestTypeColor(context, contest.type),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CountdownTimer(startTimeSeconds: startTime, size: CountdownTimerSize.large, textColor: Colors.white),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(icon: Icons.calendar_today, text: date),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.access_time, text: '$time IST'),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.timer_outlined, text: duration),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.white70),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }
} 