// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutConfigAdapter extends TypeAdapter<WorkoutConfig> {
  @override
  final int typeId = 2;

  @override
  WorkoutConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutConfig(
      type: fields[0] as WorkoutType,
      exerciseId: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutConfig obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.exerciseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SetsConfigAdapter extends TypeAdapter<SetsConfig> {
  @override
  final int typeId = 3;

  @override
  SetsConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SetsConfig(
      exerciseId: fields[1] as String,
      sets: fields[2] as int,
      reps: fields[3] as int,
      restBetweenSets: fields[4] as int,
      weight: fields[5] as double?,
      weightUnit: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SetsConfig obj) {
    writer
      ..writeByte(7)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.reps)
      ..writeByte(4)
      ..write(obj.restBetweenSets)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.weightUnit)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.exerciseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SetsConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TabataConfigAdapter extends TypeAdapter<TabataConfig> {
  @override
  final int typeId = 4;

  @override
  TabataConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TabataConfig(
      exerciseId: fields[1] as String,
      workTime: fields[2] as int,
      restTime: fields[3] as int,
      rounds: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TabataConfig obj) {
    writer
      ..writeByte(5)
      ..writeByte(2)
      ..write(obj.workTime)
      ..writeByte(3)
      ..write(obj.restTime)
      ..writeByte(4)
      ..write(obj.rounds)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.exerciseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabataConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TimedConfigAdapter extends TypeAdapter<TimedConfig> {
  @override
  final int typeId = 5;

  @override
  TimedConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TimedConfig(
      exerciseId: fields[1] as String,
      duration: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TimedConfig obj) {
    writer
      ..writeByte(3)
      ..writeByte(2)
      ..write(obj.duration)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.exerciseId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimedConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
