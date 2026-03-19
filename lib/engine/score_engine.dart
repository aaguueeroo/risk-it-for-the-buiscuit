import 'dart:math' show max, pow;

import 'package:start_hack_2026/domain/entities/simulation_event.dart';
import 'package:start_hack_2026/engine/calculation_engine.dart'
    show PortfolioAsset;
import 'package:start_hack_2026/engine/game_engine.dart'
    show PortfolioHistoryPoint;

class PersonaObjectives {
  const PersonaObjectives({
    required this.wealthTarget,
    required this.drawdownLimit,
    required this.concentrationLimit,
    required this.realReturnTarget,
  });

  final int wealthTarget;
  final double drawdownLimit;
  final double concentrationLimit;
  final double realReturnTarget;
}

class PersonaFidelityConfig {
  const PersonaFidelityConfig({
    required this.goodReactions,
    required this.badReactions,
    required this.minGood,
  });

  final Set<String> goodReactions;
  final Set<String> badReactions;
  final int minGood;
}

class ScoreDimensionFeedback {
  const ScoreDimensionFeedback({
    required this.score,
    required this.max,
    required this.explanation,
    required this.tip,
  });

  final int score;
  final int max;
  final String explanation;
  final String tip;
}

class FinalScoreFeedback {
  const FinalScoreFeedback({
    required this.dimensions,
    required this.summary,
    required this.total,
    required this.grade,
  });

  final Map<String, ScoreDimensionFeedback> dimensions;
  final String summary;
  final int total;
  final String grade;
}

class PersonaFeedbackTexts {
  const PersonaFeedbackTexts({
    required this.wealth,
    required this.drawdown,
    required this.behavior,
    required this.divers,
    required this.real,
  });

  final List<String> wealth;
  final List<String> drawdown;
  final List<String> behavior;
  final List<String> divers;
  final List<String> real;
}

class ScoreResult {
  const ScoreResult({
    required this.totalScore,
    required this.totalOutOf105,
    required this.grade,
    required this.wealthPoints,
    required this.drawdownPoints,
    required this.behaviorPoints,
    required this.diversificationPoints,
    required this.realReturnPoints,
    required this.personaFidelityBonus,
    required this.maxDrawdown,
    required this.maxConcentration,
    required this.worstReaction,
  });

  final int totalScore;
  final int totalOutOf105;
  final String grade;
  final double wealthPoints;
  final double drawdownPoints;
  final double behaviorPoints;
  final double diversificationPoints;
  final double realReturnPoints;
  final double personaFidelityBonus;
  final double maxDrawdown;
  final double maxConcentration;
  final String? worstReaction;
}

class ScoreEngine {
  static const int wealthWeight = 25;
  static const int drawdownWeight = 20;
  static const int behaviorWeight = 25;
  static const int diversificationWeight = 15;
  static const int realReturnWeight = 15;
  static const int fidelityWeight = 5;
  static const double _inflationAssumption = 0.02;

  static const Map<String, PersonaObjectives> _objectives = {
    'young_investor': PersonaObjectives(
      wealthTarget: 80000,
      drawdownLimit: 0.35,
      concentrationLimit: 0.40,
      realReturnTarget: 0.04,
    ),
    'middle_aged': PersonaObjectives(
      wealthTarget: 300000,
      drawdownLimit: 0.25,
      concentrationLimit: 0.35,
      realReturnTarget: 0.03,
    ),
    'pre_retirement': PersonaObjectives(
      wealthTarget: 350000,
      drawdownLimit: 0.15,
      concentrationLimit: 0.25,
      realReturnTarget: 0.015,
    ),
    'entrepreneur': PersonaObjectives(
      wealthTarget: 250000,
      drawdownLimit: 0.40,
      concentrationLimit: 0.50,
      realReturnTarget: 0.05,
    ),
    'risk_taker': PersonaObjectives(
      wealthTarget: 500000,
      drawdownLimit: 0.50,
      concentrationLimit: 0.60,
      realReturnTarget: 0.07,
    ),
  };

  static const Map<String, PersonaFidelityConfig> _fidelity = {
    'young_investor': PersonaFidelityConfig(
      goodReactions: {'buy_dip', 'ignore'},
      badReactions: {'panic_full', 'fomo_all_in'},
      minGood: 3,
    ),
    'middle_aged': PersonaFidelityConfig(
      goodReactions: {'ignore', 'buy_dip'},
      badReactions: {'panic_full', 'panic_partial'},
      minGood: 3,
    ),
    'pre_retirement': PersonaFidelityConfig(
      goodReactions: {'ignore'},
      badReactions: {'panic_full', 'fomo_all_in'},
      minGood: 2,
    ),
    'entrepreneur': PersonaFidelityConfig(
      goodReactions: {'buy_dip', 'ignore'},
      badReactions: {'panic_full'},
      minGood: 4,
    ),
    'risk_taker': PersonaFidelityConfig(
      goodReactions: {'buy_dip', 'fomo_all_in'},
      badReactions: {'panic_full', 'panic_partial'},
      minGood: 5,
    ),
  };

