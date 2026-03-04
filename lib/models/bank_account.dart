import 'package:hive/hive.dart';

part 'bank_account.g.dart';

@HiveType(typeId: 0)
class BankAccount extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String bankName;

  @HiveField(2)
  String url; // Logo fetch için veya net bankacılığı URL'si

  @HiveField(3)
  String accountName;

  @HiveField(4)
  String encryptedPassword;

  @HiveField(5)
  String encryptedNotes;

  @HiveField(6)
  int periodMonths; // Şifre rotasyon süresi: 1, 3, 6, 9, 12 vs.

  @HiveField(7)
  DateTime lastChangedAt; // Son değiştirilme tarihi

  @HiveField(8)
  DateTime createdAt;

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
  });
}
