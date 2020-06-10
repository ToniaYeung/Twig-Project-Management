import 'package:flutter/material.dart';
import 'package:twig/models/user.dart';

class Assignees {
  final List<User> users;

  Assignees(this.users);

  int getColour(String userId) {
    final usersSearched = users.where((user) => userId == user.id);

    //If there is no user with that id, then return a default colour
    if (usersSearched.isEmpty) {
      return Color(0xFFF7F797).value;
    }

    //.first gets the first element of the list
    return usersSearched.first.colour;
  }
}
