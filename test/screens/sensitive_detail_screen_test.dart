import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guarden/i18n/strings.g.dart';
import 'package:guarden/models/bank_account.dart';
import 'package:guarden/models/web_password.dart';
import 'package:guarden/providers/auth_provider.dart';
import 'package:guarden/providers/bank_account_provider.dart';
import 'package:guarden/providers/settings_provider.dart';
import 'package:guarden/providers/web_password_provider.dart';
import 'package:guarden/screens/bank_accounts/bank_account_detail_screen.dart';
import 'package:guarden/screens/web_passwords/web_password_detail_screen.dart';
import 'package:guarden/services/clipboard_service.dart';
import 'package:guarden/services/crypto_service.dart';
import 'package:guarden/services/logo_service.dart';
import 'package:guarden/services/secure_storage_service.dart';
import 'package:guarden/theme/app_colors.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier({
    this.sensitiveActionResult = true,
  });

  bool sensitiveActionResult;
  int sensitiveActionCalls = 0;

  @override
  Future<AuthState> build() async => AuthState.authenticated;

  @override
  Future<bool> authenticateForSensitiveAction(
    BuildContext context, {
    String? biometricReason,
    String? passwordDialogTitle,
    String? wrongPasswordMessage,
  }) async {
    sensitiveActionCalls++;
    return sensitiveActionResult;
  }

  @override
  Future<bool> canUseBiometrics() async => false;

  @override
  Future<bool> biometricUnlock({String? reason}) async => false;

  @override
  Future<bool> verifyMasterPassword(String masterPassword) async => true;

  @override
  Future<String?> requestVerifiedMasterPassword(
    BuildContext context, {
    String? dialogTitle,
    String? wrongPasswordMessage,
  }) async {
    return sensitiveActionResult ? 'master-password' : null;
  }
}

class FakeSettingsNotifier extends SettingsNotifier {
  FakeSettingsNotifier(this.settingsState);

  final SettingsState settingsState;

  @override
  Future<SettingsState> build() async => settingsState;
}

class FakeBankAccountNotifier extends BankAccountNotifier {
  FakeBankAccountNotifier(this.accounts);

  final List<BankAccount> accounts;

  @override
  Future<List<BankAccount>> build() async => accounts;
}

class FakeWebPasswordNotifier extends WebPasswordNotifier {
  FakeWebPasswordNotifier(this.passwords);

  final List<WebPassword> passwords;

  @override
  Future<List<WebPassword>> build() async => passwords;
}

class FakeSecureStorageService extends SecureStorageService {
  FakeSecureStorageService({this.encryptionKey = 'test-key'});

  final String? encryptionKey;

  @override
  Future<String?> getEncryptionKey() async => encryptionKey;
}

class FakeCryptoService extends CryptoService {
  FakeCryptoService(this.decryptions);

  final Map<String, String> decryptions;

  @override
  Future<String> decryptWithBase64Key(
    String encryptedBase64,
    String base64Key,
  ) async {
    return decryptions[encryptedBase64] ?? encryptedBase64;
  }
}

class FakeClipboardService extends ClipboardService {
  int copyCalls = 0;
  String? lastValue;

  @override
  Future<void> copy(
    String text, {
    Duration expireAfter = const Duration(seconds: 45),
  }) async {
    copyCalls++;
    lastValue = text;
  }
}

class FakeLogoService extends LogoService {
  @override
  Widget getLogoWidget(String rawUrlOrDomain, {double size = 48.0}) {
    return SizedBox(width: size, height: size);
  }
}

Widget _buildHarness({
  required Widget child,
  required List<Override> overrides,
}) {
  return ProviderScope(
    overrides: overrides,
    child: TranslationProvider(
      child: MaterialApp(
        theme: ThemeData(useMaterial3: true, extensions: [AppColors.light]),
        home: child,
      ),
    ),
  );
}

