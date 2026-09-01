import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'bloc/password_generator_bloc.dart';
import 'bloc/password_generator_state.dart';
import 'constants/app_colors.dart';
import 'widgets/header_panel.dart';
import 'widgets/password_panel.dart';
import 'widgets/settings_panel.dart';
import 'widgets/visualizer_panel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CipherForge: Secure Keysmith',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        fontFamily: GoogleFonts.nunito().fontFamily,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          tertiary: AppColors.tertiary,
          surface: AppColors.surface,
        ),
      ),
      home: BlocProvider(
        create: (context) => PasswordGeneratorBloc(),
        child: const CipherForgeScreen(),
      ),
    );
  }
}

class CipherForgeScreen extends StatefulWidget {
  const CipherForgeScreen({super.key});

  @override
  State<CipherForgeScreen> createState() => _CipherForgeScreenState();
}

class _CipherForgeScreenState extends State<CipherForgeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _genController;
  late final AnimationController _fadeController;

  PasswordGeneratorBloc get _bloc => context.read<PasswordGeneratorBloc>();

  @override
  void initState() {
    super.initState();
    _genController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    // Start initial animations on load
    _genController.forward(from: 0.0);
    _fadeController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _genController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SelectionArea(
        child: SafeArea(
          child: BlocListener<PasswordGeneratorBloc, PasswordGeneratorState>(
            listenWhen: (previous, current) =>
                previous.passwordResult != current.passwordResult &&
                current.passwordResult.masterPassword.isNotEmpty,
            listener: (context, state) {
              _genController.forward(from: 0.0);
              _fadeController.forward(from: 0.0);
            },
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool isDesktop = constraints.constrainWidth() > 900;

                final settingsPanel =
                    BlocBuilder<PasswordGeneratorBloc, PasswordGeneratorState>(
                      buildWhen: (previous, current) =>
                          previous.length != current.length ||
                          previous.useUppercase != current.useUppercase ||
                          previous.useLowercase != current.useLowercase ||
                          previous.useDigits != current.useDigits ||
                          previous.useSymbols != current.useSymbols ||
                          previous.poolSize != current.poolSize,
                      builder: (context, state) {
                        return SettingsPanel(
                          length: state.length,
                          useUppercase: state.useUppercase,
                          useLowercase: state.useLowercase,
                          useDigits: state.useDigits,
                          useSymbols: state.useSymbols,
                          poolSize: state.poolSize,
                          isDesktop: isDesktop,
                          onLengthChanged: (value) {
                            _bloc.add(UpdateLength(value));
                          },
                          onUppercaseChanged: (value) {
                            _bloc.add(ToggleUppercase(value));
                          },
                          onLowercaseChanged: (value) {
                            _bloc.add(ToggleLowercase(value));
                          },
                          onDigitsChanged: (value) {
                            _bloc.add(ToggleDigits(value));
                          },
                          onSymbolsChanged: (value) {
                            _bloc.add(ToggleSymbols(value));
                          },
                        );
                      },
                    );

                final passwordPanel =
                    BlocBuilder<PasswordGeneratorBloc, PasswordGeneratorState>(
                      buildWhen: (previous, current) =>
                          previous.passwordResult.masterPassword !=
                              current.passwordResult.masterPassword ||
                          previous.strength != current.strength ||
                          previous.crackTime != current.crackTime ||
                          previous.entropy != current.entropy ||
                          previous.isCopied != current.isCopied,
                      builder: (context, state) {
                        return PasswordPanel(
                          password: state.passwordResult.masterPassword,
                          strength: state.strength,
                          strengthColor: state.strengthColor(),
                          crackTime: state.crackTime,
                          entropy: state.entropy,
                          copied: state.isCopied,
                          onCopy: () {
                            _bloc.add(const CopyPassword());
                          },
                          onGenerate: () {
                            _bloc.add(const GeneratePassword());
                          },
                          generateIconController: _genController,
                          fadeInController: _fadeController,
                          isDesktop: isDesktop,
                        );
                      },
                    );

                final visualizer =
                    BlocBuilder<PasswordGeneratorBloc, PasswordGeneratorState>(
                      buildWhen: (previous, current) =>
                          previous.passwordResult != current.passwordResult,
                      builder: (context, state) {
                        return VisualizerPanel(
                          alternativePasswords:
                              state.passwordResult.alternativePasswords,
                          chosenIndices: state.passwordResult.chosenIndices,
                          isDesktop: isDesktop,
                        );
                      },
                    );

                return SingleChildScrollView(
                  primary: false,
                  padding: isDesktop
                      ? const EdgeInsets.all(32.0)
                      : const EdgeInsets.all(16.0),
                  child: RepaintBoundary(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const HeaderPanel(),
                        if (isDesktop)
                          const SizedBox(height: 32)
                        else
                          const SizedBox(height: 16),
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(child: settingsPanel),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    passwordPanel,
                                    const SizedBox(height: 16),
                                    visualizer,
                                  ],
                                ),
                              ),
                            ],
                          )
                        else
                          Column(
                            children: [
                              passwordPanel,
                              const SizedBox(height: 8),
                              settingsPanel,
                              const SizedBox(height: 8),
                              visualizer,
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
