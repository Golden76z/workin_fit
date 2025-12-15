// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enums.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MuscleAdapter extends TypeAdapter<Muscle> {
  @override
  final int typeId = 13;

  @override
  Muscle read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Muscle(
      id: fields[0] as String,
      name: fields[1] as String,
      commonName: fields[2] as String,
      category: fields[3] as MuscleCategory,
      isPrimary: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Muscle obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.commonName)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isPrimary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuscleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkOutTypeAdapter extends TypeAdapter<WorkOutType> {
  @override
  final int typeId = 10;

  @override
  WorkOutType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return WorkOutType.sets;
      case 1:
        return WorkOutType.tabata;
      case 2:
        return WorkOutType.timed;
      default:
        return WorkOutType.sets;
    }
  }

  @override
  void write(BinaryWriter writer, WorkOutType obj) {
    switch (obj) {
      case WorkOutType.sets:
        writer.writeByte(0);
        break;
      case WorkOutType.tabata:
        writer.writeByte(1);
        break;
      case WorkOutType.timed:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkOutTypeAdapter &&
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

class MuscleCategoryAdapter extends TypeAdapter<MuscleCategory> {
  @override
  final int typeId = 12;

  @override
  MuscleCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MuscleCategory.neck;
      case 1:
        return MuscleCategory.chest;
      case 2:
        return MuscleCategory.shoulders;
      case 3:
        return MuscleCategory.back;
      case 4:
        return MuscleCategory.biceps;
      case 5:
        return MuscleCategory.triceps;
      case 6:
        return MuscleCategory.forearms;
      case 7:
        return MuscleCategory.abs;
      case 8:
        return MuscleCategory.glutes;
      case 9:
        return MuscleCategory.quads;
      case 10:
        return MuscleCategory.hamstrings;
      case 11:
        return MuscleCategory.calves;
      case 12:
        return MuscleCategory.core;
      case 13:
        return MuscleCategory.cardio;
      default:
        return MuscleCategory.neck;
    }
  }

  @override
  void write(BinaryWriter writer, MuscleCategory obj) {
    switch (obj) {
      case MuscleCategory.neck:
        writer.writeByte(0);
        break;
      case MuscleCategory.chest:
        writer.writeByte(1);
        break;
      case MuscleCategory.shoulders:
        writer.writeByte(2);
        break;
      case MuscleCategory.back:
        writer.writeByte(3);
        break;
      case MuscleCategory.biceps:
        writer.writeByte(4);
        break;
      case MuscleCategory.triceps:
        writer.writeByte(5);
        break;
      case MuscleCategory.forearms:
        writer.writeByte(6);
        break;
      case MuscleCategory.abs:
        writer.writeByte(7);
        break;
      case MuscleCategory.glutes:
        writer.writeByte(8);
        break;
      case MuscleCategory.quads:
        writer.writeByte(9);
        break;
      case MuscleCategory.hamstrings:
        writer.writeByte(10);
        break;
      case MuscleCategory.calves:
        writer.writeByte(11);
        break;
      case MuscleCategory.core:
        writer.writeByte(12);
        break;
      case MuscleCategory.cardio:
        writer.writeByte(13);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuscleCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
