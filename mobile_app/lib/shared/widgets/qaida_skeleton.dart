import 'package:flutter/material.dart';

class QaidaSkeleton extends StatefulWidget {
  const QaidaSkeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  @override
  State<QaidaSkeleton> createState() => _QaidaSkeletonState();
}

class _QaidaSkeletonState extends State<QaidaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor =
        widget.baseColor ??
        (isDark ? const Color(0xFF172233) : const Color(0xFFE8EEF7));
    final highlightColor =
        widget.highlightColor ??
        (isDark ? const Color(0xFF22324A) : const Color(0xFFF7FAFF));

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                begin: Alignment(-1.4 + (value * 2.8), -0.2),
                end: Alignment(-0.4 + (value * 2.8), 0.2),
                colors: [baseColor, highlightColor, baseColor],
                stops: const [0.15, 0.5, 0.85],
              ),
            ),
          );
        },
      ),
    );
  }
}