  static const Map<String, PersonaFeedbackTexts> _feedbackTexts = {
    'young_investor': PersonaFeedbackTexts(
      wealth: [
        'Time is your biggest asset - compounding turns small consistent gains into life-changing wealth.',
        'Even small increases to your savings rate matter enormously over 35 years.',
      ],
      drawdown: [
        'You can afford volatility - you have decades to recover from any loss.',
        'Holding through downturns rather than selling is how young investors beat the market.',
      ],
      behavior: [
        'FOMO and panic are the enemy of compounding - every bad reaction chips away at your returns.',
        'Write down your investment plan before the next crash, so emotion does not make the decision.',
      ],
      divers: [
        'No single asset should dominate - concentration is the fastest way to derail a long journey.',
        'Spread across 6-8 asset classes and rebalance once a year.',
      ],
      real: [
        'Over 35 years, inflation can seriously erode purchasing power - outpacing it is non-negotiable.',
        'Keep enough in equities to stay well ahead of inflation across your full horizon.',
      ],
    ),
    'middle_aged': PersonaFeedbackTexts(
      wealth: [
        '20 years is still enough for compounding to do heavy lifting - but consistent saving matters.',
        'Avoid large withdrawals or cash drag; every year out of the market is costly at this stage.',
      ],
      drawdown: [
        'With fewer recovery years ahead, a large loss now delays your retirement.',
        'Add bonds and gold to your mix - they cushion falls without killing long-term returns.',
      ],
      behavior: [
        'Emotional reactions are more expensive now - you have less time to recover.',
        'Automate contributions and rebalancing to take the emotion out of it.',
      ],
      divers: [
        'A balanced mix - growth assets for returns, defensive assets for protection - is the sweet spot.',
        'Review your allocation annually; do not let winners drift into concentration.',
      ],
      real: [
        'Inflation over 20 years is significant - earning 3%+ real helps keep retirement plans intact.',
        'Keep equity exposure high enough to stay ahead of prices, even if it feels uncomfortable.',
      ],
    ),
    'pre_retirement': PersonaFeedbackTexts(
      wealth: [
        'Preservation is now as important as growth - losses are harder to replace this close to retirement.',
        'Shift gradually toward defensive assets while keeping enough equity for real return.',
      ],
      drawdown: [
        'A big loss close to retirement can force bad decisions or delay retirement.',
        'Bonds, gold and cash protect the downside - accept lower upside for resilience.',
      ],
      behavior: [
        'Panic selling is especially costly at this stage because recovery time is limited.',
        'Stick to a written plan and a conservative allocation to reduce emotional pressure.',
      ],
      divers: [
        'Broad diversification is essential - one event should not derail retirement.',
        'Blend bonds, equities and real assets for income, growth and protection.',
      ],
      real: [
        'Even modest real returns help preserve purchasing power through retirement.',
        'Do not hold too much cash; inflation erodes it quietly over time.',
      ],
    ),
    'entrepreneur': PersonaFeedbackTexts(
      wealth: [
        'Your business is already concentrated risk - your portfolio should compensate with diversified growth.',
        'Strong long-term returns build financial independence your business income cannot guarantee.',
      ],
      drawdown: [
        'Business and markets can both stress at the same time, so downside control matters.',
        'Keep a liquidity buffer so you are never forced to sell at the wrong time.',
      ],
      behavior: [
        'Resilience is an edge - use it for disciplined buying, not impulsive concentration.',
        'Overtrading is the main risk; set rebalancing rules before headlines hit.',
      ],
      divers: [
        'You already have one concentrated bet - your business. Diversify the portfolio in the opposite direction.',
        'Spread across assets that do not move with your industry or income.',
      ],
      real: [
        'High real return targets are achievable with discipline and compounding.',
        'Keep costs low and reinvest consistently to maximize compounding.',
      ],
    ),
    'risk_taker': PersonaFeedbackTexts(
      wealth: [
        'Ambitious wealth targets require both upside and survival.',
        'One reckless concentration can erase years of gains; position sizing matters.',
      ],
      drawdown: [
        'A drawdown limit still matters even for aggressive personas - beyond that it is gambling.',
        'Spread high-risk bets so one blow-up does not end the run.',
      ],
      behavior: [
        'Psychological edge means staying calm when others panic.',
        'Avoid FOMO concentration; diversify across convictions.',
      ],
      divers: [
        'Even bold portfolios perform better with risk spread across multiple themes.',
        'Concentration in one asset removes recovery flexibility after a bad outcome.',
      ],
      real: [
        'Very high real return targets require discipline, not just risk-taking.',
        'Minimize cash drag and transaction costs to protect compounding.',
      ],
    ),
  };

