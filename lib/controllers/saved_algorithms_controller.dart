import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final savedAlgorithmsControllerProvider =
    NotifierProvider<SavedAlgorithmsController, Set<String>>(
      SavedAlgorithmsController.new,
    );

class SavedAlgorithmsController extends Notifier<Set<String>> {
  static const _savedAlgorithmsKey = 'saved.algorithms.names';
  bool _loaded = false;

  @override
  Set<String> build() {
    return <String>{};
  }

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final names = prefs.getStringList(_savedAlgorithmsKey) ?? const <String>[];
    state = names.toSet();
    _loaded = true;
  }

  bool isSaved(String algorithmName) {
    return state.contains(algorithmName);
  }

  Future<void> toggleSaved(String algorithmName) async {
    await ensureLoaded();
    final next = Set<String>.from(state);
    if (next.contains(algorithmName)) {
      next.remove(algorithmName);
    } else {
      next.add(algorithmName);
    }
    state = next;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedAlgorithmsKey, next.toList()..sort());
  }
}
