// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trade_signal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TradeSignalAdapter extends TypeAdapter<TradeSignal> {
  @override
  final int typeId = 0;

  @override
  TradeSignal read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TradeSignal(
      symbol: fields[0] as String,
      signal: fields[1] as String,
      tier: fields[2] as String,
      entry: fields[3] as double,
      stopLoss: fields[4] as double,
      target: fields[5] as double,
      reason: fields[6] as String,
      rsi: fields[7] as String,
      timestamp: fields[8] as DateTime,
      source: fields[9] as String,
      fullJson: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TradeSignal obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.symbol)
      ..writeByte(1)
      ..write(obj.signal)
      ..writeByte(2)
      ..write(obj.tier)
      ..writeByte(3)
      ..write(obj.entry)
      ..writeByte(4)
      ..write(obj.stopLoss)
      ..writeByte(5)
      ..write(obj.target)
      ..writeByte(6)
      ..write(obj.reason)
      ..writeByte(7)
      ..write(obj.rsi)
      ..writeByte(8)
      ..write(obj.timestamp)
      ..writeByte(9)
      ..write(obj.source)
      ..writeByte(10)
      ..write(obj.fullJson);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TradeSignalAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
