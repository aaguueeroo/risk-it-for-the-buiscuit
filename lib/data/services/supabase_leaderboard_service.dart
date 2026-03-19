import 'package:start_hack_2026/core/config/supabase_config.dart';
import 'package:start_hack_2026/domain/entities/leaderboard_entry.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseLeaderboardService {
  bool get isAvailable => SupabaseConfig.isInitialized;

  Future<void> saveScore({
    required String playerName,
    required String characterType,
    required int score,
  }) async {
    if (!isAvailable) {
      return;
    }

    await Supabase.instance.client.from('leaderboard_scores').insert({
      'username': playerName,
      'character_type': characterType.toUpperCase(),
      'score': score,
    });
  }

  Future<List<LeaderboardEntry>> fetchTopScores({int limit = 20}) async {
    if (!isAvailable) {
      return const [];
    }

    final response = await Supabase.instance.client
        .from('leaderboard_scores')
        .select('id, username, character_type, score, created_at')
        .order('score', ascending: false)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((row) => LeaderboardEntry.fromJson(row as Map<String, dynamic>))
        .toList(growable: false);
  }
}
