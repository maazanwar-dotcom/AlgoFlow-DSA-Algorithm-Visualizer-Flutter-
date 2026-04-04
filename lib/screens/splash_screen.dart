import 'package:algo_visualizer/controllers/app_settings_controller.dart';
import 'package:algo_visualizer/controllers/continue_learning_controller.dart';
import 'package:algo_visualizer/controllers/saved_algorithms_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Duration _minSplashDuration = Duration(milliseconds: 4000);

  bool _hasNavigated = false;
  Object? _bootstrapError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _bootstrapAndNavigate();
    });
  }

  Future<void> _bootstrapAndNavigate() async {
    final startedAt = DateTime.now();
    if (_bootstrapError != null) {
      setState(() {
        _bootstrapError = null;
      });
    }

    try {
      await Future.wait<void>([
        ref
            .read(appSettingsControllerProvider.notifier)
            .ensureLoaded()
            .then((_) {}),
        ref.read(savedAlgorithmsControllerProvider.notifier).ensureLoaded(),
        ref.read(continueLearningControllerProvider.notifier).ensureLoaded(),
      ]);

      final elapsed = DateTime.now().difference(startedAt);
      if (elapsed < _minSplashDuration) {
        await Future<void>.delayed(_minSplashDuration - elapsed);
      }

      if (!mounted || _hasNavigated) return;
      _hasNavigated = true;
      Navigator.pushReplacementNamed(context, '/home-screen');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _bootstrapError = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0A18),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double maxLogoWidth = constraints.maxWidth * 0.94;
            final double maxLogoHeight = constraints.maxHeight * 0.84;

            return Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: maxLogoWidth,
                      maxHeight: maxLogoHeight,
                    ),
                    child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: _bootstrapError == null
                        ? const SizedBox(
                            width: 34,
                            height: 34,
                            child: CircularProgressIndicator(
                              strokeWidth: 3.2,
                              valueColor: AlwaysStoppedAnimation(
                                Colors.purpleAccent,
                              ),
                              backgroundColor: Colors.white24,
                            ),
                          )
                        : Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xAA2A1111),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.redAccent),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                TextButton(
                                  onPressed: _bootstrapAndNavigate,
                                  child: const Text('Retry initialization'),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
