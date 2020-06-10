// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Project _$ProjectFromJson(Map<String, dynamic> json) {
  return Project(
    json['name'] as String,
    json['teamLeader'] as String,
    (json['assignees'] as List).map((e) => e as String).toList(),
    DateTime.parse(json['dueDate'] as String),
    json['id'] as String,
    DateTime.parse(json['creationDate'] as String),
  );
}

Map<String, dynamic> _$ProjectToJson(Project instance) => <String, dynamic>{
      'name': instance.name,
      'teamLeader': instance.teamLeader,
      'assignees': instance.assignees,
      'dueDate': instance.dueDate.toIso8601String(),
      'id': instance.id,
      'creationDate': instance.creationDate.toIso8601String(),
    };
