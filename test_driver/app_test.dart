import 'dart:math';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';
import 'package:twig/common/utility/keys.dart';

//To run: First log out, then run:
// flutter driver --target=test_driver/app.dart
//All tests run one after another
void main() {
  group('Twig integration tests', () {
    //This object contains all the functionality of the integration tests, e.g. tap, scroll, drag, etc.
    FlutterDriver driver;
    String email =
        "integration-test-sign-up-${Random().nextInt(999999)}@gmail.com";

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    Future<void> tap(String key) async {
      print("Tap $key");
      await driver.tap(find.byValueKey(key));
    }

    test('User can sign up ', () async {
      await tap(navigateToSignUpOrLoginButtonKey);
      await tap(signUpNameFieldKey);
      await driver.enterText("Tonia");
      await tap(loginOrSignUpEmailFieldKey);
      await driver.enterText(email);
      await tap(loginOrSignUpPasswordFieldKey);
      await driver.enterText("password");
      await tap(loginOrRegisterButtonKey);
      await Future.delayed(Duration(seconds: 3));
    });

    test('User can send forgot password email', () async {
      await tap(forgotPasswordButtonKey);
      await tap(forgotPasswordEmailKey);
      await driver.enterText(email);
      await tap(forgotPasswordSubmitKey);
    });

    test('User can login', () async {
      await tap(loginOrSignUpEmailFieldKey);
      await driver.enterText(email);
      await tap(loginOrSignUpPasswordFieldKey);
      await driver.enterText("password");
      await tap(loginOrRegisterButtonKey);
    });

    test('User can create new project', () async {
      await tap(newProjectButtonKey);
      await tap(newProjectNameFieldKey);
      await driver.enterText("Homework");
      await tap(newProjectSubmitButtonKey);
      await Future.delayed(Duration(seconds: 3));
    });

    test('User can create new task', () async {
      await tap("Homework$projectCardKey");
      await tap(backlogTabKey);
      await tap(addTaskButtonKey);
      await tap(addTaskDialogNameKey);
      await driver.enterText("Task");
      await tap(addTaskDialogDescriptionKey);
      await driver.enterText("Description");
      await tap(submitTaskButtonKey);
    });

    test('User can delete a task', () async {
      await tap(deleteTaskButtonKey);
      await tap(deleteYesButtonKey);
    });

    test('User can delete project', () async {
      await tap(settingsTabKey);
      await tap(deleteProjectButtonKey);
      await tap(deleteYesButtonKey);
    });

    test('User can log out', () async {
      await tap(logOutButtonKey);
    });
  });
}
