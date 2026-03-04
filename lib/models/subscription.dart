import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 1)
class Subscription extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String serviceName;

  @HiveField(2)
  String url;

  @HiveField(3)
  String emailOrUsername;

  @HiveField(4)
  String encryptedPassword;

  @HiveField(5)
  double monthlyCost;

  @HiveField(6)
  String currency;

  @HiveField(7)
  DateTime nextBillingDate;

  @HiveField(8)
  DateTime createdAt;

  Subscription({
    required this.id,
    required this.serviceName,
    required this.url,
    required this.emailOrUsername,
    required this.encryptedPassword,
    required this.monthlyCost,
    this.currency = 'TRY',
    required this.nextBillingDate,
    required this.createdAt,
  });
}
