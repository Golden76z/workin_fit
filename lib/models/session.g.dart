// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SessionAdapter extends TypeAdapter<Session> {
  @override
  final int typeId = 1;

  @override
  Session read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Session(
      id: fields[0] as String,
      name: fields[1] as String,
      workouts: (fields[3] as List).cast<WorkoutConfig>(),
      difficulty: fields[6] as DifficultyLevel,
      description: fields[2] as String?,
      restBetweenExercises: fields[4] as int,
      transitionTime: fields[5] as int,
      isCustom: fields[7] as bool,
      userId: fields[8] as String?,
      createdAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Session obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.workouts)
      ..writeByte(4)
      ..write(obj.restBetweenExercises)
      ..writeByte(5)
      ..write(obj.transitionTime)
      ..writeByte(6)
      ..write(obj.difficulty)
      ..writeByte(7)
      ..write(obj.isCustom)
      ..writeByte(8)
      ..write(obj.userId)
      ..writeByte(9)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
