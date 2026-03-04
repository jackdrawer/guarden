import 'package:hive/hive.dart';

part 'web_password.g.dart';

@HiveType(typeId: 2)
class WebPassword extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String url;

  @HiveField(3)
  String username;

  @HiveField(4)
  String encryptedPassword;

  @HiveField(5)
  String encryptedNotes;

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime updatedAt;

  WebPassword({
    required this.id,
    required this.title,
    required this.url,
    required this.username,
    required this.encryptedPassword,
    this.encryptedNotes = '',
    required this.createdAt,
    required this.updatedAt,
  });
}
