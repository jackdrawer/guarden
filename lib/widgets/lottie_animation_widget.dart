import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'native_animated_illustration.dart';

/// Predefined animation assets for consistent usage across the app.
enum GuardenAnimation {
  fingerprintScan('assets/animations/fingerprint_scan.json'),
  shieldSecure('assets/animations/shield_secure.json'),
  cloudSync('assets/animations/cloud_sync.json'),
  lockUnlock('assets/animations/lock_unlock.json'),
  successCelebration('assets/animations/success_celebration.json'),
  deleteItem('assets/animations/delete_item.json'),
  emptyStateVault('assets/animations/empty_state_vault.json');

  final String path;
  const GuardenAnimation(this.path);
}

/// A reusable Lottie animation widget with Guarden's accent color support.
class LottieAnimationWidget extends StatelessWidget {
  final GuardenAnimation animation;
  final double size;
  final bool repeat;
  final Color? colorOverride;

  const LottieAnimationWidget({
    super.key,
    required this.animation,
    this.size = 120,
    this.repeat = true,
    this.colorOverride,
  });

  @override
  Widget build(BuildContext context) {
    final nativeIllustration = _nativeIllustration;
    if (nativeIllustration != null) {
      return NativeAnimatedIllustration(
        illustration: nativeIllustration,
        size: size,
        colorOverride: colorOverride,
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        animation.path,
        width: size,
        height: size,
        repeat: repeat,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        frameRate: FrameRate.max,
        addRepaintBoundary:
            true, // Prevents full screen repaints, helpful for web
        delegates: colorOverride != null
            ? LottieDelegates(
                values: [
                  ValueDelegate.color(const ['**'], value: colorOverride),
                ],
              )
            : null,
        errorBuilder: (context, error, stackTrace) {
          if (kDebugMode) {
            debugPrint('Lottie load error for ${animation.path}: $error');
          }
          return Center(
            child: Icon(
              _fallbackIcon,
              size: size * 0.45,
              color: colorOverride ?? const Color(0xFFF19754),
            ),
          );
        },
      ),
    );
  }

  NativeIllustration? get _nativeIllustration {
    switch (animation) {
      case GuardenAnimation.lockUnlock:
        return NativeIllustration.lockUnlock;
      case GuardenAnimation.deleteItem:
        return NativeIllustration.deleteItem;
      case GuardenAnimation.emptyStateVault:
        return NativeIllustration.vault;
      case GuardenAnimation.fingerprintScan:
      case GuardenAnimation.shieldSecure:
      case GuardenAnimation.cloudSync:
      case GuardenAnimation.successCelebration:
        return null;
    }
  }

  IconData get _fallbackIcon {
    switch (animation) {
      case GuardenAnimation.fingerprintScan:
        return Icons.fingerprint;
      case GuardenAnimation.shieldSecure:
        return Icons.shield;
      case GuardenAnimation.cloudSync:
        return Icons.cloud_sync;
      case GuardenAnimation.lockUnlock:
        return Icons.lock_open;
      case GuardenAnimation.successCelebration:
        return Icons.celebration_rounded;
      case GuardenAnimation.deleteItem:
        return Icons.delete_sweep_rounded;
      case GuardenAnimation.emptyStateVault:
        return Icons.inventory_2_outlined;
    }
  }
}
