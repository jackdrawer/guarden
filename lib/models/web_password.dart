import 'package:hive/hive.dart';

part 'web_password.g.dart';

@HiveType(typeId: 2)
class WebPassword extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String url;

  @HiveField(3)
  final String username;

  @HiveField(4)
  final String encryptedPassword;

  @HiveField(5)
  final String encryptedNotes;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime updatedAt;

  @HiveField(8)
  final String category;

  WebPassword({
    required this.id,
    required this.title,
    required this.url,
    required this.username,
    required this.encryptedPassword,
    this.encryptedNotes = '',
    required this.createdAt,
    required this.updatedAt,
    this.category = '',
  });

  WebPassword copyWith({
    String? title,
    String? url,
    String? username,
    String? encryptedPassword,
    String? encryptedNotes,
    DateTime? updatedAt,
    String? category,
  }) {
    return WebPassword(
      id: id,
      title: title ?? this.title,
      url: url ?? this.url,
      username: username ?? this.username,
      encryptedPassword: encryptedPassword ?? this.encryptedPassword,
      encryptedNotes: encryptedNotes ?? this.encryptedNotes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      category: category ?? this.category,
    );
  }
}
