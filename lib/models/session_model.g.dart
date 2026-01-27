// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SessionModel _$SessionModelFromJson(Map<String, dynamic> json) => SessionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      exercises: (json['exercises'] as List<dynamic>)
          .map((e) => e as Map<String, dynamic>)
          .toList(),
      duration: (json['duration'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      description: json['description'] as String?,
    );

Map<String, dynamic> _$SessionModelToJson(SessionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'exercises': instance.exercises,
      'duration': instance.duration,
      'difficulty': instance.difficulty,
    };
