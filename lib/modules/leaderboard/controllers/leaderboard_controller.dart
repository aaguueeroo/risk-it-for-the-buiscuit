import 'package:flutter/foundation.dart';
import 'package:start_hack_2026/data/services/local_leaderboard_service.dart';
import 'package:start_hack_2026/data/services/supabase_leaderboard_service.dart';
import 'package:start_hack_2026/domain/entities/leaderboard_entry.dart';

class LeaderboardController extends ChangeNotifier {
  LeaderboardController({
    required LocalLeaderboardService localService,
    required SupabaseLeaderboardService supabaseService,
  }) : _localService = localService,
       _supabaseService = supabaseService;

  final LocalLeaderboardService _localService;
  final SupabaseLeaderboardService _supabaseService;

  List<LeaderboardEntry> _entries = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<LeaderboardEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadTopScores({int limit = 20}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final local = await _localService.fetchTopScores(limit: limit);
      if (_supabaseService.isAvailable) {
        final remote = await _supabaseService.fetchTopScores(limit: limit);
        _entries = _mergeScores(local, remote, limit: limit);
      } else {
        _entries = local;
      }
    } catch (e) {
      _errorMessage = 'Failed to load leaderboard: $e';
      _entries = const [];
      if (kDebugMode) {
        print(_errorMessage);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveScore({
    required String playerName,
    required String characterType,
    required int score,
  }) async {
    await _localService.savePlayerName(playerName);

    await _localService.saveScore(
      playerName: playerName,
      characterType: characterType,
      score: score,
    );

    if (_supabaseService.isAvailable) {
      try {
        await _supabaseService.saveScore(
          playerName: playerName,
          characterType: characterType,
          score: score,
        );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to sync score to Supabase: $e');
        }
      }
    }
  }

  Future<String?> getSavedPlayerName() {
    return _localService.getSavedPlayerName();
  }

  List<LeaderboardEntry> _mergeScores(
    List<LeaderboardEntry> local,
    List<LeaderboardEntry> remote, {
    required int limit,
  }) {
    final merged = [...local, ...remote]
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        if (byScore != 0) return byScore;
        return b.createdAt.compareTo(a.createdAt);
      });

    final deduped = <String, LeaderboardEntry>{};
    for (final entry in merged) {
      final key =
          '${entry.playerName}|${entry.characterType}|${entry.score}|${entry.createdAt.millisecondsSinceEpoch}';
      deduped[key] = entry;
    }

    return deduped.values.take(limit).toList(growable: false);
  }
}
