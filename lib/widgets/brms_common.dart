import 'dart:async';

import 'package:flutter/material.dart';
import '../theme/brms_theme.dart';

/// Shared monochrome surface card matching Stitch's rounded-xl bordered container.
class BrmsCard extends StatelessWidget {
  const BrmsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.backgroundColor = BrmsColors.surface,
    this.borderColor = BrmsColors.outlineVariant,
    this.borderRadius = 12,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: borderColor.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Monochrome pill badge for codes, statuses, and tags.
class BrmsBadge extends StatelessWidget {
  const BrmsBadge({
    super.key,
    required this.label,
    this.filled = false,
    this.fontSize = 10,
  });

  final String label;
  final bool filled;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? BrmsColors.primary : BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(5),
        border: filled ? null : Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Text(
        label,
        style: BrmsTheme.mono(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: filled ? BrmsColors.onPrimary : BrmsColors.onSurfaceVariant,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// Thin monochrome horizontal progress bar.
class BrmsProgressBar extends StatelessWidget {
  const BrmsProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.barColor = BrmsColors.barDark,
    this.trackColor = BrmsColors.surfaceContainer,
  });

  final double value;
  final double height;
  final Color barColor;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value.clamp(0.0, 1.0),
        minHeight: height,
        backgroundColor: trackColor,
        valueColor: AlwaysStoppedAnimation<Color>(barColor),
      ),
    );
  }
}

/// Standard monochrome primary or outlined action button.
class BrmsButton extends StatelessWidget {
  const BrmsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.primary = true,
    this.height = 36,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool primary;
  final double height;

  @override
  Widget build(BuildContext context) {
    final bg = primary ? BrmsColors.primary : BrmsColors.surface;
    final fg = primary ? BrmsColors.onPrimary : BrmsColors.onSurface;
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          side: BorderSide(
            color: primary ? BrmsColors.primary : BrmsColors.outlineVariant,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Monochrome error recovery state with a retry action.
class BrmsErrorState extends StatelessWidget {
  const BrmsErrorState({
    super.key,
    required this.title,
    required this.error,
    required this.onRetry,
  });

  final String title;
  final Object error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: BrmsColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BrmsColors.outlineVariant),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline,
            size: 28,
            color: BrmsColors.error,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: BrmsTheme.heading(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Text(
              error.toString(),
              style: BrmsTheme.mono(
                fontSize: 11,
                color: BrmsColors.secondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 14),
          BrmsButton(
            label: 'Retry',
            icon: Icons.refresh,
            primary: false,
            height: 32,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

OverlayEntry? _activeBrmsNoticeEntry;

/// Dismisses any currently visible top-of-app notification.
void dismissBrmsNotice() {
  _activeBrmsNoticeEntry?.remove();
  _activeBrmsNoticeEntry = null;
}

/// Shows a clean monochrome notification banner at the top of the app,
/// rendered in the root [Overlay] so it appears above all screens and dialogs.
void showBrmsNotice(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: BrmsColors.primary,
          behavior: SnackBarBehavior.floating,
          width: 420,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          duration: const Duration(seconds: 2),
        ),
      );
    return;
  }

  dismissBrmsNotice();

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (ctx) => _BrmsTopNotice(
      message: message,
      onDismissed: () {
        if (_activeBrmsNoticeEntry == entry) {
          dismissBrmsNotice();
        }
      },
    ),
  );

  _activeBrmsNoticeEntry = entry;
  overlay.insert(entry);
}

class _BrmsTopNotice extends StatefulWidget {
  const _BrmsTopNotice({
    required this.message,
    required this.onDismissed,
  });

  final String message;
  final VoidCallback onDismissed;

  @override
  State<_BrmsTopNotice> createState() => _BrmsTopNoticeState();
}

class _BrmsTopNoticeState extends State<_BrmsTopNotice>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _autoDismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
    _autoDismissTimer = Timer(
      const Duration(seconds: 3),
      _dismiss,
    );
  }

  Future<void> _dismiss() async {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _autoDismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top + 16;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: IgnorePointer(
        ignoring: false,
        child: Center(
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Material(
                  color: BrmsColors.primary,
                  elevation: 8,
                  shadowColor: Colors.black.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 17,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        InkWell(
                          onTap: _dismiss,
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
