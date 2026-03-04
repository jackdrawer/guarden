import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.g.dart';
import '../providers/bank_account_provider.dart';
import '../providers/web_password_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_tab_fab.dart';
import '../widgets/neumorphic/neumorphic_bottom_nav.dart';
import 'dashboard/dashboard_tab.dart';
import 'bank_accounts/bank_accounts_tab.dart';
import 'subscriptions/subscriptions_tab.dart';
import 'web_passwords/web_passwords_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkNotifications();
    });
  }

  Future<void> _checkNotifications() async {
    final settings =
        ref.read(settingsProvider).valueOrNull ?? SettingsState.initial();

    if (!settings.notificationsEnabled) return;

    final notificationService = ref.read(notificationProvider);
    await notificationService.requestPermissions();

    if (settings.bankRotationNotif) {
      final banks = ref.read(bankAccountProvider).valueOrNull ?? [];
      final webPasswords = ref.read(webPasswordProvider).valueOrNull ?? [];
      await notificationService.checkPasswordExpirations(banks, webPasswords);
    }
  }

  final List<Widget> _tabs = [
    DashboardTab(),
    BankAccountsTab(),
    SubscriptionsTab(),
    WebPasswordsTab(),
  ];

  TabFabConfig? _fabConfigForTab(BuildContext context) {
    switch (_currentIndex) {
      case 1:
        return TabFabConfig(
          icon: Icons.account_balance_rounded,
          tooltip: t.home.add_bank,
          onPressed: () => context.push('/add-bank'),
        );
      case 2:
        return TabFabConfig(
          icon: Icons.subscriptions_rounded,
          tooltip: t.home.add_subscription,
          onPressed: () => context.push('/add-subscription'),
        );
      case 3:
        return TabFabConfig(
          icon: Icons.language_rounded,
          tooltip: t.home.add_web_password,
          onPressed: () => context.push('/add-web-password'),
        );
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fabConfig = _fabConfigForTab(context);

    return Scaffold(
      backgroundColor: AppColors.of(context).background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                'assets/images/app_icon.png',
                width: 32,
                height: 32,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Guarden',
              style: TextStyle(
                color: AppColors.of(context).textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: t.home.settings_tooltip,
            icon: Icon(
              Icons.settings,
              color: AppColors.of(context).textPrimary,
            ),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(index: _currentIndex, children: _tabs),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AnimatedTabFab(
        visible: fabConfig != null,
        config: fabConfig,
      ),
      bottomNavigationBar: NeumorphicBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
