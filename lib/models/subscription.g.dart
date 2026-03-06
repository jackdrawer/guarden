// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SubscriptionAdapter extends TypeAdapter<Subscription> {
  @override
  final int typeId = 1;

  @override
  Subscription read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Subscription(
      id: fields[0] as String,
      serviceName: fields[1] as String,
      url: fields[2] as String,
      emailOrUsername: fields[3] as String,
      encryptedPassword: fields[4] as String,
      monthlyCost: fields[5] as double,
      currency: fields[6] as String,
      nextBillingDate: fields[7] as DateTime,
      createdAt: fields[8] as DateTime,
      billingCycle: fields[9] as String,
      category: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Subscription obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.serviceName)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.emailOrUsername)
      ..writeByte(4)
      ..write(obj.encryptedPassword)
      ..writeByte(5)
      ..write(obj.monthlyCost)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.nextBillingDate)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.billingCycle)
      ..writeByte(10)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubscriptionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
