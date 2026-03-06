import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum NativeIllustration { vault, lockUnlock, deleteItem }

class NativeAnimatedIllustration extends StatefulWidget {
  final NativeIllustration illustration;
  final double size;
  final Color? colorOverride;

  const NativeAnimatedIllustration({
    super.key,
    required this.illustration,
    required this.size,
    this.colorOverride,
  });

  @override
  State<NativeAnimatedIllustration> createState() =>
      _NativeAnimatedIllustrationState();
}

class _NativeAnimatedIllustrationState extends State<NativeAnimatedIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _durationFor(widget.illustration),
    )..repeat();
  }

  @override
  void didUpdateWidget(covariant NativeAnimatedIllustration oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.illustration != widget.illustration) {
      _controller
        ..duration = _durationFor(widget.illustration)
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Duration _durationFor(NativeIllustration illustration) {
    switch (illustration) {
      case NativeIllustration.vault:
        return const Duration(milliseconds: 2600);
      case NativeIllustration.lockUnlock:
        return const Duration(milliseconds: 2200);
      case NativeIllustration.deleteItem:
        return const Duration(milliseconds: 1800);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accent = widget.colorOverride ?? colors.primaryAccent;
    final surface = colors.surface;
    final detail =
        ThemeData.estimateBrightnessForColor(accent) == Brightness.dark
        ? Colors.white
        : const Color(0xFF2D3748);

    return SizedBox(
      key: ValueKey<String>('native-${widget.illustration.name}'),
      width: widget.size,
      height: widget.size,
      child: FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: 100,
          height: 100,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return switch (widget.illustration) {
                NativeIllustration.vault => _VaultIllustration(
                  progress: _controller.value,
                  accent: accent,
                  surface: surface,
                  detail: detail,
                ),
                NativeIllustration.lockUnlock => _LockUnlockIllustration(
                  progress: _controller.value,
                  accent: accent,
                  surface: surface,
                  detail: detail,
                ),
                NativeIllustration.deleteItem => _DeleteIllustration(
                  progress: _controller.value,
                  accent: accent,
                  surface: surface,
                  detail: detail,
                ),
              };
            },
          ),
        ),
      ),
    );
  }
}

class _VaultIllustration extends StatelessWidget {
  final double progress;
  final Color accent;
  final Color surface;
  final Color detail;

  const _VaultIllustration({
    required this.progress,
    required this.accent,
    required this.surface,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final bob = math.sin(progress * math.pi * 2) * 6;
    final tilt = math.sin(progress * math.pi * 2) * 0.035;
    final wheelTurn = progress * math.pi * 2;

    return Transform.translate(
      offset: Offset(0, bob),
      child: Transform.rotate(
        angle: tilt,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.2),
                    accent.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accent.withValues(alpha: 0.92),
                    accent.withValues(alpha: 0.72),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.28),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: surface.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),
            Transform.rotate(
              angle: wheelTurn,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: detail.withValues(alpha: 0.9),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    for (final offset in const [
                      Offset(0, -7),
                      Offset(7, 0),
                      Offset(0, 7),
                      Offset(-7, 0),
                    ])
                      Transform.translate(
                        offset: offset,
                        child: Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: accent,
                          ),
                        ),
                      ),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 17,
              top: 17,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surface.withValues(alpha: 0.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LockUnlockIllustration extends StatelessWidget {
  final double progress;
  final Color accent;
  final Color surface;
  final Color detail;

  const _LockUnlockIllustration({
    required this.progress,
    required this.accent,
    required this.surface,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final pulse = 0.96 + (math.sin(progress * math.pi * 2) * 0.04);
    final unlockAmount = Curves.easeInOut.transform(
      ((math.sin(progress * math.pi * 2 - math.pi / 2) + 1) / 2),
    );
    final shackleAngle = -unlockAmount * 0.72;
    final shackleLift = -unlockAmount * 5;

    return Transform.scale(
      scale: pulse,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withValues(alpha: 0.18),
                  accent.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
          Transform.translate(
            offset: const Offset(0, 10),
            child: Container(
              width: 58,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    accent.withValues(alpha: 0.96),
                    accent.withValues(alpha: 0.72),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.26),
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: detail.withValues(alpha: 0.92),
                      ),
                    ),
                    Container(
                      width: 4,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(99),
                        color: detail.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(10 * unlockAmount, shackleLift - 7),
            child: Transform.rotate(
              angle: shackleAngle,
              alignment: const Alignment(-0.9, 1),
              child: Container(
                width: 34,
                height: 30,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: accent.withValues(alpha: 0.92),
                    width: 6,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  color: Colors.transparent,
                ),
              ),
            ),
          ),
          Positioned(
            top: 11,
            right: 15,
            child: Opacity(
              opacity: unlockAmount,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: surface.withValues(alpha: 0.7),
                ),
                child: Icon(Icons.check_rounded, size: 10, color: accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteIllustration extends StatelessWidget {
  final double progress;
  final Color accent;
  final Color surface;
  final Color detail;

  const _DeleteIllustration({
    required this.progress,
    required this.accent,
    required this.surface,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final shake = math.sin(progress * math.pi * 4) * 3;
    final lidLift = Curves.easeInOut.transform(
      ((math.sin(progress * math.pi * 2) + 1) / 2),
    );

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                accent.withValues(alpha: 0.15),
                accent.withValues(alpha: 0.02),
              ],
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(shake, 8),
          child: Stack(
            alignment: Alignment.topCenter,
            children: [
              Transform.translate(
                offset: Offset(0, -2 - (lidLift * 6)),
                child: Transform.rotate(
                  angle: -0.1 - (lidLift * 0.12),
                  child: Container(
                    width: 46,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Container(
                        width: 14,
                        height: 3,
                        decoration: BoxDecoration(
                          color: detail.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: surface.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 3,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: detail.withValues(alpha: 0.84),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
