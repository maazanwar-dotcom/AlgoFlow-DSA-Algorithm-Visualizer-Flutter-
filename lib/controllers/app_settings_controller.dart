import 'package:algo_visualizer/states/app_settings.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final appSettingsControllerProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
      AppSettingsController.new,
    );

class AppSettingsController extends Notifier<AppSettings> {
  static const _keyDefaultSpeedMs = 'defaultSpeedMs';
  static const _keyAutoPlayOnOpen = 'autoPlayOnOpen';
  static const _keyShowMetrics = 'showMetrics';
  static const _keyAnimationScale = 'animationScale';

  bool _isLoaded = false;

  @override
  AppSettings build() {
    return AppSettings.defaults();
  }

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  Future<AppSettings> ensureLoaded() async {
    if (_isLoaded) return state;

    final prefs = await _prefs();
    state = state.copyWith(
      defaultSpeedMs:
          prefs.getInt(_keyDefaultSpeedMs) ??
          AppSettings.defaults().defaultSpeedMs,
      autoPlayOnOpen:
          prefs.getBool(_keyAutoPlayOnOpen) ??
          AppSettings.defaults().autoPlayOnOpen,
      showMetrics:
          prefs.getBool(_keyShowMetrics) ?? AppSettings.defaults().showMetrics,
      animationScale:
          prefs.getDouble(_keyAnimationScale) ??
          AppSettings.defaults().animationScale,
    );
    _isLoaded = true;
    return state;
  }

  Future<void> setDefaultSpeedMs(int value) async {
    state = state.copyWith(defaultSpeedMs: value);
    final prefs = await _prefs();
    await prefs.setInt(_keyDefaultSpeedMs, value);
  }

  Future<void> setAutoPlayOnOpen(bool value) async {
    state = state.copyWith(autoPlayOnOpen: value);
    final prefs = await _prefs();
    await prefs.setBool(_keyAutoPlayOnOpen, value);
  }

  Future<void> setShowMetrics(bool value) async {
    state = state.copyWith(showMetrics: value);
    final prefs = await _prefs();
    await prefs.setBool(_keyShowMetrics, value);
  }

  Future<void> setAnimationScale(double value) async {
    state = state.copyWith(animationScale: value);
    final prefs = await _prefs();
    await prefs.setDouble(_keyAnimationScale, value);
  }
}
