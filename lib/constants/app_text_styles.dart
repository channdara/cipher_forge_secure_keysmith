import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Visualizer Card Text Styles
  static const TextStyle visualizerRowIndex = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.blueGrey,
  );

  static TextStyle visualizerGridChar({
    required bool isChosen,
    required Color charColor,
  }) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 12,
      color: isChosen ? Colors.white : charColor,
    );
  }

  static const TextStyle cardTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle visualizerInsight = TextStyle(
    fontSize: 14,
    color: AppColors.insightsSubtitle,
  );

  static const TextStyle visualizerLegend = TextStyle(
    color: AppColors.legendText,
    fontSize: 12,
  );

  // Output Card Text Styles
  static TextStyle outputStrengthBadge(Color col) {
    return TextStyle(color: col, fontSize: 12, fontWeight: FontWeight.bold);
  }

  static const TextStyle outputPlaceholder = TextStyle(
    color: Colors.grey,
    fontStyle: FontStyle.italic,
  );

  static TextStyle outputPasswordChar({
    required double fontSize,
    required Color charColor,
  }) {
    return TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      color: charColor,
    );
  }

  static const TextStyle outputEntropy = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle outputCrackTime = TextStyle(
    color: AppColors.tertiary,
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  // Header Text Styles
  static const TextStyle headerTitle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    letterSpacing: 3.0,
    color: Colors.white,
  );

  static const TextStyle headerSubtitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    letterSpacing: 7.85,
  );

  static const TextStyle headerDescription = TextStyle(
    color: AppColors.insightsSubtitle,
    fontSize: 16,
  );

  // Configuration Panel Text Styles
  static const TextStyle configLengthLabel = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static const TextStyle configLengthValue = TextStyle(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static const TextStyle configPoolSizeLabel = TextStyle(
    color: AppColors.poolSizeLabel,
    fontSize: 14,
  );

  static const TextStyle configPoolSizeValue = TextStyle(
    fontWeight: FontWeight.bold,
    color: AppColors.tertiary,
  );

  static const TextStyle configSwitchTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle configSwitchSubtitle = TextStyle(
    fontSize: 10,
    color: AppColors.legendText,
  );

  static TextStyle s14BoldWith({Color? color}) {
    return TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color);
  }
}
