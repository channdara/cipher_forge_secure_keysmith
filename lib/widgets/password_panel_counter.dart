import 'package:flutter/material.dart';

import '../bloc/password_generator.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class PasswordPanelCounter extends StatelessWidget {
  const PasswordPanelCounter({
    super.key,
    required this.isDesktop,
    required this.password,
  });

  final bool isDesktop;
  final String password;

  List<Widget> get _items {
    var uppercaseCount = 0;
    var lowercaseCount = 0;
    var digitCount = 0;
    var symbolCount = 0;

    for (var i = 0; i < password.length; i++) {
      final String c = password[i];
      final int code = c.codeUnitAt(0);
      if (code >= 50 && code <= 57) {
        digitCount++;
      } else if (code >= 65 && code <= 90) {
        uppercaseCount++;
      } else if (PasswordGenerator.symbolChars.contains(c)) {
        symbolCount++;
      } else {
        lowercaseCount++;
      }
    }
    return [
      _Item(
        label: 'Uppercase',
        count: uppercaseCount,
        color: AppColors.charUppercase,
      ),
      _Item(
        label: 'Lowercase',
        count: lowercaseCount,
        color: AppColors.charDefault,
      ),
      _Item(label: 'Number', count: digitCount, color: AppColors.charDigit),
      _Item(label: 'Symbol', count: symbolCount, color: AppColors.charSymbol),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _items,
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_items[0], _items[1]],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [_items[2], _items[3]],
          ),
        ],
      );
    }
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle_rounded, color: color, size: 10),
        const SizedBox(width: 8),
        SelectableText(
          '$label: $count',
          style: AppTextStyles.s14BoldWith(color: color),
        ),
      ],
    );
  }
}
