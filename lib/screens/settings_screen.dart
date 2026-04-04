import 'package:algo_visualizer/controllers/app_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(appSettingsControllerProvider.notifier).ensureLoaded();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsControllerProvider);
    final notifier = ref.read(appSettingsControllerProvider.notifier);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0x9E2E243F),
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  Text(
                    'Settings',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 40, height: 40),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'Playback Defaults',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Default Speed'),
                      subtitle: Text('${settings.defaultSpeedMs} ms/step'),
                    ),
                    Slider(
                      value: settings.defaultSpeedMs.toDouble().clamp(
                        150,
                        2000,
                      ),
                      min: 150,
                      max: 2000,
                      divisions: 37,
                      label: '${settings.defaultSpeedMs} ms',
                      onChanged: (value) =>
                          notifier.setDefaultSpeedMs(value.round()),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Auto-play on Visualizer Open'),
                      subtitle: const Text(
                        'Automatically start playback on open',
                      ),
                      value: settings.autoPlayOnOpen,
                      onChanged: notifier.setAutoPlayOnOpen,
                    ),
                    const Divider(height: 30),
                    const Text(
                      'Learning UI',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show Metrics Panel'),
                      subtitle: const Text(
                        'Comparisons, swaps, and current event',
                      ),
                      value: settings.showMetrics,
                      onChanged: notifier.setShowMetrics,
                    ),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Animation Intensity'),
                      subtitle: Text(
                        '${settings.animationScale.toStringAsFixed(1)}x',
                      ),
                    ),
                    Slider(
                      value: settings.animationScale.clamp(0.5, 1.5),
                      min: 0.5,
                      max: 1.5,
                      divisions: 10,
                      label: '${settings.animationScale.toStringAsFixed(1)}x',
                      onChanged: notifier.setAnimationScale,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
