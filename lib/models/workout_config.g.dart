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
      sets: fields[5] as int? ?? 1,
      restBetweenSets: fields[6] as int? ?? 60,
    );
  }

  @override
  void write(BinaryWriter writer, TabataConfig obj) {
    writer
      ..writeByte(7)
      ..writeByte(2)
      ..write(obj.workTime)
      ..writeByte(3)
      ..write(obj.restTime)
      ..writeByte(4)
      ..write(obj.rounds)
      ..writeByte(5)
      ..write(obj.sets)
      ..writeByte(6)
      ..write(obj.restBetweenSets)
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

class CircuitConfigAdapter extends TypeAdapter<CircuitConfig> {
  @override
  final int typeId = 7;

  @override
  CircuitConfig read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CircuitConfig(
      name: fields[2] as String? ?? 'Circuit',
      exercises: (fields[3] as List?)?.cast<WorkoutConfig>() ?? [],
      rounds: fields[4] as int? ?? 3,
      restBetweenExercises: fields[5] as int? ?? 0,
      restBetweenRounds: fields[6] as int? ?? 60,
    );
  }

  @override
  void write(BinaryWriter writer, CircuitConfig obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.exerciseId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.exercises)
      ..writeByte(4)
      ..write(obj.rounds)
      ..writeByte(5)
      ..write(obj.restBetweenExercises)
      ..writeByte(6)
      ..write(obj.restBetweenRounds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CircuitConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutConfig _$WorkoutConfigFromJson(Map<String, dynamic> json) =>
    WorkoutConfig(
      type: $enumDecode(_$WorkoutTypeEnumMap, json['type']),
      exerciseId: json['exerciseId'] as String,
    );

Map<String, dynamic> _$WorkoutConfigToJson(WorkoutConfig instance) =>
    <String, dynamic>{
      'type': _$WorkoutTypeEnumMap[instance.type]!,
      'exerciseId': instance.exerciseId,
    };

const _$WorkoutTypeEnumMap = {
  WorkoutType.sets: 'sets',
  WorkoutType.tabata: 'tabata',
  WorkoutType.timed: 'timed',
};

SetsConfig _$SetsConfigFromJson(Map<String, dynamic> json) => SetsConfig(
      exerciseId: json['exerciseId'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      restBetweenSets: (json['restBetweenSets'] as num?)?.toInt() ?? 60,
      weight: (json['weight'] as num?)?.toDouble(),
      weightUnit: json['weightUnit'] as String?,
    );

Map<String, dynamic> _$SetsConfigToJson(SetsConfig instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'sets': instance.sets,
      'reps': instance.reps,
      'restBetweenSets': instance.restBetweenSets,
      'weight': instance.weight,
      'weightUnit': instance.weightUnit,
    };

TabataConfig _$TabataConfigFromJson(Map<String, dynamic> json) => TabataConfig(
      exerciseId: json['exerciseId'] as String,
      workTime: (json['workTime'] as num).toInt(),
      restTime: (json['restTime'] as num).toInt(),
      rounds: (json['rounds'] as num).toInt(),
      sets: (json['sets'] as num?)?.toInt() ?? 1,
      restBetweenSets: (json['restBetweenSets'] as num?)?.toInt() ?? 60,
    );

Map<String, dynamic> _$TabataConfigToJson(TabataConfig instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'workTime': instance.workTime,
      'restTime': instance.restTime,
      'rounds': instance.rounds,
      'sets': instance.sets,
      'restBetweenSets': instance.restBetweenSets,
    };

TimedConfig _$TimedConfigFromJson(Map<String, dynamic> json) => TimedConfig(
      exerciseId: json['exerciseId'] as String,
      duration: (json['duration'] as num).toInt(),
    );

Map<String, dynamic> _$TimedConfigToJson(TimedConfig instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'duration': instance.duration,
    };
