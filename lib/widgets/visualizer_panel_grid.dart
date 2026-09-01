import 'package:flutter/material.dart';

import '../bloc/entropy_helper.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class VisualizerPanelGrid extends StatelessWidget {
  const VisualizerPanelGrid({
    super.key,
    required this.alternativePasswords,
    required this.chosenIndices,
  });

  final List<String> alternativePasswords;
  final List<int> chosenIndices;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(alternativePasswords.length, (rowIndex) {
        return VisualizerGridRow(
          key: ValueKey(rowIndex),
          rowIndex: rowIndex,
          password: alternativePasswords[rowIndex],
          chosenIndex: chosenIndices[rowIndex],
        );
      }),
    );
  }
}

class VisualizerGridRow extends StatelessWidget {
  const VisualizerGridRow({
    super.key,
    required this.rowIndex,
    required this.password,
    required this.chosenIndex,
  });

  final int rowIndex;
  final String password;
  final int chosenIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${(rowIndex + 1).toString().padLeft(2, '0')}',
              textAlign: TextAlign.end,
              style: AppTextStyles.visualizerRowIndex,
            ),
          ),
          const SizedBox(width: 6),
          ...List.generate(password.length, (charIndex) {
            final String char = password[charIndex];
            final isChosen = charIndex == chosenIndex;
            return VisualizerGridCell(
              key: ValueKey(charIndex),
              char: char,
              isChosen: isChosen,
              charColor: EntropyHelper.characterColor(char),
            );
          }),
        ],
      ),
    );
  }
}

class VisualizerGridCell extends StatelessWidget {
  const VisualizerGridCell({
    super.key,
    required this.char,
    required this.isChosen,
    required this.charColor,
  });

  final String char;
  final bool isChosen;
  final Color charColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: isChosen ? AppColors.secondary : AppColors.unchosenBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isChosen ? AppColors.chosenBorder : AppColors.unchosenBorder,
        ),
      ),
      child: Center(
        child: Text(
          char,
          style: AppTextStyles.visualizerGridChar(
            isChosen: isChosen,
            charColor: charColor,
          ),
        ),
      ),
    );
  }
}
