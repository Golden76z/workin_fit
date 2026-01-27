// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProgramModel _$ProgramModelFromJson(Map<String, dynamic> json) => ProgramModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      sessionIds: (json['sessionIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      durationWeeks: (json['durationWeeks'] as num).toInt(),
      difficulty: json['difficulty'] as String,
      goals: (json['goals'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ProgramModelToJson(ProgramModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'sessionIds': instance.sessionIds,
      'durationWeeks': instance.durationWeeks,
      'difficulty': instance.difficulty,
      'goals': instance.goals,
    };
