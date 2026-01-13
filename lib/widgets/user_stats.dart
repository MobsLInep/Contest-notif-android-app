import 'package:flutter/material.dart';
import '../providers/user_provider.dart';

class UserStats extends StatelessWidget {
  final UserInfo userInfo;
  const UserStats({super.key, required this.userInfo});

  Color getRankColor(String? rank, BuildContext context) {
    if (rank == null) return Theme.of(context).colorScheme.secondary;
    final lowerRank = rank.toLowerCase();
    if (lowerRank.contains('legendary')) return Colors.red;
    if (lowerRank.contains('international grandmaster')) return Colors.red;
    if (lowerRank.contains('grandmaster')) return Colors.red;
    if (lowerRank.contains('international master')) return Colors.orange;
    if (lowerRank.contains('master')) return Colors.orange;
    if (lowerRank.contains('candidate master')) return Colors.purple;
    if (lowerRank.contains('expert')) return Colors.blue;
    if (lowerRank.contains('specialist')) return Colors.teal;
    if (lowerRank.contains('pupil')) return Colors.green;
    return Theme.of(context).colorScheme.secondary;
  }

  String formatRating(int? rating) => rating?.toString() ?? 'Unrated';

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userInfo.avatar),
                  backgroundColor: Colors.transparent,
                ),
                const SizedBox(height: 12),
                Text(userInfo.handle,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
                if (userInfo.rank != null)
                  Text(userInfo.rank!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: getRankColor(userInfo.rank, context))),
                Text(formatRating(userInfo.rating), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatCard(
                  icon: Icons.trending_up,
                  value: formatRating(userInfo.maxRating),
                  label: 'Max Rating',
                  color: getRankColor(userInfo.maxRank, context),
                ),
                _StatCard(
                  icon: Icons.emoji_events,
                  value: userInfo.maxRank ?? 'Unranked',
                  label: 'Max Rank',
                  color: Theme.of(context).colorScheme.secondary,
                ),
                _StatCard(
                  icon: Icons.track_changes,
                  value: userInfo.rating != null && userInfo.maxRating != null ? (userInfo.maxRating! - userInfo.rating!).toString() : '0',
                  label: 'To Max Rating',
                  color: Colors.green,
                ),
                _StatCard(
                  icon: Icons.emoji_events_outlined,
                  value: '-',
                  label: 'Contests',
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.icon, required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
        ],
      ),
    );
  }
} 