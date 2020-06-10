import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/project.dart';
import 'package:twig/screens/login/login.dart';

import '../../../test_util.dart';
import '../../../unit/firebase/authentication_service_test.dart';
import '../home/home_test.dart';

main() {
  MockDatabase database;
  MockAuthenticationService auth;

  setUp(() {
    database = MockDatabase();
    auth = MockAuthenticationService();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Database>(create: (context) {
            return database;
          }),
          Provider<AuthenticationService>(create: (context) {
            return auth;
          })
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Login(),
          ),
        ),
      ),
    );
  }

  testWidgets('Email is validated', (WidgetTester tester) async {
    //setup
    String email = "tonia";

    //action
    await pumpLoginScreen(tester);

    Finder emailErrorMessageFinder = find.text("Must be a valid email");
    expect(emailErrorMessageFinder, findsNothing);

    Finder emailFinder = findKeyAndExpectOne(loginOrSignUpEmailFieldKey);
    await tester.enterText(emailFinder, email);

    Finder loginButtonFinder = findKeyAndExpectOne(loginOrRegisterButtonKey);
    await tapAndSettle(tester, loginButtonFinder);

    //assert
    Finder emailErrorMessageFinder2 = find.text("Must be a valid email");
    expect(emailErrorMessageFinder2, findsOneWidget);
  });

  testWidgets('Password is validated', (WidgetTester tester) async {
    //setup
    String password = "toe";

    //action
    await pumpLoginScreen(tester);

    Finder passwordErrorMessageFinder =
        find.text("Password must be 6 or more characters");
    expect(passwordErrorMessageFinder, findsNothing);

    Finder passwordFinder = findKeyAndExpectOne(loginOrSignUpPasswordFieldKey);
    await tester.enterText(passwordFinder, password);

    Finder loginButtonFinder = findKeyAndExpectOne(loginOrRegisterButtonKey);
    await tapAndSettle(tester, loginButtonFinder);

    //assert
    Finder passwordErrorMessageFinder2 =
        find.text("Password must be 6 or more characters");
    expect(passwordErrorMessageFinder2, findsOneWidget);
  });

  testWidgets('Login button logs them in', (WidgetTester tester) async {
    //setup
    String email = "tonia@gmail.com";
    String password = "password";

    //action
    await pumpLoginScreen(tester);
    Finder emailFinder = findKeyAndExpectOne(loginOrSignUpEmailFieldKey);
    await tester.enterText(emailFinder, email);

    Finder passwordFinder = findKeyAndExpectOne(loginOrSignUpPasswordFieldKey);
    await tester.enterText(passwordFinder, password);

    Finder loginButtonFinder = findKeyAndExpectOne(loginOrRegisterButtonKey);
    await tester.tap(loginButtonFinder);
    await tester.pump();
    await tester.pump();

    //assert
    verify(auth.login(email, password)).called(1);
    findKeyAndExpectOne(homeScreenKey);
  });

  testWidgets('Forgot password shows the dialog', (WidgetTester tester) async {
    //setup

    //action
    await pumpLoginScreen(tester);
    Finder forgotPasswordFinder = findKeyAndExpectOne(forgotPasswordButtonKey);
    await tapAndSettle(tester, forgotPasswordFinder);

    //assert
    Finder forgotPasswordDialogFinder =
        findKeyAndExpectOne(forgotPasswordDialogKey);
    expect(forgotPasswordDialogFinder, findsOneWidget);
  });
}
