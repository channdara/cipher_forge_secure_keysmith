import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class HeaderPanel extends StatelessWidget {
  const HeaderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Icon(
                  Icons.admin_panel_settings_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CIPHERFORGE', style: AppTextStyles.headerTitle),
                  Text('SECURE KEYSMITH', style: AppTextStyles.headerSubtitle),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text(
          'A cryptographically secure password generator based on the customized matrix algorithm with cryptographically secure random number generation to construct extremely secure passwords.',
          style: AppTextStyles.headerDescription,
        ),
      ],
    );
  }
}
