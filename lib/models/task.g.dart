// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Task _$TaskFromJson(Map<String, dynamic> json) {
  return Task(
    json['name'] as String,
    json['id'] as String,
    json['description'] as String,
    json['status'] as String,
    json['estimation'] as int,
    json['dueDate'] == null ? null : DateTime.parse(json['dueDate'] as String),
    json['assignedTo'] as String,
    json['movedToToDo'] == null
        ? null
        : DateTime.parse(json['movedToToDo'] as String),
    json['movedToDone'] == null
        ? null
        : DateTime.parse(json['movedToDone'] as String),
  );
}

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'description': instance.description,
      'status': instance.status,
      'estimation': instance.estimation,
      'dueDate': instance.dueDate?.toIso8601String(),
      'assignedTo': instance.assignedTo,
      'movedToToDo': instance.movedToToDo?.toIso8601String(),
      'movedToDone': instance.movedToDone?.toIso8601String(),
    };
