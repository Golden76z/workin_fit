// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutTypeAdapter extends TypeAdapter<WorkoutType> {
  @override
  final int typeId = 10;

  @override
  WorkoutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkoutType.sets;
      case 1:
        return WorkoutType.tabata;
      case 2:
        return WorkoutType.timed;
      default:
        return WorkoutType.sets;
    }
  }

  @override
  void write(BinaryWriter writer, WorkoutType obj) {
    switch (obj) {
      case WorkoutType.sets:
        writer.writeByte(0);
        break;
      case WorkoutType.tabata:
        writer.writeByte(1);
        break;
      case WorkoutType.timed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DifficultyLevelAdapter extends TypeAdapter<DifficultyLevel> {
  @override
  final int typeId = 11;

  @override
  DifficultyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DifficultyLevel.beginner;
      case 1:
        return DifficultyLevel.intermediate;
      case 2:
        return DifficultyLevel.advanced;
      default:
        return DifficultyLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, DifficultyLevel obj) {
    switch (obj) {
      case DifficultyLevel.beginner:
        writer.writeByte(0);
        break;
      case DifficultyLevel.intermediate:
        writer.writeByte(1);
        break;
      case DifficultyLevel.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DifficultyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MuscleGroupAdapter extends TypeAdapter<MuscleGroup> {
  @override
  final int typeId = 12;

  @override
  MuscleGroup read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MuscleGroup.chest;
      case 1:
        return MuscleGroup.shoulders;
      case 2:
        return MuscleGroup.triceps;
      case 3:
        return MuscleGroup.biceps;
      case 4:
        return MuscleGroup.back;
      case 5:
        return MuscleGroup.forearms;
      case 6:
        return MuscleGroup.quads;
      case 7:
        return MuscleGroup.hamstrings;
      case 8:
        return MuscleGroup.calves;
      case 9:
        return MuscleGroup.glutes;
      case 10:
        return MuscleGroup.abs;
      case 11:
        return MuscleGroup.obliques;
      case 12:
        return MuscleGroup.lowerBack;
      case 13:
        return MuscleGroup.cardio;
      default:
        return MuscleGroup.chest;
    }
  }

  @override
  void write(BinaryWriter writer, MuscleGroup obj) {
    switch (obj) {
      case MuscleGroup.chest:
        writer.writeByte(0);
        break;
      case MuscleGroup.shoulders:
        writer.writeByte(1);
        break;
      case MuscleGroup.triceps:
        writer.writeByte(2);
        break;
      case MuscleGroup.biceps:
        writer.writeByte(3);
        break;
      case MuscleGroup.back:
        writer.writeByte(4);
        break;
      case MuscleGroup.forearms:
        writer.writeByte(5);
        break;
      case MuscleGroup.quads:
        writer.writeByte(6);
        break;
      case MuscleGroup.hamstrings:
        writer.writeByte(7);
        break;
      case MuscleGroup.calves:
        writer.writeByte(8);
        break;
      case MuscleGroup.glutes:
        writer.writeByte(9);
        break;
      case MuscleGroup.abs:
        writer.writeByte(10);
        break;
      case MuscleGroup.obliques:
        writer.writeByte(11);
        break;
      case MuscleGroup.lowerBack:
        writer.writeByte(12);
        break;
      case MuscleGroup.cardio:
        writer.writeByte(13);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuscleGroupAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
