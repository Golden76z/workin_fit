// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercices.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseAdapter extends TypeAdapter<Exercise> {
  @override
  final int typeId = 0;

  @override
  Exercise read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Exercise(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      imageMuscleUrl: fields[3] as String,
      imageTutorialUrl: fields[4] as String,
      primaryMuscleIds: (fields[5] as List).cast<String>(),
      secondaryMuscleIds: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, Exercise obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.imageMuscleUrl)
      ..writeByte(4)
      ..write(obj.imageTutorialUrl)
      ..writeByte(5)
      ..write(obj.primaryMuscleIds)
      ..writeByte(6)
      ..write(obj.secondaryMuscleIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
