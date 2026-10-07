import 'package:flutter/material.dart';

import '../constants/app_text_styles.dart';
import 'custom_card.dart';
import 'visualizer_panel_grid.dart';

class VisualizerPanel extends StatefulWidget {
  const VisualizerPanel({
    super.key,
    required this.alternativePasswords,
    required this.chosenIndices,
    required this.isDesktop,
    required this.activePoolCount,
  });

  final List<String> alternativePasswords;
  final List<int> chosenIndices;
  final bool isDesktop;
  final int activePoolCount;

  @override
  State<VisualizerPanel> createState() => _VisualizerPanelState();
}

class _VisualizerPanelState extends State<VisualizerPanel> {
  String _insight(int length) {
    final int classes = widget.activePoolCount;
    if (classes <= 1) {
      return 'The matrix builds $length intermediate keys of length $length. '
          'One character is taken from a random position in each key. '
          'Violet cells are the characters in the password.';
    }
    return 'The matrix builds $length intermediate keys of length $length. '
        'Each key includes at least one character from every selected class, '
        'then is shuffled. One character is taken from each key. '
        '$classes keys are assigned to those classes, and the character taken '
        'from an assigned key is chosen only from that class. '
        'Every other key contributes a character from any position. '
        'Violet cells are the characters in the password.';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.alternativePasswords.isEmpty) {
      return const SizedBox();
    }

    final Widget grid = VisualizerPanelGrid(
      alternativePasswords: widget.alternativePasswords,
      chosenIndices: widget.chosenIndices,
    );

    final int len = widget.alternativePasswords.length;
    return CustomCard(
      padding: widget.isDesktop ? 32 : 16,
      borderRadiusTopLeft: widget.isDesktop ? 8 : 8,
      borderRadiusTopRight: widget.isDesktop ? 8 : 8,
      borderRadiusBottomLeft: widget.isDesktop ? 32 : 32,
      borderRadiusBottomRight: widget.isDesktop ? 32 : 32,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.grid_view_rounded, color: Colors.cyan),
              SizedBox(width: 16),
              SelectableText(
                'Algorithm Insights',
                style: AppTextStyles.cardTitle,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(_insight(len), style: AppTextStyles.visualizerInsight),
          const SizedBox(height: 14),
          RepaintBoundary(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              child: grid,
            ),
          ),
        ],
      ),
    );
  }
}
