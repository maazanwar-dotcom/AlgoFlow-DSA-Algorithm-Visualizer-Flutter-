import 'package:flutter/material.dart';

class Minibar extends StatefulWidget {
  final double height;
  final double width;
  final Color color;
  final Duration animationDuration;
  final Curve animationCurve;
  final Duration colorAnimationDuration;
  final Curve colorAnimationCurve;
  const Minibar({
    super.key,
    required this.height,
    required this.color,
    required this.width,
    this.animationDuration = const Duration(milliseconds: 500),
    this.animationCurve = Curves.easeInOutCubic,
    this.colorAnimationDuration = const Duration(milliseconds: 850),
    this.colorAnimationCurve = Curves.easeInOutSine,
  });

  @override
  State<Minibar> createState() => _MinibarState();
}

class _MinibarState extends State<Minibar> with SingleTickerProviderStateMixin {
  late AnimationController _colorController;
  late Animation<Color?> _colorAnimation;

  @override
  void initState() {
    super.initState();
    _colorController = AnimationController(
      vsync: this,
      duration: widget.colorAnimationDuration,
    );
    _colorAnimation = ColorTween(begin: widget.color, end: widget.color)
        .animate(
          CurvedAnimation(
            parent: _colorController,
            curve: widget.colorAnimationCurve,
          ),
        );
    _colorController.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant Minibar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final colorChanged = oldWidget.color != widget.color;
    final timingChanged =
        oldWidget.colorAnimationDuration != widget.colorAnimationDuration ||
        oldWidget.colorAnimationCurve != widget.colorAnimationCurve;

    if (colorChanged || timingChanged) {
      final beginColor = _colorAnimation.value ?? oldWidget.color;
      _colorController.duration = widget.colorAnimationDuration;
      _colorAnimation = ColorTween(begin: beginColor, end: widget.color)
          .animate(
            CurvedAnimation(
              parent: _colorController,
              curve: widget.colorAnimationCurve,
            ),
          );
      _colorController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, _) {
        final resolvedColor = _colorAnimation.value ?? widget.color;
        return AnimatedContainer(
          duration: widget.animationDuration,
          curve: widget.animationCurve,
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: resolvedColor,
            boxShadow: [
              BoxShadow(
                color: resolvedColor.withOpacity(0.6),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}
