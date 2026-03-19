import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:start_hack_2026/core/constants/game_theme_constants.dart';
import 'package:start_hack_2026/core/constants/spacing_constants.dart';
import 'package:start_hack_2026/core/widgets/game_button.dart';

class SimulationDebugScreen extends StatelessWidget {
  const SimulationDebugScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              GameThemeConstants.creamBackground,
              Color(0xFFF5EDE0),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(SpacingConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Simulation Debug',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: SpacingConstants.xl),
              GameButton(
                label: 'Show Win Screen',
                icon: Icons.emoji_events,
                onPressed: () => context.pushReplacement('/game-won'),
                variant: GameButtonVariant.success,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
