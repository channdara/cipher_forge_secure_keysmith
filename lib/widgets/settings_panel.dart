import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../bloc/entropy_helper.dart';
import '../bloc/password_generator.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import 'custom_card.dart';
import 'settings_panel_switch.dart';

class SettingsPanel extends StatefulWidget {
  const SettingsPanel({
    super.key,
    required this.length,
    required this.useUppercase,
    required this.useLowercase,
    required this.useDigits,
    required this.useSymbols,
    required this.poolSize,
    required this.isDesktop,
    required this.onLengthChanged,
    required this.onUppercaseChanged,
    required this.onLowercaseChanged,
    required this.onDigitsChanged,
    required this.onSymbolsChanged,
  });

  final int length;
  final bool useUppercase;
  final bool useLowercase;
  final bool useDigits;
  final bool useSymbols;
  final int poolSize;
  final bool isDesktop;
  final ValueChanged<int> onLengthChanged;
  final ValueChanged<bool> onUppercaseChanged;
  final ValueChanged<bool> onLowercaseChanged;
  final ValueChanged<bool> onDigitsChanged;
  final ValueChanged<bool> onSymbolsChanged;

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  static const int _minLength = 6;
  static const int _maxLength = 32;
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  late int _localLength;
  late bool _localUseUppercase;
  late bool _localUseLowercase;
  late bool _localUseDigits;
  late bool _localUseSymbols;

  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _localLength = widget.length;
    _localUseUppercase = widget.useUppercase;
    _localUseLowercase = widget.useLowercase;
    _localUseDigits = widget.useDigits;
    _localUseSymbols = widget.useSymbols;

    _controller = TextEditingController(text: _localLength.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _validateAndClamp();
    }
  }

  void _updateControllerText(String text) {
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _handleTextChanged(String text) {
    final int? value = int.tryParse(text);
    if (value != null && value >= _minLength && value <= _maxLength) {
      if (_localLength != value) {
        setState(() {
          _localLength = value;
        });
        _debounceLengthChanged(value);
      }
    }
  }

  void _validateAndClamp() {
    final String text = _controller.text;
    final int? value = int.tryParse(text);
    if (value == null) {
      _updateControllerText(_localLength.toString());
    } else if (value < _minLength) {
      _updateControllerText(_minLength.toString());
      if (_localLength != _minLength) {
        setState(() {
          _localLength = _minLength;
        });
        _debounceTimer?.cancel();
        widget.onLengthChanged(_minLength);
      }
    } else if (value > _maxLength) {
      _updateControllerText(_maxLength.toString());
      if (_localLength != _maxLength) {
        setState(() {
          _localLength = _maxLength;
        });
        _debounceTimer?.cancel();
        widget.onLengthChanged(_maxLength);
      }
    } else {
      if (_localLength != value) {
        setState(() {
          _localLength = value;
        });
        _debounceTimer?.cancel();
        widget.onLengthChanged(value);
      }
    }
  }

  void _debounceLengthChanged(int newLength) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      if (newLength != widget.length) {
        widget.onLengthChanged(newLength);
      }
    });
  }

  int get _localPoolSize => EntropyHelper.getPoolSize(
    useUppercase: _localUseUppercase,
    useLowercase: _localUseLowercase,
    useDigits: _localUseDigits,
    useSymbols: _localUseSymbols,
  );

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      padding: widget.isDesktop ? 32 : 16,
      borderRadiusTopLeft: widget.isDesktop ? 32 : 8,
      borderRadiusTopRight: widget.isDesktop ? 8 : 8,
      borderRadiusBottomLeft: widget.isDesktop ? 32 : 8,
      borderRadiusBottomRight: widget.isDesktop ? 8 : 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, color: Colors.cyan),
              SizedBox(width: 16),
              SelectableText('Settings', style: AppTextStyles.cardTitle),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SelectableText(
                'Length',
                style: AppTextStyles.configLengthLabel,
              ),
              SizedBox(
                height: 40,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _localLength > _minLength
                          ? () {
                              setState(() {
                                _localLength--;
                                _updateControllerText(_localLength.toString());
                              });
                              widget.onLengthChanged(_localLength);
                            }
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.poolSizeBackground,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          side: BorderSide(color: AppColors.poolSizeBorder),
                        ),
                      ),
                      icon: const Icon(Icons.remove_rounded),
                    ),
                    const SizedBox(width: 4.0),
                    SizedBox(
                      width: 70,
                      height: 40,
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.configLengthValue,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          filled: true,
                          fillColor: AppColors.poolSizeBackground,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: AppColors.poolSizeBorder,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: AppColors.poolSizeBorder,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: _handleTextChanged,
                        onSubmitted: (_) => _validateAndClamp(),
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    IconButton(
                      onPressed: _localLength < _maxLength
                          ? () {
                              setState(() {
                                _localLength++;
                                _updateControllerText(_localLength.toString());
                              });
                              widget.onLengthChanged(_localLength);
                            }
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.poolSizeBackground,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(4),
                            bottomLeft: Radius.circular(4),
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                          side: BorderSide(color: AppColors.poolSizeBorder),
                        ),
                      ),
                      icon: const Icon(Icons.add_rounded),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: AppColors.dividerColor, height: 32),
          SettingsPanelSwitch(
            title: 'Uppercase',
            subtitle: PasswordGenerator.uppercaseChars,
            value: _localUseUppercase,
            onChanged: (v) {
              if (!v &&
                  !_localUseLowercase &&
                  !_localUseDigits &&
                  !_localUseSymbols) {
                return;
              }
              setState(() {
                _localUseUppercase = v;
              });
              widget.onUppercaseChanged(v);
            },
          ),
          SettingsPanelSwitch(
            title: 'Lowercase',
            subtitle: PasswordGenerator.lowercaseChars,
            value: _localUseLowercase,
            onChanged: (v) {
              if (!_localUseUppercase &&
                  !v &&
                  !_localUseDigits &&
                  !_localUseSymbols) {
                return;
              }
              setState(() {
                _localUseLowercase = v;
              });
              widget.onLowercaseChanged(v);
            },
          ),
          SettingsPanelSwitch(
            title: 'Numbers',
            subtitle: PasswordGenerator.digitChars,
            value: _localUseDigits,
            onChanged: (v) {
              if (!_localUseUppercase &&
                  !_localUseLowercase &&
                  !v &&
                  !_localUseSymbols) {
                return;
              }
              setState(() {
                _localUseDigits = v;
              });
              widget.onDigitsChanged(v);
            },
          ),
          SettingsPanelSwitch(
            title: 'Symbols',
            subtitle: PasswordGenerator.symbolChars,
            value: _localUseSymbols,
            onChanged: (v) {
              if (!_localUseUppercase &&
                  !_localUseLowercase &&
                  !_localUseDigits &&
                  !v) {
                return;
              }
              setState(() {
                _localUseSymbols = v;
              });
              widget.onSymbolsChanged(v);
            },
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.poolSizeBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.poolSizeBorder),
            ),
            child: SelectionArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: Text(
                      'Pool Size',
                      style: AppTextStyles.configPoolSizeLabel,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      '$_localPoolSize characters',
                      style: AppTextStyles.configPoolSizeValue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
