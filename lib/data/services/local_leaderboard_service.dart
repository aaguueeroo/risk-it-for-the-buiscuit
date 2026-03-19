import 'dart:convert';

import 'package:start_hack_2026/domain/entities/leaderboard_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalLeaderboardService {
  static const String _scoresKey = 'leaderboard_scores_v2';
  static const String _playerNameKey = 'leaderboard_player_name_v1';

  Future<void> savePlayerName(String playerName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_playerNameKey, playerName.trim());
  }

  Future<String?> getSavedPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_playerNameKey)?.trim();
    if (name == null || name.isEmpty) return null;
    return name;
  }

  Future<void> saveScore({
    required String playerName,
    required String characterType,
    required int score,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await fetchTopScores(limit: 500);
    final entry = LeaderboardEntry(
      id: '${DateTime.now().microsecondsSinceEpoch}',
      playerName: playerName.trim(),
      characterType: characterType.toUpperCase(),
      score: score,
      createdAt: DateTime.now(),
    );
    final updated = [...current, entry]
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        return b.createdAt.compareTo(a.createdAt);
      });
    final trimmed = updated.take(200).toList(growable: false);
    await prefs.setString(
      _scoresKey,
      jsonEncode(trimmed.map((e) => e.toJson()).toList(growable: false)),
    );
  }

  Future<List<LeaderboardEntry>> fetchTopScores({int limit = 20}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scoresKey);
    if (raw == null || raw.isEmpty) return const [];

    try {
      final list =
          (jsonDecode(raw) as List<dynamic>)
              .whereType<Map<String, dynamic>>()
              .map(LeaderboardEntry.fromJson)
              .toList(growable: false)
            ..sort((a, b) {
              final byScore = b.score.compareTo(a.score);
              if (byScore != 0) return byScore;
              return b.createdAt.compareTo(a.createdAt);
            });
      return list.take(limit).toList(growable: false);
    } catch (_) {
      return const [];
    }
  }
}
