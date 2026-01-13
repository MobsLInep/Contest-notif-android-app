import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class RecentContests extends StatelessWidget {
  final String userHandle;
  const RecentContests({super.key, required this.userHandle});

  String formatDate(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${_monthShort(date.month)} ${date.day.toString().padLeft(2, '0')}, ${date.year % 100}";
  }

  String _monthShort(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }

  Color getRatingChangeColor(BuildContext context, int change) {
    if (change > 0) return Colors.green;
    if (change < 0) return Theme.of(context).colorScheme.error;
    return Theme.of(context).colorScheme.secondary;
  }

  Icon getRatingChangeIcon(int change) {
    if (change > 0) return const Icon(Icons.trending_up, size: 14, color: Colors.green);
    if (change < 0) return const Icon(Icons.trending_down, size: 14, color: Colors.red);
    return const Icon(Icons.remove, size: 14, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final contestResults = userProvider.contestResults;
    if (contestResults.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: const [
              Text('Recent Contests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 16),
              Text('No recent contest data available', style: TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text('Recent Contests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            ...contestResults.reversed.take(10).toList().reversed.map((result) {
              final ratingChange = result.newRating - result.oldRating;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(result.contestName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          Row(
                            children: [
                              Text('Rank #${result.rank}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              const SizedBox(width: 12),
                              Text(formatDate(result.ratingUpdateTimeSeconds), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        getRatingChangeIcon(ratingChange),
                        const SizedBox(width: 4),
                        Text(
                          '${ratingChange > 0 ? '+' : ''}$ratingChange',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: getRatingChangeColor(context, ratingChange)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
} 