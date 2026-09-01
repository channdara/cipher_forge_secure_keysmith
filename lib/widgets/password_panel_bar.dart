import 'package:flutter/material.dart';

import '../bloc/entropy_helper.dart';
import '../constants/app_colors.dart';

class PasswordPanelBar extends StatelessWidget {
  const PasswordPanelBar({
    super.key,
    required this.strength,
    required this.color,
  });

  final PasswordStrength strength;
  final Color color;

  int get _active {
    return switch (strength) {
      PasswordStrength.none => 0,
      PasswordStrength.veryWeak => 1,
      PasswordStrength.weak => 2,
      PasswordStrength.medium => 3,
      PasswordStrength.strong => 4,
      PasswordStrength.veryStrong => 5,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 3,
              right: index == 4 ? 0 : 3,
            ),
            decoration: BoxDecoration(
              color: index < _active ? color : AppColors.barBackground,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