void main() {
  testWidgets('bank notes stay hidden until explicit reveal and remask', (
    tester,
  ) async {
    final auth = FakeAuthNotifier();
    final settings = FakeSettingsNotifier(
      SettingsState.initial().copyWith(isInitialized: true),
    );
    final accounts = FakeBankAccountNotifier([
      BankAccount(
        id: 'bank-1',
        bankName: 'Test Bank',
        url: 'example.com',
        accountName: 'john',
        encryptedPassword: 'encrypted-password',
        encryptedNotes: 'encrypted-notes',
        lastChangedAt: DateTime(2026, 3, 8),
        createdAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: const BankAccountDetailScreen(accountId: 'bank-1'),
        overrides: [
          authProvider.overrideWith(() => auth),
          settingsProvider.overrideWith(() => settings),
          bankAccountProvider.overrideWith(() => accounts),
          secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
          cryptoProvider.overrideWithValue(
            FakeCryptoService({
              'encrypted-password': 'secret-password',
              'encrypted-notes': 'bank notes',
            }),
          ),
          clipboardServiceProvider.overrideWithValue(FakeClipboardService()),
          logoServiceProvider.overrideWithValue(FakeLogoService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('bank notes'), findsNothing);
    expect(find.text('••••••••'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility).at(1));
    await tester.pumpAndSettle();

    expect(find.text('bank notes'), findsOneWidget);

    await tester.pump(const Duration(seconds: 16));
    await tester.pumpAndSettle();

    expect(find.text('bank notes'), findsNothing);
    expect(find.text('••••••••'), findsOneWidget);
  });

  testWidgets('web notes stay hidden until explicit reveal and remask', (
    tester,
  ) async {
    final auth = FakeAuthNotifier();
    final settings = FakeSettingsNotifier(
      SettingsState.initial().copyWith(isInitialized: true),
    );
    final passwords = FakeWebPasswordNotifier([
      WebPassword(
        id: 'web-1',
        title: 'Example',
        url: 'example.com',
        username: 'john@example.com',
        encryptedPassword: 'encrypted-password',
        encryptedNotes: 'encrypted-notes',
        createdAt: DateTime(2026, 3, 8),
        updatedAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: const WebPasswordDetailScreen(webPasswordId: 'web-1'),
        overrides: [
          authProvider.overrideWith(() => auth),
          settingsProvider.overrideWith(() => settings),
          webPasswordProvider.overrideWith(() => passwords),
          secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
          cryptoProvider.overrideWithValue(
            FakeCryptoService({
              'encrypted-password': 'secret-password',
              'encrypted-notes': 'web notes',
            }),
          ),
          clipboardServiceProvider.overrideWithValue(FakeClipboardService()),
          logoServiceProvider.overrideWithValue(FakeLogoService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('web notes'), findsNothing);
    expect(find.text('••••••••'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility).at(1));
    await tester.pumpAndSettle();

    expect(find.text('web notes'), findsOneWidget);

    await tester.pump(const Duration(seconds: 16));
    await tester.pumpAndSettle();

    expect(find.text('web notes'), findsNothing);
    expect(find.text('••••••••'), findsOneWidget);
  });

  testWidgets('bank detail copy requires sensitive action auth', (
    tester,
  ) async {
    final auth = FakeAuthNotifier(sensitiveActionResult: false);
    final clipboard = FakeClipboardService();
    final settings = FakeSettingsNotifier(
      SettingsState.initial().copyWith(
        biometricConfirm: true,
        isInitialized: true,
      ),
    );
    final accounts = FakeBankAccountNotifier([
      BankAccount(
        id: 'bank-1',
        bankName: 'Test Bank',
        url: 'example.com',
        accountName: 'john',
        encryptedPassword: 'encrypted-password',
        encryptedNotes: '',
        lastChangedAt: DateTime(2026, 3, 8),
        createdAt: DateTime(2026, 3, 8),
      ),
    ]);

    await tester.pumpWidget(
      _buildHarness(
        child: const BankAccountDetailScreen(accountId: 'bank-1'),
        overrides: [
          authProvider.overrideWith(() => auth),
          settingsProvider.overrideWith(() => settings),
          bankAccountProvider.overrideWith(() => accounts),
          secureStorageProvider.overrideWithValue(FakeSecureStorageService()),
          cryptoProvider.overrideWithValue(
            FakeCryptoService({'encrypted-password': 'secret-password'}),
          ),
          clipboardServiceProvider.overrideWithValue(clipboard),
          logoServiceProvider.overrideWithValue(FakeLogoService()),
        ],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.copy).first);
    await tester.pumpAndSettle();

    expect(auth.sensitiveActionCalls, 1);
    expect(clipboard.copyCalls, 0);
  });
}
