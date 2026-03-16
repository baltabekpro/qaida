import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';

class BookmarkButton extends StatefulWidget {
  const BookmarkButton({
    super.key,
    required this.saved,
    required this.onPressed,
  });

  final bool saved;
  final VoidCallback onPressed;

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void initState() {
    super.initState();
    if (widget.saved) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant BookmarkButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.saved && !_controller.isAnimating) {
      _controller.repeat();
    }
    if (!widget.saved && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 42,
      width: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.saved)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final value = Curves.easeOut.transform(_controller.value);
                return Transform.scale(
                  scale: 0.72 + (value * 0.78),
                  child: Opacity(
                    opacity: (1 - value) * 0.3,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.18),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.saved
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : (isDark
                        ? AppColors.darkSurfaceSoft
                        : Colors.white.withValues(alpha: 0.86)),
              border: Border.all(
                color: widget.saved
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : (isDark
                          ? AppColors.darkTextSecondary.withValues(alpha: 0.14)
                          : AppColors.borderSoft),
              ),
              boxShadow: widget.saved
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.16),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: IconButton(
              onPressed: widget.onPressed,
              icon: Icon(
                widget.saved
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: widget.saved
                    ? AppColors.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
