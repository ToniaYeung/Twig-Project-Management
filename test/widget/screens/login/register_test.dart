import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/screens/login/register.dart';

import '../../../test_util.dart';
import '../../../unit/firebase/authentication_service_test.dart';
import '../home/home_test.dart';

main() {
  MockDatabase database;
  MockAuthenticationService auth;
  MockNavigatorObserver mockNavigatorObserver;

  setUp(() {
    database = MockDatabase();
    auth = MockAuthenticationService();
    mockNavigatorObserver = MockNavigatorObserver();
  });

  Future<void> pumpRegisterScreen(WidgetTester tester) async {
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
          navigatorObservers: [mockNavigatorObserver],
          home: Scaffold(
            body: Register(),
          ),
        ),
      ),
    );
  }

  testWidgets('Name field is validated', (WidgetTester tester) async {
    //setup
    String name = "";

    //action
    await pumpRegisterScreen(tester);

    Finder nameMessageFinder = find.text("Please enter your name");
    expect(nameMessageFinder, findsNothing);

    Finder nameFinder = findKeyAndExpectOne(signUpNameFieldKey);
    await tester.enterText(nameFinder, name);

    Finder loginButtonFinder = findKeyAndExpectOne(loginOrRegisterButtonKey);
    await tapAndSettle(tester, loginButtonFinder);

    //assert
    Finder nameMessageFinder2 = find.text("Please enter your name");
    expect(nameMessageFinder2, findsOneWidget);
  });

  testWidgets('Email is validated', (WidgetTester tester) async {
    //setup
    String email = "tonia";

    //action
    await pumpRegisterScreen(tester);

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
    await pumpRegisterScreen(tester);

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

  testWidgets('Register button registers the user',
      (WidgetTester tester) async {
    //setup
    String name = "tonia";
    String email = "tonia@gmail.com";
    String password = "password";

    //action
    await pumpRegisterScreen(tester);
    Finder nameFinder = findKeyAndExpectOne(signUpNameFieldKey);
    await tester.enterText(nameFinder, name);

    Finder emailFinder = findKeyAndExpectOne(loginOrSignUpEmailFieldKey);
    await tester.enterText(emailFinder, email);

    Finder passwordFinder = findKeyAndExpectOne(loginOrSignUpPasswordFieldKey);
    await tester.enterText(passwordFinder, password);

    Finder registerButtonFinder = findKeyAndExpectOne(loginOrRegisterButtonKey);
    await tapAndSettle(tester, registerButtonFinder);

    //assert
    verify(auth.signUp(email, password, name, any)).called(1);
    verify(mockNavigatorObserver.didPop(any, any));
  });
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}
