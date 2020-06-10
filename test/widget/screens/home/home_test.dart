import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_projects.dart';
import 'package:twig/models/project.dart';
import 'package:twig/screens/home/home.dart';

import '../../../test_util.dart';
import '../../../unit/firebase/authentication_service_test.dart';

main() {
  MockDatabase database;
  MockAuthenticationService auth;
  setUp(() {
    database = MockDatabase();
    auth = MockAuthenticationService();
  });

  Future<void> pumpHomeScreen(WidgetTester tester) async {
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
            body: Home(),
          ),
        ),
      ),
    );
  }

  testWidgets('User colour is the correct one', (WidgetTester tester) async {
    //setup
    MockFirebaseUser firebaseUser = MockFirebaseUser();
    when(auth.getCurrentUser()).thenAnswer((_) => Future.value(firebaseUser));
    String userId = "any";
    Color colour = Colors.yellow;
    when(firebaseUser.uid).thenReturn(userId);
    when(database.getUserColour(userId))
        .thenAnswer((_) => Stream.value(colour));

    //action
    await pumpHomeScreen(tester);
    await tester.pump();
    await tester.pump();

    //assert
    Finder userColourButtonFinder = findKeyAndExpectOne(userColourButtonKey);
    FlatButton userColourButton = tester.firstWidget(userColourButtonFinder);
    Container userColourContainer = userColourButton.child as Container;
    BoxDecoration decoration = userColourContainer.decoration as BoxDecoration;
    expect(decoration.color, equals(colour));
  });

  testWidgets('Log out button logs them out', (WidgetTester tester) async {
    //setup
    //action
    await pumpHomeScreen(tester);

    //assert
    Finder logOutButtonKeyFinder = find.byKey(Key(logOutButtonKey));
    await tapAndSettle(tester, logOutButtonKeyFinder);
    verify(auth.logOut()).called(1);
  });

  testWidgets('Clicking on a project goes to the project screen',
      (WidgetTester tester) async {
    //setup
    MockFirebaseUser firebaseUser = MockFirebaseUser();
    when(auth.getCurrentUser()).thenAnswer((_) => Future.value(firebaseUser));
    String userId = "any";
    Project project = Project(
        "Homework", "123", ["123"], DateTime.now(), "001", DateTime.now());
    Color colour = Colors.yellow;
    when(firebaseUser.uid).thenReturn(userId);
    when(database.getUserColour(userId))
        .thenAnswer((_) => Stream.value(colour));
    when(database.getAllProjects(userId))
        .thenAnswer((_) => Stream.value(AllProjects([project])));
    when(database.getProject(project.id))
        .thenAnswer((_) => Stream.value(project));

    //action
    await pumpHomeScreen(tester);
    await tester.pumpAndSettle();

    Finder projectCard = find.byKey(Key("${project.name}$projectCardKey"));
    await tester.tap(projectCard);
    await tester.pump();
    await tester.pump();

    //assert
    findKeyAndExpectOne(baseProjectKey);
  });
}

class MockAuthenticationService extends Mock implements AuthenticationService {}
