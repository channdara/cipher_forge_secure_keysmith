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
  });

  final List<String> alternativePasswords;
  final List<int> chosenIndices;
  final bool isDesktop;

  @override
  State<VisualizerPanel> createState() => _VisualizerPanelState();
}

class _VisualizerPanelState extends State<VisualizerPanel> {
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
          SelectableText(
            'The matrix generates $len intermediate keys of length $len. One random character from each row forms the master key. The violet cells represent characters selected for the Master Key',
            style: AppTextStyles.visualizerInsight,
          ),
          const SizedBox(height: 14),
          RepaintBoundary(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
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
