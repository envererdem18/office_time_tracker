// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_out.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CheckInOutAdapter extends TypeAdapter<CheckInOut> {
  @override
  final int typeId = 0;

  @override
  CheckInOut read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CheckInOut(
      date: fields[0] as DateTime,
      checkInTime: fields[1] as DateTime?,
      checkOutTime: fields[2] as DateTime?,
      commuteDepartureTime: fields[3] as DateTime?,
      returnArrivalTime: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CheckInOut obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.checkInTime)
      ..writeByte(2)
      ..write(obj.checkOutTime)
      ..writeByte(3)
      ..write(obj.commuteDepartureTime)
      ..writeByte(4)
      ..write(obj.returnArrivalTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckInOutAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
