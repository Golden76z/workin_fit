// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tabata_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TabataConfigModel _$TabataConfigModelFromJson(Map<String, dynamic> json) =>
    TabataConfigModel(
      exerciseId: json['exerciseId'] as String,
      workTime: (json['workTime'] as num).toInt(),
      restTime: (json['restTime'] as num).toInt(),
      rounds: (json['rounds'] as num).toInt(),
    );

Map<String, dynamic> _$TabataConfigModelToJson(TabataConfigModel instance) =>
    <String, dynamic>{
      'exerciseId': instance.exerciseId,
      'workTime': instance.workTime,
      'restTime': instance.restTime,
      'rounds': instance.rounds,
    };
