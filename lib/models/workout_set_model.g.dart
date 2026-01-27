// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_set_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WorkoutSetModel _$WorkoutSetModelFromJson(Map<String, dynamic> json) =>
    WorkoutSetModel(
      exerciseId: json['exerciseId'] as String,
      sets: (json['sets'] as num).toInt(),
      reps: (json['reps'] as num).toInt(),
      restTime: (json['restTime'] as num).toInt(),
    );

Map<String, dynamic> _$WorkoutSetModelToJson(WorkoutSetModel instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'sets': instance.sets,
      'reps': instance.reps,
      'restTime': instance.restTime,
    };
