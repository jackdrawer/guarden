// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_password.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WebPasswordAdapter extends TypeAdapter<WebPassword> {
  @override
  final int typeId = 2;

  @override
  WebPassword read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WebPassword(
      id: fields[0] as String,
      title: fields[1] as String,
      url: fields[2] as String,
      username: fields[3] as String,
      encryptedPassword: fields[4] as String,
      encryptedNotes: fields[5] as String,
      createdAt: fields[6] as DateTime,
      updatedAt: fields[7] as DateTime,
      category: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WebPassword obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.encryptedPassword)
      ..writeByte(5)
      ..write(obj.encryptedNotes)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(8)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WebPasswordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