  static const Map<String, String> _reactionTips = {
    'panic_full': 'panic liquidations during stress',
    'panic_partial': 'partial panic selling',
    'fomo_all_in': 'all-in FOMO entries',
    'overtrade': 'frequent overtrading',
  };

  ScoreResult calculateScore({
    required String personaId,
    required List<PortfolioHistoryPoint> portfolioHistory,
    required List<SimulationDataPoint> cumulativeDataPoints,
    required List<SimulationEvent> cumulativeEvents,
    required Map<String, PortfolioAsset> finalHoldings,
  }) {
    final objectives = _resolvedObjectives(personaId);
    final initialValue = portfolioHistory.isNotEmpty
        ? portfolioHistory.first.value
        : 0.0;
    final finalValue = portfolioHistory.isNotEmpty
        ? portfolioHistory.last.value
        : 0.0;
    final yearsPlayed = max(1, portfolioHistory.length - 1);

    final wealthPoints = _calculateWealthPoints(
      finalValue: finalValue,
      wealthTarget: objectives.wealthTarget,
    );
    final maxDrawdown = _calculateMaxDrawdown(
      portfolioHistory: portfolioHistory,
      dataPoints: cumulativeDataPoints,
    );
    final drawdownPoints = _calculateDrawdownPoints(
      maxDrawdown: maxDrawdown,
      drawdownLimit: objectives.drawdownLimit,
    );
    final behaviorPoints = _calculateBehaviorPoints(
      events: cumulativeEvents,
      startValue: initialValue,
      endValue: finalValue,
    );
    final maxConcentration = _calculateMaxConcentration(finalHoldings);
    final diversificationPoints = _calculateDiversificationPoints(
      holdings: finalHoldings,
      concentrationLimit: objectives.concentrationLimit,
    );
    final realReturnPoints = _calculateRealReturnPoints(
      initialValue: initialValue,
      finalValue: finalValue,
      yearsPlayed: yearsPlayed,
      realReturnTarget: objectives.realReturnTarget,
    );
    final fidelityBonus = _calculatePersonaFidelityBonus(
      personaId: personaId,
      events: cumulativeEvents,
    );

    final rawTotal =
        wealthPoints +
        drawdownPoints +
        behaviorPoints +
        diversificationPoints +
        realReturnPoints +
        fidelityBonus;
    final totalOutOf105 = rawTotal.round().clamp(0, 105);

    return ScoreResult(
      totalScore: totalOutOf105.clamp(0, 100),
      totalOutOf105: totalOutOf105,
      grade: _computeGrade(totalOutOf105),
      wealthPoints: wealthPoints,
      drawdownPoints: drawdownPoints,
      behaviorPoints: behaviorPoints,
      diversificationPoints: diversificationPoints,
      realReturnPoints: realReturnPoints,
      personaFidelityBonus: fidelityBonus,
      maxDrawdown: maxDrawdown,
      maxConcentration: maxConcentration,
      worstReaction: _detectWorstReaction(cumulativeEvents),
    );
  }

  FinalScoreFeedback buildFinalFeedback({
    required String personaId,
    required String personaLabel,
    required ScoreResult score,
    required int roundsPlayed,
  }) {
    final feedbackPersonaId = _feedbackTexts.containsKey(personaId)
        ? personaId
        : 'middle_aged';
    final bank = _feedbackTexts[feedbackPersonaId]!;

    final dimensions = {
      'wealth': ScoreDimensionFeedback(
        score: score.wealthPoints.round(),
        max: wealthWeight,
        explanation: bank.wealth[0],
        tip: bank.wealth[1],
      ),
      'drawdown': ScoreDimensionFeedback(
        score: score.drawdownPoints.round(),
        max: drawdownWeight,
        explanation: bank.drawdown[0],
        tip: bank.drawdown[1],
      ),
      'behavior': ScoreDimensionFeedback(
        score: score.behaviorPoints.round(),
        max: behaviorWeight,
        explanation: bank.behavior[0],
        tip: bank.behavior[1],
      ),
      'diversification': ScoreDimensionFeedback(
        score: score.diversificationPoints.round(),
        max: diversificationWeight,
        explanation: bank.divers[0],
        tip: bank.divers[1],
      ),
      'real_return': ScoreDimensionFeedback(
        score: score.realReturnPoints.round(),
        max: realReturnWeight,
        explanation: bank.real[0],
        tip: bank.real[1],
      ),
      'fidelity': ScoreDimensionFeedback(
        score: score.personaFidelityBonus.round(),
        max: fidelityWeight,
        explanation: 'Did you play like a real $personaLabel?',
        tip:
            "Matching your persona's risk profile and horizon is what separates smart from lucky.",
      ),
    };

    final weak = <String>[];
    dimensions.forEach((key, value) {
      if (value.score < (value.max * 0.5)) {
        weak.add(key);
      }
    });

    final summary = _buildSummary(
      score: score,
      weakDimensions: weak,
      roundsPlayed: roundsPlayed,
    );

    return FinalScoreFeedback(
      dimensions: dimensions,
      summary: summary,
      total: score.totalOutOf105,
      grade: score.grade,
    );
  }

