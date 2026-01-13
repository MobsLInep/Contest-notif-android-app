import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/contest_provider.dart';
import '../widgets/loading_spinner.dart';

class ContestDetailsScreen extends StatefulWidget {
  static const routeName = '/contest-details';

  const ContestDetailsScreen({super.key});

  @override
  State<ContestDetailsScreen> createState() => _ContestDetailsScreenState();
}

class _ContestDetailsScreenState extends State<ContestDetailsScreen> {
  bool _isLoading = true;
  String? _content;
  String? _errorMessage;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final contest = ModalRoute.of(context)!.settings.arguments as Contest;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadAnnouncement(contest);
      });
      _isInitialized = true;
    }
  }

  // Codeforces rank colors (matching the actual colors from Codeforces)
  // Based on the API's USER_CLASS_TO_TAG mapping
  static const Map<String, Color> tagColors = {
    'grandmaster': Color(0xFFFF0000), // Red (for user-legendary and user-red)
    'master': Color(0xFFFF8C00), // Orange (for user-orange)
    'candidate_master': Color(0xFFAA00AA), // Purple/Violet (for user-violet)
    'expert': Color(0xFF0000FF), // Blue (for user-blue)
    'specialist': Color(0xFF03A89E), // Cyan (for user-cyan)
    'pupil': Color(0xFF008000), // Green (for user-green)
    'newbie': Color(0xFF808080), // Gray (for user-gray)
    'unrated': Color(0xFF000000), // Black (for user-black)
    'admin': Color(0xFF000000), // Black (for user-admin)
  };

  Future<void> _loadAnnouncement(Contest contest) async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _content = null;
      _errorMessage = null;
    });
    try {
      final resp = await http.get(Uri.parse('https://scraper-api-j7tm.onrender.com/api/posts'));
      if (resp.statusCode == 200) {
        final List<dynamic> posts = json.decode(resp.body);
        String normalize(String s) => s.replaceAll(RegExp(r'[^a-zA-Z0-9 ]'), '').toLowerCase();
        final contestNumberMatches = RegExp(r'\d+').allMatches(contest.name);
        final contestNumbers = contestNumberMatches.map((m) => m.group(0)).whereType<String>().toList();
        final contestType = contest.name.split(RegExp(r'\d+')).first.trim();
        final match = posts.firstWhere(
          (p) {
            final title = p['title'] as String;
            final normalizedTitle = normalize(title);
            final titleNumbers = RegExp(r'\d+').allMatches(title).map((m) => m.group(0)).whereType<String>().toList();
            final hasNumber = contestNumbers.any((n) => titleNumbers.contains(n));
            final hasType = contestType.isNotEmpty && normalizedTitle.contains(normalize(contestType));
            return hasNumber && hasType;
          },
          orElse: () => null,
        );
        if (match != null && match['description'] != null && (match['description'] as String).trim().isNotEmpty) {
          var content = match['description'] as String;
          
          // Decode HTML entities and Unicode escapes
          content = content
              .replaceAll('\\u003C', '<')
              .replaceAll('\\u003E', '>')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>');
          
          // Fix image sources
          content = content.replaceAllMapped(
            RegExp(r'data-cfsrc="([^"]+)"'),
            (m) => 'src="https://codeforces.com${m.group(1)}"',
          );
          
          // Remove unnecessary style attributes and noscript tags
          content = content.replaceAll(RegExp(r'style="display:none;visibility:hidden;"'), '');
          content = content.replaceAll(RegExp(r'<noscript>[\s\S]*?<\/noscript>'), '');
          
          if (!mounted) return;
          setState(() {
            _content = content;
          });
        } else {
          if (!mounted) return;
          setState(() {
            _content = 'Description of this contest has not been generated yet';
          });
        }
      } else {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Failed to load contest announcement.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to load contest announcement.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final contest = ModalRoute.of(context)!.settings.arguments as Contest;
    final contestUrl = 'https://codeforces.com/contests/${contest.id}';

    return Scaffold(
      appBar: AppBar(
        title: Text(contest.name, style: const TextStyle(fontSize: 16)),
      ),
      body: _buildBody(),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => launchUrl(Uri.parse(contestUrl)),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Contest Link'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      Share.share('Check out this Codeforces contest: $contestUrl'),
                  icon: const Icon(Icons.share),
                  label: const Text('Share'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final contest = ModalRoute.of(context)!.settings.arguments as Contest;

    if (_isLoading) {
      return Column(
        children: [
          const Expanded(child: Center(child: LoadingSpinner())),
        ],
      );
    }

    if (_errorMessage != null) {
      return Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
        ],
      );
    }

    if (_content == null) {
      return Column(
        children: [
          const Expanded(child: SizedBox.shrink()),
        ],
      );
    }
    if (_content == 'Description of this contest has not been generated yet') {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      final textColor = isDark ? Colors.white : Colors.black87;
      final labelColor = isDark ? Colors.blue[200] : theme.colorScheme.primary;
      final valueColor = isDark ? Colors.white70 : Colors.black87;
      String formatDuration(int seconds) {
        final h = seconds ~/ 3600;
        final m = (seconds % 3600) ~/ 60;
        return '${h}h ${m}m';
      }
      String formatDateTime(int? ts, {bool utc = false}) {
        if (ts == null) return '-';
        final dt = DateTime.fromMillisecondsSinceEpoch(ts * 1000, isUtc: utc);
        final local = dt.toLocal();
        final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][local.weekday - 1];
        final dateStr = '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
        final timeStr = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
        final utcStr = dt.toUtc().toIso8601String().replaceFirst('T', ' ').substring(0, 16);
        return '$weekday, $dateStr $timeStr (Local)\n$utcStr UTC';
      }
      String endTimeStr = '-';
      if (contest.startTimeSeconds != null) {
        final end = DateTime.fromMillisecondsSinceEpoch(contest.startTimeSeconds! * 1000).add(Duration(seconds: contest.durationSeconds));
        final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][end.weekday - 1];
        final dateStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';
        final timeStr = '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';
        final utcStr = end.toUtc().toIso8601String().replaceFirst('T', ' ').substring(0, 16);
        endTimeStr = '$weekday, $dateStr $timeStr (Local)\n$utcStr UTC';
      }
      return Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Card(
                        color: theme.cardColor.withValues(alpha: isDark ? 0.95 : 1),
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contest.name,
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                                textAlign: TextAlign.left,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Text('Type: ', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
                                  Text(contest.type, style: TextStyle(color: valueColor)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text('Duration: ', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
                                  Text(formatDuration(contest.durationSeconds), style: TextStyle(color: valueColor)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Start: ', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
                                  Expanded(child: Text(formatDateTime(contest.startTimeSeconds), style: TextStyle(color: valueColor))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('End: ', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
                                  Expanded(child: Text(endTimeStr, style: TextStyle(color: valueColor))),
                                ],
                              ),
                              if (contest.phase.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text('Phase: ', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
                                    Text(contest.phase, style: TextStyle(color: valueColor)),
                                  ],
                                ),
                              ],
                              if (contest.preparedBy != null && contest.preparedBy!.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Text('Prepared by: ', style: TextStyle(fontWeight: FontWeight.w600, color: labelColor)),
                                    Flexible(child: Text(contest.preparedBy!, style: TextStyle(color: valueColor), overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Description of this contest has not been provided yet.',
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Html(
              data: _content,
              style: {
                "body": Style(
                  fontSize: FontSize(16.0),
                  lineHeight: LineHeight.number(1.5),
                ),
                "p": Style(
                  margin: Margins.only(bottom: 12.0),
                ),
                "h1, h2, h3, h4, h5, h6": Style(
                  fontWeight: FontWeight.bold,
                  margin: Margins.only(top: 16.0, bottom: 8.0),
                ),
                "h1": Style(fontSize: FontSize(26.0)),
                "h2": Style(fontSize: FontSize(24.0)),
                "h3": Style(fontSize: FontSize(22.0)),
                "ul": Style(
                  padding: HtmlPaddings.only(left: 24),
                ),
                "li": Style(
                  margin: Margins.symmetric(vertical: 4.0),
                  listStyleType: ListStyleType.circle,
                ),
                "a": Style(
                  color: Theme.of(context).colorScheme.primary,
                  textDecoration: TextDecoration.none,
                  fontWeight: FontWeight.w600,
                ),
                "img": Style(
                  margin: Margins.symmetric(vertical: 10.0),
                ),
              },
              extensions: [
                // Custom image rendering
                TagExtension(
                  tagsToExtend: {"img"},
                  builder: (context) {
                    final src = context.attributes['src'] ?? '';
                    if (src.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            src,
                            fit: BoxFit.contain,
                            width: MediaQuery.of(context.buildContext!).size.width * 0.85,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Image failed to load',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Handle all Codeforces rank tags with individual extensions
                ...tagColors.entries.map((entry) => TagExtension(
                      tagsToExtend: {entry.key},
                      builder: (context) => Text.rich(
                        TextSpan(
                          text: context.innerHtml,
                          style: TextStyle(
                            color: entry.value,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
              ],
              onLinkTap: (url, _, __) {
                if (url != null) {
                  launchUrl(Uri.parse(url));
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}