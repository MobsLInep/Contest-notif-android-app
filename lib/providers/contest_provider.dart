import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Contest {
  final int id;
  final String name;
  final String type;
  final String phase;
  final bool frozen;
  final int durationSeconds;
  final int? startTimeSeconds;
  final int? relativeTimeSeconds;
  final String? description;
  final String? preparedBy;

  Contest({
    required this.id,
    required this.name,
    required this.type,
    required this.phase,
    required this.frozen,
    required this.durationSeconds,
    this.startTimeSeconds,
    this.relativeTimeSeconds,
    this.description,
    this.preparedBy,
  });

  factory Contest.fromJson(Map<String, dynamic> json) {
    return Contest(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      phase: json['phase'],
      frozen: json['frozen'],
      durationSeconds: json['durationSeconds'],
      startTimeSeconds: json['startTimeSeconds'],
      relativeTimeSeconds: json['relativeTimeSeconds'],
      description: json['description'],
      preparedBy: json['preparedBy'],
    );
  }
}

class ContestProvider extends ChangeNotifier {
  List<Contest> contests = [];
  bool loading = false;
  String? error;

  Future<void> fetchContests() async {
    loading = true;
    error = null;
    notifyListeners();
    try {
      const url = 'https://codeforces.com/api/contest.list';
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final upcomingContests = (data['result'] as List)
            .where((c) => c['phase'] == 'BEFORE')
            .map((e) => Contest.fromJson(e))
            .toList();
        upcomingContests.sort((a, b) => (a.startTimeSeconds ?? 0).compareTo(b.startTimeSeconds ?? 0));
        contests = upcomingContests;
      } else {
        error = 'Failed to fetch contests from Codeforces API';
      }
    } catch (e) {
      error = 'Network error. Please check your connection.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }
} 