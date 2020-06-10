import 'package:flutter/material.dart';
import 'package:test/test.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/user.dart';

void main() {
  //testing getColour(String userId);
  test('For a user that does not exist, should return the default color',
      () async {
    // setup
    Assignees assignees = Assignees([]);

    // action
    int color = assignees.getColour("myRandomUserId");

    // assert
    expect(color, equals(0xFFF7F797));
  });

  test('For a userId that exists, should return their colour', () async {
    // setup

    Assignees assignees = Assignees([
      User('Tonia', 'myRandomUserId', 'tonia@gmail.com', Colors.pink.value)
    ]);

    // action
    int color = assignees.getColour("myRandomUserId");

    // assert
    expect(color, equals(Colors.pink.value));
  });
  test(
      'For a userId that exists and multiple assignees, should return their colour',
      () async {
    // setup
    Assignees assignees = Assignees([
      User('User1', 'differentRandomUserId', 'user1@yahoo.com',
          Colors.blue.value),
      User('Tonia', 'myRandomUserId', 'tonia@gmail.com', Colors.pink.value)
    ]);

    // action
    int color = assignees.getColour("myRandomUserId");

    // assert
    expect(color, equals(Colors.pink.value));
  });
}
