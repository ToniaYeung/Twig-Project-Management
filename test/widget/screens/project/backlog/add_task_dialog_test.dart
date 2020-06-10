import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/project.dart';
import 'package:twig/screens/project/backlog/add_task_dialog.dart';

import '../../../../test_util.dart';
import '../../../../unit/firebase/authentication_service_test.dart';

main() {
  Project project = Project(
      "Homework", "123", ["123"], DateTime.now(), "001", DateTime.now());

  MockDatabase database;

  setUp(() {
    database = MockDatabase();
  });

  Future<void> pumpAddTaskDialog(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Database>(create: (context) {
            return database;
          })
        ],
        child: MaterialApp(
          home: Scaffold(
            body: AddTaskDialog(project),
          ),
        ),
      ),
    );
  }

  testWidgets('Name is validated', (WidgetTester tester) async {
    //setup
    String taskName = "";
    await pumpAddTaskDialog(tester);

    //action
    Finder nameMessageFinder = find.text("Please enter a name");
    expect(nameMessageFinder, findsNothing);

    Finder nameFinder = findKeyAndExpectOne(addTaskDialogNameKey);
    await tester.enterText(nameFinder, taskName);

    Finder addTaskButtonFinder = findKeyAndExpectOne(submitTaskButtonKey);
    await tapAndSettle(tester, addTaskButtonFinder);

    //assert
    Finder nameMessageFinder2 = find.text("Please enter a name");
    expect(nameMessageFinder2, findsOneWidget);
  });
}
