import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'services/app_lifecycle_service.dart';
import 'screens/auth/login_screen.dart';
import 'screens/onboarding/welcome_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/onboarding/biometric_optin_screen.dart';
import 'screens/home_screen.dart';
import 'screens/bank_accounts/bank_account_form_screen.dart';
import 'screens/bank_accounts/bank_account_detail_screen.dart';
import 'screens/subscriptions/subscription_form_screen.dart';
import 'screens/subscriptions/subscription_detail_screen.dart';
import 'screens/web_passwords/web_password_form_screen.dart';
import 'screens/web_passwords/web_password_detail_screen.dart';
import 'screens/security_audit_screen.dart';
import 'screens/security/compromised_accounts_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/autofill_screen.dart';
import 'main.dart';

/// A [Listenable] that notifies when auth state changes.
/// Used with GoRouter's `refreshListenable` parameter to trigger redirects
/// without recreating the router instance.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Ref ref) {
    // Listen to auth state changes
    _authSubscription = ref.listen(
      authProvider.select((value) => value.valueOrNull),
      (previous, next) {
        notifyListeners();
      },
    );
    // Listen to app lock state changes
    _lockSubscription = ref.listen(isLockedProvider, (previous, next) {
      notifyListeners();
    });
    // Listen to splash completion
    _splashSubscription = ref.listen(splashCompleterProvider, (previous, next) {
      notifyListeners();
    });
  }

  late final ProviderSubscription<AuthState?> _authSubscription;
  late final ProviderSubscription<bool> _lockSubscription;
  late final ProviderSubscription<bool> _splashSubscription;

  @override
  void dispose() {
    _authSubscription.close();
    _lockSubscription.close();
    _splashSubscription.close();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(ref);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final authStateAsync = ref.read(authProvider);
      final authState = authStateAsync.valueOrNull ?? AuthState.initial;
      final splashCompleted = ref.read(splashCompleterProvider);
      final isAutofill = ref.read(isAutofillProvider);
      final isLocked = ref.read(isLockedProvider);

      if (!splashCompleted) {
        return state.uri.path == '/splash' ? null : '/splash';
      }

      // App lock check - redirect to login if locked and authenticated
      if (isLocked && authState == AuthState.authenticated) {
        return state.uri.path == '/login' ? null : '/login';
      }

      if (authState == AuthState.initial) {
        return null; // Yükleniyor durumu
      }

      final isGoingToLogin = state.uri.path == '/login';
      final isGoingToRecovery = state.uri.path == '/recovery';
      final isGoingToWelcome = state.uri.path == '/welcome';
      final isGoingToOnboard = state.uri.path == '/onboarding';
      final isGoingToOptIn = state.uri.path == '/biometric-optin';
      final isFirstTimeFlow =
          isGoingToWelcome ||
          isGoingToOnboard ||
          isGoingToOptIn ||
          isGoingToRecovery;

      if (authState == AuthState.firstTime && !isFirstTimeFlow) {
        return '/welcome';
      }

      if (authState == AuthState.unauthenticated &&
          !isGoingToLogin &&
          !isGoingToRecovery) {
        return '/login';
      }

      if (authState == AuthState.authenticated) {
        if (isGoingToOptIn) return null;

        if (isGoingToLogin ||
            isGoingToRecovery ||
            isGoingToWelcome ||
            isGoingToOnboard ||
            state.uri.path == '/splash') {
          return isAutofill ? '/autofill' : '/';
        }

        if (isAutofill && state.uri.path != '/autofill') {
          return '/autofill';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) {
          final authStateAsync = ref.read(authProvider);
          final authState = authStateAsync.valueOrNull ?? AuthState.initial;
          if (authState == AuthState.initial) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const HomeScreen();
        },
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/biometric-optin',
        builder: (context, state) => const BiometricOptInScreen(),
      ),
      GoRoute(
        path: '/add-bank',
        builder: (context, state) => const BankAccountFormScreen(),
      ),
      GoRoute(
        path: '/bank-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BankAccountDetailScreen(accountId: id);
        },
      ),
      GoRoute(
        path: '/edit-bank/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BankAccountFormScreen(accountId: id);
        },
      ),
      GoRoute(
        path: '/add-subscription',
        builder: (context, state) => const SubscriptionFormScreen(),
      ),
      GoRoute(
        path: '/subscription-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubscriptionDetailScreen(subscriptionId: id);
        },
      ),
      GoRoute(
        path: '/edit-subscription/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SubscriptionFormScreen(subscriptionId: id);
        },
      ),
      GoRoute(
        path: '/add-web-password',
        builder: (context, state) => const WebPasswordFormScreen(),
      ),
      GoRoute(
        path: '/web-password-detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WebPasswordDetailScreen(webPasswordId: id);
        },
      ),
      GoRoute(
        path: '/edit-web-password/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return WebPasswordFormScreen(webPasswordId: id);
        },
      ),
      GoRoute(
        path: '/security-audit',
        builder: (context, state) => const SecurityAuditScreen(),
      ),
      GoRoute(
        path: '/compromised-accounts',
        builder: (context, state) => const CompromisedAccountsScreen(),
      ),
      GoRoute(path: '/settings', builder: (context, state) => SettingsScreen()),
      GoRoute(
        path: '/autofill',
        builder: (context, state) => const AutofillScreen(),
      ),
    ],
  );
});
