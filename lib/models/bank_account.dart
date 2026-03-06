import 'package:hive/hive.dart';

part 'bank_account.g.dart';

@HiveType(typeId: 0)
class BankAccount extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String bankName;

  @HiveField(2)
  final String url; // Logo fetch için veya net bankacılığı URL'si

  @HiveField(3)
  final String accountName;

  @HiveField(4)
  final String encryptedPassword;

  @HiveField(5)
  final String encryptedNotes;

  @HiveField(6)
  final int periodMonths; // Şifre rotasyon süresi: 1, 3, 6, 9, 12 vs.

  @HiveField(7)
  final DateTime lastChangedAt; // Son değiştirilme tarihi

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final String category;

  BankAccount({
    required this.id,
    required this.bankName,
    required this.url,
    required this.accountName,
    required this.encryptedPassword,
    this.encryptedNotes = '',
    this.periodMonths = 6,
    required this.lastChangedAt,
    required this.createdAt,
    this.category = '',
  });

  BankAccount copyWith({
    String? bankName,
    String? url,
    String? accountName,
    String? encryptedPassword,
    String? encryptedNotes,
    int? periodMonths,
    DateTime? lastChangedAt,
    String? category,
  }) {
    return BankAccount(
      id: id,
      bankName: bankName ?? this.bankName,
      url: url ?? this.url,
      accountName: accountName ?? this.accountName,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      encryptedNotes: encryptedNotes ?? this.encryptedNotes,
      periodMonths: periodMonths ?? this.periodMonths,
      lastChangedAt: lastChangedAt ?? this.lastChangedAt,
      createdAt: createdAt,
      category: category ?? this.category,
    );
  }
}
