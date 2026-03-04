import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/strings.g.dart';
import '../../providers/web_password_provider.dart';
import '../../services/clipboard_service.dart';
import '../../services/crypto_service.dart';
import '../../services/logo_service.dart';
import '../../services/secure_storage_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/animated_empty_state.dart';
import '../../widgets/neumorphic/neumorphic_container.dart';

class WebPasswordsTab extends ConsumerWidget {
  const WebPasswordsTab({super.key});

  Future<void> _copyPassword(
    BuildContext context,
    WidgetRef ref,
    String encryptedPassword,
  ) async {
    try {
      final secureStorage = ref.read(secureStorageProvider);
      final cryptoService = ref.read(cryptoProvider);

      final base64Key = await secureStorage.getEncryptionKey();
      if (base64Key == null) throw Exception(t.web_passwords.no_key_error);

      final password = await cryptoService.decryptWithBase64Key(
        encryptedPassword,
        base64Key,
      );

      await ref.read(clipboardServiceProvider).copy(password);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.web_passwords.copy_success)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(t.web_passwords.copy_error(error: e.toString())),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final webPasswords = ref.watch(webPasswordProvider).valueOrNull ?? [];
    final logoService = ref.watch(logoServiceProvider);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.web_passwords.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.of(context).textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: webPasswords.isEmpty
                ? AnimatedEmptyState(
                    icon: Icons.password_outlined,
                    title: t.web_passwords.empty.title,
                    subtitle: t.web_passwords.empty.subtitle,
                  )
                : AnimationLimiter(
                    child: ListView.builder(
                      itemCount: webPasswords.length,
                      itemBuilder: (context, index) {
                        final wp = webPasswords[index];
                        final username = wp.username;
                        final maskedUsername = username.length > 2
                            ? '${username.substring(0, 2)}***'
                            : '***';

                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: Slidable(
                                  key: ValueKey(wp.id),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (context) {
                                          HapticFeedback.lightImpact();
                                          context.push(
                                            '/edit-web-password/${wp.id}',
                                          );
                                        },
                                        backgroundColor: Colors.transparent,
                                        foregroundColor: AppColors.of(
                                          context,
                                        ).primaryAccent,
                                        icon: Icons.edit,
                                        label: t.general.edit,
                                      ),
                                      SlidableAction(
                                        onPressed: (context) {
                                          HapticFeedback.mediumImpact();
                                          ref
                                              .read(
                                                webPasswordProvider.notifier,
                                              )
                                              .deleteWebPassword(wp.id);
                                        },
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
                                      context.push(
                                        '/web-password-detail/${wp.id}',
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: NeumorphicContainer(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          logoService.getLogoWidget(
                                            wp.url.isNotEmpty
                                                ? wp.url
                                                : wp.title,
                                            size: 50,
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  wp.title,
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
                                                  maskedUsername,
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
                                          IconButton(
                                            tooltip:
                                                t.web_passwords.tooltip_copy,
                                            icon: Icon(
                                              Icons.copy,
                                              color: AppColors.of(
                                                context,
                                              ).primaryAccent,
                                            ),
                                            onPressed: () => _copyPassword(
                                              context,
                                              ref,
                                              wp.encryptedPassword,
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
