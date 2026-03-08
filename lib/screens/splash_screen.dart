import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/neumorphic/neumorphic_container.dart';
import '../widgets/lottie_animation_widget.dart';
import '../i18n/strings.g.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late final Completer<void> _minimumDisplayCompleter;
  Timer? _minimumDisplayTimer;

  @override
  void initState() {
    super.initState();
    _minimumDisplayCompleter = Completer<void>();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // 1500 -> 1000ms
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    // Paralel çalıştır: animasyon + minimum gösterim süresi
    _minimumDisplayTimer = Timer(const Duration(milliseconds: 800), () {
      if (!_minimumDisplayCompleter.isCompleted) {
        _minimumDisplayCompleter.complete();
      }
    });

    Future.wait([_controller.forward(), _minimumDisplayCompleter.future]).then((
      _,
    ) {
      if (!mounted) return;
      ref.read(splashCompleterProvider.notifier).state = true;
    });
  }

  @override
  void dispose() {
    _minimumDisplayTimer?.cancel();
    if (!_minimumDisplayCompleter.isCompleted) {
      _minimumDisplayCompleter.complete();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: Opacity(
                opacity: _animation.value.clamp(0.0, 1.0),
                child: Hero(
                  tag: 'app-logo',
                  child: NeumorphicContainer(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          t.general.app_short_name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.of(context).textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          t.settings.info.about.offline_title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.of(context).textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const LottieAnimationWidget(
                          animation: GuardenAnimation.lockUnlock,
                          size: 48,
                          repeat: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
