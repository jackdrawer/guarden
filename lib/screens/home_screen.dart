import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../i18n/strings.g.dart';
import '../providers/auth_provider.dart';
import '../providers/bank_account_provider.dart';
import '../providers/web_password_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_colors.dart';
import '../widgets/animated_tab_fab.dart';
import '../widgets/lottie_animation_widget.dart';
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
      _checkMasterPasswordReminder();
    });
  }

  Future<void> _checkMasterPasswordReminder() async {
    final settings =
        ref.read(settingsProvider).valueOrNull ?? SettingsState.initial();

    // Yalnızca biyometrik ile giriş yapılıyorsa ve ayar açıksa mantıklı
    if (!settings.biometricLogin) return;

    final lastEntry = settings.lastMasterPasswordEntry;
    if (lastEntry == null) return;

    final daysPassed = DateTime.now().difference(lastEntry).inDays;

    // 14 Günden fazla geçmişse hatırlat (Test için && !kDebugMode silinebilir veya daysPassed 0 verilebilir ama biz 14 gün bırakıyoruz. )
    if (daysPassed >= 14) {
      _showMasterPasswordReminderDialog();
    }
  }

  void _showMasterPasswordReminderDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.of(context).background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.of(context).neumorphicShadows,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.security_rounded,
                size: 48,
                color: AppColors.of(context).primaryAccent,
              ),
              const SizedBox(height: 8),
              const LottieAnimationWidget(
                animation: GuardenAnimation.shieldSecure,
                size: 72,
                repeat: false,
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/security_key.png',
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t.settings.reminders.master_password_title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.of(context).textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                t.settings.reminders.master_password_desc,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.of(context).textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.of(ctx).pop(), // Kapat ve daha sonra sor
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.settings.reminders.remind_later,
                        style: TextStyle(
                          color: AppColors.of(context).textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _testMasterPassword();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.of(context).primaryAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(t.settings.reminders.test_it),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _testMasterPassword() async {
    final controller = TextEditingController();
    bool obscure = true;
    String? error;

    final success = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.of(context).background,
              title: Text(
                t.settings.reminders.enter_master_password,
                style: TextStyle(color: AppColors.of(context).textPrimary),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (error != null) ...[
                    Text(
                      error!,
                      style: TextStyle(
                        color: AppColors.of(context).error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextField(
                    controller: controller,
                    obscureText: obscure,
                    style: TextStyle(color: AppColors.of(context).textPrimary),
                    decoration: InputDecoration(
                      hintText: t.settings.reminders.master_password_hint,
                      hintStyle: TextStyle(
                        color: AppColors.of(
                          context,
                        ).textSecondary.withValues(alpha: 0.5),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                          color: AppColors.of(context).textSecondary,
                        ),
                        onPressed: () => setState(() => obscure = !obscure),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.of(
                            context,
                          ).textSecondary.withValues(alpha: 0.2),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppColors.of(context).primaryAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(
                    t.general.cancel,
                    style: TextStyle(
                      color: AppColors.of(context).textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final authNotifier = ref.read(authProvider.notifier);
                    final isCorrect = await authNotifier.verifyMasterPassword(
                      controller.text,
                    );
                    if (isCorrect) {
                      if (ctx.mounted) Navigator.pop(ctx, true);
                    } else {
                      setState(() => error = t.settings.alerts.wrong_password);
                      controller.clear();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.of(context).primaryAccent,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(t.settings.reminders.test_it),
                ),
              ],
            );
          },
        );
      },
    );

    if (success == true) {
      await ref
          .read(settingsProvider.notifier)
          .setLastMasterPasswordEntry(DateTime.now());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.settings.alerts.correct_password),
            backgroundColor: AppColors.of(context).success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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

  static const List<Widget> _tabs = [
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
            Flexible(
              child: Text(
                t.general.app_short_name,
                style: TextStyle(
                  color: AppColors.of(context).textPrimary,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
