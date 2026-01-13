import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../widgets/user_stats.dart';
import '../widgets/recent_contests.dart';
import '../widgets/loading_spinner.dart';
import '../widgets/error_message.dart';
import '../widgets/language_usage_chart.dart';
import '../widgets/submissions_heatmap.dart';
import '../widgets/rank_graph.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isInit = true;

  @override
  void initState() {
    super.initState();
    // No need to call provider here, will be handled in didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      _controller.text = userProvider.userHandle ?? '';
      if (userProvider.userHandle != null && userProvider.userInfo == null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          userProvider.fetchUserInfo();
        });
      }
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSearch() {
    final handle = _controller.text.trim();
    if (handle.isNotEmpty) {
      Provider.of<UserProvider>(context, listen: false).setUserHandle(handle);
      Provider.of<UserProvider>(context, listen: false).fetchUserInfo();
    }
  }

  Future<void> _onRefresh() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userHandle != null) {
      await userProvider.fetchUserInfo();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userInfo = userProvider.userInfo;
    final loading = userProvider.loading;
    final error = userProvider.error;
    final userHandle = userProvider.userHandle;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 32), // Increased top padding to 48
        children: [
          const Text(
            'Profile',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'View your Codeforces statistics',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (userProvider.userHandle == null)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Enter Codeforces handle',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12))),
                    ),
                    onSubmitted: (_) => _handleSearch(),
                    autocorrect: false,
                    textInputAction: TextInputAction.search,
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _handleSearch,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.all(16),
                  ),
                  child: Icon(Icons.search,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ],
            ),
          const SizedBox(height: 24),
          if (loading)
            const Center(child: LoadingSpinner()),
          if (error != null)
            Center(child: ErrorMessage(message: error, onRetry: _handleSearch)),
          if (!loading && error == null && userInfo != null)
            Column(
              children: [
                UserStats(userInfo: userInfo),
                RecentContests(userHandle: userHandle!),
                const SizedBox(height: 24),
                LanguageUsageChart(
                  languageCounts: userProvider.languageCounts,
                  totalSubmissions: userProvider.totalSubmissions,
                ),
                const SizedBox(height: 24),
                SubmissionsHeatMap(
                  submissionsPerDay: userProvider.submissionsPerDay,
                ),
                const SizedBox(height: 24),
                RankGraph(contestResults: userProvider.contestResults),
              ],
            ),
          if (!loading && error == null && userInfo == null && userHandle == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: const [
                  Icon(Icons.person, size: 48, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Enter your Codeforces handle to view\nyour profile and statistics',
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