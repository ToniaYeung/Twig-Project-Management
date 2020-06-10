import 'package:json_annotation/json_annotation.dart';

part 'task.g.dart';

@JsonSerializable(nullable: true)
class Task {
  final String name;
  final String id;
  final String description;
  final String status;
  final int estimation;
  final DateTime dueDate;
  //their id
  final String assignedTo;
  final DateTime movedToToDo;
  final DateTime movedToDone;

  Task(
    this.name,
    this.id,
    this.description,
    this.status,
    this.estimation,
    this.dueDate,
    this.assignedTo,
    this.movedToToDo,
    this.movedToDone,
  );

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  //Calls the function to change the data into Json for use in the database
  Map<String, dynamic> toJson() => _$TaskToJson(this);
}
