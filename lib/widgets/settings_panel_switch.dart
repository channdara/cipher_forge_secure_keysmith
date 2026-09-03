import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class SettingsPanelSwitch extends StatelessWidget {
  const SettingsPanelSwitch({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.transparent,
      elevation: 0,
      clipBehavior: Clip.hardEdge,
      child: SwitchListTile(
        title: SelectableText(title, style: AppTextStyles.configSwitchTitle),
        subtitle: SelectableText(
          subtitle,
          style: AppTextStyles.configSwitchSubtitle,
        ),
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }
}
