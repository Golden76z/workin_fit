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

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Session _$SessionFromJson(Map<String, dynamic> json) => Session(
      id: json['id'] as String,
      name: json['name'] as String,
      workouts: (json['workouts'] as List<dynamic>)
          .map((e) => WorkoutConfig.fromJson(e as Map<String, dynamic>))
          .toList(),
      difficulty: $enumDecode(_$DifficultyLevelEnumMap, json['difficulty']),
      description: json['description'] as String?,
      restBetweenExercises:
          (json['restBetweenExercises'] as num?)?.toInt() ?? 120,
      transitionTime: (json['transitionTime'] as num?)?.toInt() ?? 5,
      isCustom: json['isCustom'] as bool? ?? false,
      userId: json['userId'] as String?,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$SessionToJson(Session instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'workouts': instance.workouts.map((e) => e.toJson()).toList(),
      'restBetweenExercises': instance.restBetweenExercises,
      'transitionTime': instance.transitionTime,
      'difficulty': _$DifficultyLevelEnumMap[instance.difficulty]!,
      'isCustom': instance.isCustom,
      'userId': instance.userId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$DifficultyLevelEnumMap = {
  DifficultyLevel.beginner: 'beginner',
  DifficultyLevel.intermediate: 'intermediate',
  DifficultyLevel.advanced: 'advanced',
};
