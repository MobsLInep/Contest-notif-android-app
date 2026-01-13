import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/contest_provider.dart';
import '../widgets/next_contest_card.dart';
import '../widgets/contest_card.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/error_message.dart';

class ContestsScreen extends StatefulWidget {
  const ContestsScreen({super.key});

  @override
  State<ContestsScreen> createState() => _ContestsScreenState();
}

class _ContestsScreenState extends State<ContestsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Provider.of<ContestProvider>(context, listen: false).fetchContests();
    });
  }

  Future<void> _onRefresh() async {
    await Provider.of<ContestProvider>(context, listen: false).fetchContests();
  }

  @override
  Widget build(BuildContext context) {
    final contestProvider = Provider.of<ContestProvider>(context);
    final contests = contestProvider.contests;
    final loading = contestProvider.loading;
    final error = contestProvider.error;

    final upcomingContests = contests;
    final nextContest = upcomingContests.isNotEmpty ? upcomingContests.first : null;
    final otherContests = upcomingContests.length > 1 ? upcomingContests.sublist(1) : [];

    if (loading && contests.isEmpty) {
      return const Center(child: LoadingSpinner());
    }
    if (error != null && contests.isEmpty) {
      return Center(child: ErrorMessage(message: error, onRetry: _onRefresh));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 32), // Increased top padding to 48
        children: [
          const Text(
            'Contest Timer',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay updated with Codeforces contests',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (nextContest != null) ...[
            NextContestCard(contest: nextContest),
            if (otherContests.isNotEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 24, bottom: 12),
                child: Text('Upcoming Contests', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
              ),
          ],
          if (otherContests.isNotEmpty)
            ...otherContests.map((contest) => ContestCard(contest: contest)),
          if (nextContest == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: const [
                  Icon(Icons.refresh, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'No upcoming contests found.\nPull to refresh or check back later.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 