import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../providers/bank_account_provider.dart';
import '../../services/logo_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_empty_state.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';
import '../../widgets/ads/native_ad_widget.dart';
import '../../i18n/strings.g.dart';

class BankAccountsTab extends ConsumerWidget {
  const BankAccountsTab({super.key});

  void _handleDelete(BuildContext context, WidgetRef ref, bank) {
    HapticFeedback.mediumImpact();
    final deleted = ref.read(bankAccountProvider.notifier).deleteBankAccount(
      bank.id,
    );
    if (deleted == null) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(t.general.deleted_label(label: bank.bankName)),
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: t.general.undo,
            onPressed: () {
              ref
                  .read(bankAccountProvider.notifier)
                  .restoreBankAccount(deleted);
            },
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bankAccounts = ref.watch(bankAccountProvider).valueOrNull ?? [];
    final logoService = ref.watch(logoServiceProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.bank_accounts.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: bankAccounts.isEmpty
                ? AnimatedEmptyState(
                    icon: Icons.account_balance_wallet_outlined,
                    title: t.bank_accounts.empty.title,
                    subtitle: t.bank_accounts.empty.subtitle,
                    actionLabel: t.home.add_bank,
                    onAction: () => context.push('/add-bank'),
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount:
                          bankAccounts.length +
                          (bankAccounts.isNotEmpty ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show native ad at index 1 (second item) if list is not empty
                        if (index == 1 && bankAccounts.isNotEmpty) {
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: const SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(child: NativeAdWidget()),
                            ),
                          );
                        }

                        // Calculate correct data index based on ad position
                        final adjustedIndex =
                            (bankAccounts.isNotEmpty && index > 1)
                            ? index - 1
                            : index;
                        final bank = bankAccounts[adjustedIndex];

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Slidable(
                                  key: ValueKey(bank.id),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          HapticFeedback.lightImpact();
                                          context.push('/edit-bank/${bank.id}');
                                        },
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: AppColors.of(
                                          context,
                                        ).primaryAccent,
                                        icon: Icons.edit,
                                        label: t.general.edit,
                                      ),
                                      SlidableAction(
                                        onPressed: (context) =>
                                            _handleDelete(context, ref, bank),
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: AppColors.of(
                                          context,
                                        ).error,
                                        icon: Icons.delete,
                                        label: t.general.delete,
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      context.push('/bank-detail/${bank.id}');
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: NeumorphicContainer(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          logoService.getLogoWidget(
                                            bank.url,
                                            size: 50,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bank.bankName,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                    color: AppColors.of(
                                                      context,
                                                    ).textPrimary,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  bank.accountName,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: AppColors.of(
                                                      context,
                                                    ).textSecondary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: AppColors.of(
                                              context,
                                            ).textSecondary,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