  String _buildSummary({
    required ScoreResult score,
    required List<String> weakDimensions,
    required int roundsPlayed,
  }) {
    final total = score.totalOutOf105;
    final grade = score.grade;
    final rounds = roundsPlayed < 1 ? 1 : roundsPlayed;

    if (total >= 80) {
      return 'Excellent run - Grade $grade ($total/105) across $rounds rounds. Your discipline and diversification made the difference.';
    }
    if (total >= 50) {
      final reactionText = score.worstReaction == null
          ? ''
          : " Watch out for '${_reactionTips[score.worstReaction] ?? score.worstReaction}'.";
      final focus = weakDimensions.isEmpty
          ? 'consistency'
          : weakDimensions.take(2).join(', ');
      return 'Solid effort - Grade $grade ($total/105) across $rounds rounds.$reactionText Focus next on: $focus.';
    }
    return 'Grade $grade ($total/105) across $rounds rounds - plenty to build on. Behavior and diversification are the fastest levers to improve.';
  }

  PersonaObjectives _resolvedObjectives(String personaId) {
    if (_objectives.containsKey(personaId)) {
      return _objectives[personaId]!;
    }
    // Fallback for personas not yet configured in the table (e.g. inheritor).
    return _objectives['middle_aged']!;
  }

  String _computeGrade(int totalOutOf105) {
    if (totalOutOf105 >= 90) return 'A';
    if (totalOutOf105 >= 75) return 'B';
    if (totalOutOf105 >= 60) return 'C';
    if (totalOutOf105 >= 45) return 'D';
    return 'E';
  }

  String? _detectWorstReaction(List<SimulationEvent> events) {
    final counts = <String, int>{};

    for (final event in events) {
      if (event.type != SimulationEventType.panicSell) continue;
      final portfolioAtEvent = max(1.0, event.portfolioValueAtEvent);
      final soldRatio = (event.panicSellAmount ?? 0) / portfolioAtEvent;
      final reaction = soldRatio >= 0.35 ? 'panic_full' : 'panic_partial';
      counts[reaction] = (counts[reaction] ?? 0) + 1;
    }

    if (counts.isEmpty) return null;

    String? worst;
    var maxCount = -1;
    counts.forEach((reaction, count) {
      if (count > maxCount) {
        worst = reaction;
        maxCount = count;
      }
    });
    return worst;
  }

  double _calculateWealthPoints({
    required double finalValue,
    required int wealthTarget,
  }) {
    if (wealthTarget <= 0) return wealthWeight.toDouble();
    final ratio = (finalValue / wealthTarget).clamp(0.0, 1.0);
    return wealthWeight * ratio;
  }

  double _calculateMaxDrawdown({
    required List<PortfolioHistoryPoint> portfolioHistory,
    required List<SimulationDataPoint> dataPoints,
  }) {
    final values = dataPoints.isNotEmpty
        ? dataPoints.map((p) => p.value).toList(growable: false)
        : portfolioHistory.map((p) => p.value).toList(growable: false);
    if (values.isEmpty) return 0.0;

    var peak = values.first;
    var maxDrawdown = 0.0;
    for (final value in values) {
      if (value > peak) peak = value;
      if (peak <= 0) continue;
      final drawdown = (peak - value) / peak;
      if (drawdown > maxDrawdown) {
        maxDrawdown = drawdown;
      }
    }
    return maxDrawdown.clamp(0.0, 1.0);
  }

