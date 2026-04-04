class AppSettings {
  final int defaultSpeedMs;
  final bool autoPlayOnOpen;
  final bool showMetrics;
  final double animationScale;

  const AppSettings({
    required this.defaultSpeedMs,
    required this.autoPlayOnOpen,
    required this.showMetrics,
    required this.animationScale,
  });

  factory AppSettings.defaults() {
    return const AppSettings(
      defaultSpeedMs: 1000,
      autoPlayOnOpen: false,
      showMetrics: true,
      animationScale: 1.0,
    );
  }

  AppSettings copyWith({
    int? defaultSpeedMs,
    bool? autoPlayOnOpen,
    bool? showMetrics,
    double? animationScale,
  }) {
    return AppSettings(
      defaultSpeedMs: defaultSpeedMs ?? this.defaultSpeedMs,
      autoPlayOnOpen: autoPlayOnOpen ?? this.autoPlayOnOpen,
      showMetrics: showMetrics ?? this.showMetrics,
      animationScale: animationScale ?? this.animationScale,
    );
  }
}
