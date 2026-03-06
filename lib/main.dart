import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'services/app_lifecycle_service.dart';
import 'widgets/error_handler.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'services/backup_task_runner.dart';
import 'services/ad_service.dart';

const _enableTelemetry = bool.fromEnvironment(
  'ENABLE_TELEMETRY',
  defaultValue: false,
);

void main() async {
  const sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  if (!_enableTelemetry || sentryDsn.isEmpty) {
    runZonedGuarded(
      () async {
        await _bootstrapApp();
      },
      (error, stackTrace) {
        MonitoringService.captureError(error, stackTrace);
      },
    );
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

  // 1. Kritik senkron işlemler (hızlı)
  LocaleSettings.useDeviceLocale();
  Intl.defaultLocale = LocaleSettings.currentLocale.languageCode;
  await Hive.initFlutter();

  // 2. Ads fire-and-forget (UI'ı engelleme)
  if (AdService.isEnabled) {
    unawaited(MobileAds.instance.initialize());
  }

  // 3. Firebase init (bağımlılık zinciri başı - telemetry önce)
  if (_enableTelemetry) {
    await TelemetryService.instance.init();
  }

  // 4. Background tasks
  if (!kIsWeb) {
    await BackupTaskRunner.init();
  }

  // 4. Bağımsız servisler paralel
  unawaited(
    Future.wait([
      if (_enableTelemetry) ...[
        MonitoringService.init(),
        AnalyticsService.init(),
      ],
    ]).catchError((e, stack) {
      debugPrint('Unawaited init error: $e');
      MonitoringService.captureError(e, stack);
      return [];
    }),
  );

  // 5. UI'ı hemen göster
  runApp(ProviderScope(child: TranslationProvider(child: const GuardenApp())));
}

final isAutofillProvider = StateProvider<bool>((ref) => false);

@pragma('vm:entry-point')
void autofillEntryPoint() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  await Hive.initFlutter();
  // Crash reporting için TelemetryService başlat
  if (_enableTelemetry) {
    await TelemetryService.instance.init();
  }
  runApp(
    ProviderScope(
      overrides: [isAutofillProvider.overrideWith((ref) => true)],
      child: TranslationProvider(child: const GuardenApp()),
    ),
  );
}

class GuardenApp extends ConsumerStatefulWidget {
  const GuardenApp({super.key});

  @override
  ConsumerState<GuardenApp> createState() => _GuardenAppState();
}

class _GuardenAppState extends ConsumerState<GuardenApp> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes and update the authenticated provider
    _syncAuthState();
  }

  void _syncAuthState() {
    // Initial sync
    final authState = ref.read(authProvider).valueOrNull;
    _updateAuthState(authState);

    // Listen for changes
    ref.listenManual(authProvider, (previous, next) {
      final newState = next.valueOrNull;
      _updateAuthState(newState);
    });
  }

  void _updateAuthState(AuthState? state) {
    final isAuthenticated = state == AuthState.authenticated;
    ref.read(isUserAuthenticatedProvider.notifier).state = isAuthenticated;

    // If authenticated, unlock the app
    if (isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(appLifecycleProvider).unlockApp();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return AppLockWrapper(
      child: MaterialApp.router(
        title: t.general.app_name,
        scaffoldMessengerKey: scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        locale: TranslationProvider.of(context).flutterLocale,
        supportedLocales: AppLocaleUtils.supportedLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        themeMode: themeMode,
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
        routerConfig: router,
      ),
    );
  }
}
