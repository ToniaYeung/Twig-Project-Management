import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';
//to generate json files run
//flutter packages pub run build_runner build

@JsonSerializable(nullable: false)
class Project {
  final String name;
  //assignees are user IDs
  final List<String> assignees;
  final DateTime dueDate;
  final String id;
  final DateTime creationDate;
  String teamLeader;

  //constructor
  Project(
    this.name,
    this.teamLeader,
    this.assignees,
    this.dueDate,
    this.id,
    this.creationDate,
  );
  //so that data can be accessed outside project
  //Call to a function to creates an instance of project from some json. Uses the auto generated function in order to do this
  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  //Calls the function to change the data into Json for use in the database
  Map<String, dynamic> toJson() => _$ProjectToJson(this);

  void setTeamLeader(String userId) {
    teamLeader = userId;
  }
}
