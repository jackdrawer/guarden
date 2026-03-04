// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_account.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BankAccountAdapter extends TypeAdapter<BankAccount> {
  @override
  final int typeId = 0;

  @override
  BankAccount read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BankAccount(
      id: fields[0] as String,
      bankName: fields[1] as String,
      url: fields[2] as String,
      accountName: fields[3] as String,
      encryptedPassword: fields[4] as String,
      encryptedNotes: fields[5] as String,
      periodMonths: fields[6] as int,
      lastChangedAt: fields[7] as DateTime,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BankAccount obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.bankName)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.accountName)
      ..writeByte(4)
      ..write(obj.encryptedPassword)
      ..writeByte(5)
      ..write(obj.encryptedNotes)
      ..writeByte(6)
      ..write(obj.periodMonths)
      ..writeByte(7)
      ..write(obj.lastChangedAt)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankAccountAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
