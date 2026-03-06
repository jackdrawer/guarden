import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 1)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String serviceName;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String emailOrUsername;

  @HiveField(4)
  final String encryptedPassword;

  @HiveField(5)
  final double monthlyCost;

  @HiveField(6)
  final String currency;

  @HiveField(7)
  final DateTime nextBillingDate;

  @HiveField(8)
  final DateTime createdAt;

  @HiveField(9)
  final String billingCycle;

  @HiveField(10)
  final String category;

  Subscription({
    required this.id,
    required this.serviceName,
    required this.url,
    required this.emailOrUsername,
    required this.encryptedPassword,
    required this.monthlyCost,
    this.currency = 'TRY', // Hive fallback, runtime uses CurrencyUtils
    required this.nextBillingDate,
    required this.createdAt,
    this.billingCycle = 'monthly',
    this.category = '',
  });

  Subscription copyWith({
    String? serviceName,
    String? url,
    String? emailOrUsername,
    String? encryptedPassword,
    double? monthlyCost,
    String? currency,
    DateTime? nextBillingDate,
    String? billingCycle,
    String? category,
  }) {
    return Subscription(
      id: id,
      serviceName: serviceName ?? this.serviceName,
      url: url ?? this.url,
      emailOrUsername: emailOrUsername ?? this.emailOrUsername,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      monthlyCost: monthlyCost ?? this.monthlyCost,
      currency: currency ?? this.currency,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      createdAt: createdAt,
      billingCycle: billingCycle ?? this.billingCycle,
      category: category ?? this.category,
    );
  }
}
