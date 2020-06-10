import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable(nullable: false)
class User {
  final String name;
  final String id;
  final String email;
  final int colour;

  User(this.name, this.id, this.email, this.colour);

  //Call to a function to creates an instance of project from some json. Uses the auto generated function in order to do this
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  //Calls the function to change the data into Json for use in the database
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