  double _calculateDrawdownPoints({
    required double maxDrawdown,
    required double drawdownLimit,
  }) {
    if (maxDrawdown <= drawdownLimit) return drawdownWeight.toDouble();
    if (drawdownLimit >= 1.0) return 0.0;
    final over = (maxDrawdown - drawdownLimit) / (1 - drawdownLimit);
    final ratio = (1 - over).clamp(0.0, 1.0);
    return drawdownWeight * ratio;
  }

  double _calculateBehaviorPoints({
    required List<SimulationEvent> events,
    required double startValue,
    required double endValue,
  }) {
    final panicEvents = events
        .where((e) => e.type == SimulationEventType.panicSell)
        .toList();
    final panicCount = panicEvents.length.toDouble();
    final panicLoss = panicEvents.fold<double>(
      0.0,
      (sum, e) => sum + max(0.0, e.panicSellLoss ?? 0.0),
    );
    final portfolioScale = max(1.0, max(startValue, endValue));
    final lossRatio = (panicLoss / portfolioScale).clamp(0.0, 1.0);

    final panicScore = (1 - (panicCount / 3)).clamp(0.0, 1.0);
    final lossScore = (1 - (lossRatio / 0.25)).clamp(0.0, 1.0);
    final ratio = (0.7 * panicScore) + (0.3 * lossScore);
    return behaviorWeight * ratio;
  }

  double _calculateMaxConcentration(Map<String, PortfolioAsset> holdings) {
    if (holdings.isEmpty) return 1.0;
    final totalHoldingsValue = holdings.values.fold<double>(
      0.0,
      (sum, a) => sum + a.totalValue,
    );
    if (totalHoldingsValue <= 0) return 1.0;

    var maxWeight = 0.0;
    for (final asset in holdings.values) {
      final weight = asset.totalValue / totalHoldingsValue;
      if (weight > maxWeight) {
        maxWeight = weight;
      }
    }
    return maxWeight;
  }

  double _calculateDiversificationPoints({
    required Map<String, PortfolioAsset> holdings,
    required double concentrationLimit,
  }) {
    if (holdings.isEmpty) return 0.0;
    final maxWeight = _calculateMaxConcentration(holdings);

    if (maxWeight <= concentrationLimit) {
      return diversificationWeight.toDouble();
    }
    if (concentrationLimit >= 1.0) return 0.0;
    final over = (maxWeight - concentrationLimit) / (1 - concentrationLimit);
    final ratio = (1 - over).clamp(0.0, 1.0);
    return diversificationWeight * ratio;
  }

  double _calculateRealReturnPoints({
    required double initialValue,
    required double finalValue,
    required int yearsPlayed,
    required double realReturnTarget,
  }) {
    if (initialValue <= 0 || yearsPlayed <= 0 || realReturnTarget <= 0) {
      return 0.0;
    }
    final growthFactor = finalValue / initialValue;
    if (growthFactor <= 0) return 0.0;

    final nominalAnnual = pow(growthFactor, 1 / yearsPlayed) - 1;
    final realAnnual = nominalAnnual - _inflationAssumption;
    final ratio = (realAnnual / realReturnTarget).clamp(0.0, 1.0);
    return realReturnWeight * ratio;
  }

  double _calculatePersonaFidelityBonus({
    required String personaId,
    required List<SimulationEvent> events,
  }) {
    final config = _fidelity[personaId];
    if (config == null) return 0.0;

    var badCount = 0;
    var goodCount = 0;
    var adverseEvents = 0;
    var panicCount = 0;

    for (final event in events) {
      if (event.type == SimulationEventType.panicSell) {
        panicCount++;
        final portfolioAtEvent = max(1.0, event.portfolioValueAtEvent);
        final soldRatio = (event.panicSellAmount ?? 0) / portfolioAtEvent;
        final tag = soldRatio >= 0.35 ? 'panic_full' : 'panic_partial';
        if (config.badReactions.contains(tag)) {
          badCount++;
        }
        continue;
      }

      if (_isAdverseHeadline(event.title)) {
        adverseEvents++;
      }
    }

    final ignoreCount = max(0, adverseEvents - panicCount);
    if (config.goodReactions.contains('ignore')) {
      goodCount += ignoreCount;
    }

    if (badCount > 0) return 0.0;
    if (config.minGood <= 0) return fidelityWeight.toDouble();
    final ratio = (goodCount / config.minGood).clamp(0.0, 1.0);
    return fidelityWeight * ratio;
  }

  bool _isAdverseHeadline(String title) {
    final t = title.toLowerCase();
    return t.contains('crash') ||
        t.contains('recession') ||
        t.contains('hike') ||
        t.contains('inflation') ||
        t.contains('stagnation') ||
        t.contains('fear');
  }
}
