import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_colors.dart';
import 'i18n/strings.g.dart';
import 'services/telemetry_service.dart';
import 'services/monitoring_service.dart';
import 'services/analytics_service.dart';
import 'widgets/error_handler.dart';

void main() async {
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  if (sentryDsn.isEmpty) {
    await _bootstrapApp();
    return;
  }

  await SentryFlutter.init((options) {
    options.dsn = sentryDsn;
    options.environment = const bool.fromEnvironment('dart.vm.product')
        ? 'production'
        : 'development';
    options.tracesSampleRate = 0.2;
    options.beforeSend = MonitoringService.scrubPII;
  }, appRunner: _bootstrapApp);
}

Future<void> _bootstrapApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
  }

  LocaleSettings.useDeviceLocale();

  await Hive.initFlutter();

  await TelemetryService.instance.init();
  await MonitoringService.init();
  await AnalyticsService.init();

  // Run app in error zone to capture uncaught async errors
  runZonedGuarded(
    () {
      runApp(
        ProviderScope(child: TranslationProvider(child: const GuardenApp())),
      );
    },
    (error, stackTrace) {
      MonitoringService.captureError(error, stackTrace);
    },
  );
}

final isAutofillProvider = StateProvider<bool>((ref) => false);

@pragma('vm:entry-point')
void autofillEntryPoint() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ProviderScope(
      overrides: [isAutofillProvider.overrideWith((ref) => true)],
      child: TranslationProvider(child: const GuardenApp()),
    ),
  );
}

class GuardenApp extends ConsumerWidget {
  const GuardenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Guarden Password Manager',
      scaffoldMessengerKey: scaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFEF8539),
          surface: const Color(0xFFE0E5EC),
        ),
        useMaterial3: true,
        extensions: [AppColors.light],
      ),
      darkTheme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color(0xFFEF8539),
          surface: const Color(0xFF1E1E24),
        ),
        useMaterial3: true,
        extensions: [AppColors.dark],
      ),
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
