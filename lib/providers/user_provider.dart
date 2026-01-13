import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class UserInfo {
  final String handle;
  final int? rating;
  final int? maxRating;
  final String? rank;
  final String? maxRank;
  final String titlePhoto;
  final String avatar;

  UserInfo({
    required this.handle,
    this.rating,
    this.maxRating,
    this.rank,
    this.maxRank,
    required this.titlePhoto,
    required this.avatar,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    String normalizeUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      if (url.startsWith('//')) {
        return 'https:$url';
      }
      return url;
    }

    return UserInfo(
      handle: json['handle'],
      rating: json['rating'],
      maxRating: json['maxRating'],
      rank: json['rank'],
      maxRank: json['maxRank'],
      titlePhoto: normalizeUrl(json['titlePhoto']),
      avatar: normalizeUrl(json['avatar']),
    );
  }
}

class ContestResult {
  final int contestId;
  final String contestName;
  final String handle;
  final int rank;
  final int ratingUpdateTimeSeconds;
  final int oldRating;
  final int newRating;

  ContestResult({
    required this.contestId,
    required this.contestName,
    required this.handle,
    required this.rank,
    required this.ratingUpdateTimeSeconds,
    required this.oldRating,
    required this.newRating,
  });

  factory ContestResult.fromJson(Map<String, dynamic> json) {
    return ContestResult(
      contestId: json['contestId'],
      contestName: json['contestName'],
      handle: json['handle'],
      rank: json['rank'],
      ratingUpdateTimeSeconds: json['ratingUpdateTimeSeconds'],
      oldRating: json['oldRating'],
      newRating: json['newRating'],
    );
  }
}

class UserProvider extends ChangeNotifier {
  final SharedPreferences prefs;
  UserInfo? userInfo;
  String? userHandle;
  List<ContestResult> contestResults = [];
  bool loading = false;
  String? error;

  // New fields for analytics
  Map<String, int> languageCounts = {};
  Map<DateTime, int> submissionsPerDay = {};
  int totalSubmissions = 0;

  UserProvider(this.prefs) {
    _loadUserHandle();
  }

  Future<void> _loadUserHandle() async {
    userHandle = prefs.getString('userHandle');
    if (userHandle != null) {
      await fetchUserInfo();
    }
    notifyListeners();
  }

  Future<void> _saveUserHandle(String handle) async {
    await prefs.setString('userHandle', handle);
  }

  Future<void> _clearUserHandle() async {
    await prefs.remove('userHandle');
  }

  void setUserHandle(String handle) {
    userHandle = handle;
    userInfo = null;
    contestResults = [];
    error = null;
    
    // Register user with notification service
    // NotificationService().setUserId(handle);
    
    notifyListeners();
  }

  Future<void> fetchUserInfo() async {
    if (userHandle == null) return;
    loading = true;
    error = null;
    notifyListeners();
    try {
      final url = 'https://codeforces.com/api/user.info?handles=$userHandle';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK' && (data['result'] as List).isNotEmpty) {
        userInfo = UserInfo.fromJson(data['result'][0]);
        await _saveUserHandle(userHandle!); // Only save if valid
        await fetchContestResults();
        await fetchUserSubmissions();
      } else {
        error = 'User not found. Please check the handle.';
        userHandle = null; // Reset handle if invalid
      }
    } catch (e) {
      error = 'Network error. Please check your connection.';
      userHandle = null; // Reset handle if error
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchContestResults() async {
    if (userHandle == null) return;
    try {
      final url = 'https://codeforces.com/api/user.rating?handle=$userHandle';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final results = (data['result'] as List)
            .map((e) => ContestResult.fromJson(e))
            .toList();
        results.sort((a, b) => a.ratingUpdateTimeSeconds.compareTo(b.ratingUpdateTimeSeconds));
        contestResults = results;
      }
    } catch (e) {
      // Contest results are optional, don't set error
    }
    notifyListeners();
  }

  // Fetch and process all submissions for analytics
  Future<void> fetchUserSubmissions() async {
    if (userHandle == null) return;
    languageCounts = {};
    submissionsPerDay = {};
    totalSubmissions = 0;
    try {
      final url = 'https://codeforces.com/api/user.status?handle=$userHandle';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final submissions = data['result'] as List;
        totalSubmissions = submissions.length;
        for (var sub in submissions) {
          // Language count
          final lang = sub['programmingLanguage'] ?? 'Unknown';
          languageCounts[lang] = (languageCounts[lang] ?? 0) + 1;
          // Heatmap: group by day
          final ts = sub['creationTimeSeconds'];
          final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
          final day = DateTime(date.year, date.month, date.day);
          submissionsPerDay[day] = (submissionsPerDay[day] ?? 0) + 1;
        }
      }
    } catch (e) {
      // Ignore errors for analytics
    }
    notifyListeners();
  }

  void clearUserData() {
    userHandle = null;
    userInfo = null;
    contestResults = [];
    error = null;
    _clearUserHandle();
    
    // Clear notification service data
    NotificationService().clearUserData();
    
    notifyListeners();
  }
} 