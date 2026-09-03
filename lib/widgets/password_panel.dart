import 'package:flutter/material.dart';

import '../bloc/entropy_helper.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'custom_card.dart';
import 'password_panel_bar.dart';
import 'password_panel_counter.dart';

class PasswordPanel extends StatelessWidget {
  const PasswordPanel({
    super.key,
    required this.password,
    required this.strength,
    required this.strengthColor,
    required this.crackTime,
    required this.entropy,
    required this.copied,
    required this.onCopy,
    required this.onGenerate,
    required this.generateIconController,
    required this.fadeInController,
    required this.isDesktop,
  });

  final String password;
  final PasswordStrength strength;
  final Color strengthColor;
  final String crackTime;
  final double entropy;
  final bool copied;
  final VoidCallback onCopy;
  final VoidCallback onGenerate;
  final AnimationController generateIconController;
  final AnimationController fadeInController;
  final bool isDesktop;

  bool get _hasPassword => password.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: isDesktop ? 32 : 16,
      borderRadiusTopLeft: isDesktop ? 8 : 32,
      borderRadiusTopRight: isDesktop ? 32 : 32,
      borderRadiusBottomLeft: isDesktop ? 8 : 8,
      borderRadiusBottomRight: isDesktop ? 8 : 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.vpn_key_rounded, color: Colors.cyan),
                  SizedBox(width: 16),
                  SelectableText('Password', style: AppTextStyles.cardTitle),
                ],
              ),
              if (_hasPassword)
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: strengthColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    child: SelectableText(
                      EntropyHelper.getStrengthLabel(strength),
                      style: AppTextStyles.outputStrengthBadge(strengthColor),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.innerCardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.innerCardBorder),
            ),
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FadeTransition(
                  opacity: fadeInController,
                  child: !_hasPassword
                      ? const SelectableText(
                          'Set options to generate',
                          style: AppTextStyles.outputPlaceholder,
                          textAlign: TextAlign.center,
                        )
                      : Text.rich(
                          TextSpan(
                            children: password.split('').map((char) {
                              return TextSpan(
                                text: char,
                                style: AppTextStyles.outputPasswordChar(
                                  fontSize: isDesktop ? 20 : 16,
                                  charColor: EntropyHelper.characterColor(char),
                                ),
                              );
                            }).toList(),
                          ),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _hasPassword ? onCopy : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: copied
                        ? Colors.green
                        : AppColors.copyButtonBackground,
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    copied ? Icons.check_rounded : Icons.copy_rounded,
                    size: 16,
                  ),
                  label: Text(copied ? 'Copied!' : 'Copy to Clipboard'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onGenerate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                icon: RotationTransition(
                  turns: generateIconController,
                  child: const Icon(Icons.refresh_rounded, size: 16),
                ),
                label: const Text('Refresh'),
              ),
            ],
          ),
          if (_hasPassword) ...[
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  'Entropy: ~${entropy.toStringAsFixed(0)} bits',
                  style: AppTextStyles.outputEntropy,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SelectableText(
                    'Crack Time: ~$crackTime',
                    style: AppTextStyles.outputCrackTime,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            PasswordPanelBar(strength: strength, color: strengthColor),
            const SizedBox(height: 24),
            PasswordPanelCounter(isDesktop: isDesktop, password: password),
          ],
        ],
      ),
    );
  }
}
