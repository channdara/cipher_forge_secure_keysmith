import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
    required this.padding,
    required this.borderRadiusTopLeft,
    required this.borderRadiusTopRight,
    required this.borderRadiusBottomLeft,
    required this.borderRadiusBottomRight,
  });

  final Widget child;
  final double padding;
  final double borderRadiusTopLeft;
  final double borderRadiusTopRight;
  final double borderRadiusBottomLeft;
  final double borderRadiusBottomRight;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: AppColors.glassCardBackground,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadiusTopLeft),
          topRight: Radius.circular(borderRadiusTopRight),
          bottomLeft: Radius.circular(borderRadiusBottomLeft),
          bottomRight: Radius.circular(borderRadiusBottomRight),
        ),
      ),
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}
