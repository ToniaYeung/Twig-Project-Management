import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';
import 'package:twig/screens/project/backlog/backlog.dart';

import '../../../../test_util.dart';
import '../../../../unit/firebase/authentication_service_test.dart';

main() {
  Project project = Project(
      "Homework", "123", ["123"], DateTime.now(), "001", DateTime.now());

  MockDatabase database;
  setUp(() {
    database = MockDatabase();
  });

  Future<void> pumpBacklogScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<Project>(create: (context) {
            return project;
          }),
          Provider<Database>(create: (context) {
            return database;
          })
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Backlog(),
          ),
        ),
      ),
    );
  }

  testWidgets('All backlog tasks have a card displayed',
      (WidgetTester tester) async {
    //setup
    List<Task> tasks = [
      Task("Task1", "1", "", "in progress", 1, DateTime.now(), "456",
          DateTime.now(), DateTime.now()),
      Task("Task2", "2", "", "backlog", 1, DateTime.now(), "456",
          DateTime.now(), DateTime.now()),
      Task("Task3", "3", "", "backlog", 1, DateTime.now(), "456",
          DateTime.now(), DateTime.now()),
    ];
    when(database.getAllTasks(project.id))
        .thenAnswer((_) => Stream.value(AllTasks(tasks)));

    //action
    await pumpBacklogScreen(tester);
    await tester.pumpAndSettle();

    // assert
    findKeyAndExpectOne("2$backlogTaskCardKey");
    findKeyAndExpectOne("3$backlogTaskCardKey");
  });

  testWidgets('Tap add task opens add task dialog',
      (WidgetTester tester) async {
    //setup
    when(database.getAllTasks(project.id))
        .thenAnswer((_) => Stream.value(AllTasks([])));

    //action
    await pumpBacklogScreen(tester);
    await tester.pumpAndSettle();

    findKeyAndExpectNothing(addTaskDialogKey);

    Finder addTaskButtonFinder = find.byKey(Key(addTaskButtonKey));
    await tapAndSettle(tester, addTaskButtonFinder);

    // assert
    findKeyAndExpectOne(addTaskDialogKey);
  });

  testWidgets(
      'Delete a task opens dialog and if press yes, tries to delete the task',
      (WidgetTester tester) async {
    //setup
    List<Task> tasks = [
      Task("Task1", "1", "", "backlog", 1, DateTime.now(), "456",
          DateTime.now(), DateTime.now()),
    ];
    when(database.getAllTasks(project.id))
        .thenAnswer((_) => Stream.value(AllTasks(tasks)));

    //action
    await pumpBacklogScreen(tester);
    await tester.pumpAndSettle();

    Finder deleteTaskFinder = find.byKey(Key(deleteTaskButtonKey));
    await tapAndSettle(tester, deleteTaskFinder);

    Finder deleteYesButtonFinder = find.byKey(Key(deleteYesButtonKey));
    await tapAndSettle(tester, deleteYesButtonFinder);

    //assert
    verify(database.deleteTask(project.id, tasks[0].id)).called(1);
  });

  testWidgets(
      'Delete a task opens dialog and if press no, does not delete task',
      (WidgetTester tester) async {
    //setup
    List<Task> tasks = [
      Task("Task1", "1", "", "backlog", 1, DateTime.now(), "456",
          DateTime.now(), DateTime.now()),
    ];
    when(database.getAllTasks(project.id))
        .thenAnswer((_) => Stream.value(AllTasks(tasks)));

    //action
    await pumpBacklogScreen(tester);
    await tester.pumpAndSettle();

    Finder deleteTaskFinder = find.byKey(Key(deleteTaskButtonKey));
    await tapAndSettle(tester, deleteTaskFinder);

    Finder deleteCancelButtonFinder = find.byKey(Key(deleteCancelButtonKey));
    await tapAndSettle(tester, deleteCancelButtonFinder);

    //assert
    verifyNever(database.deleteTask(project.id, tasks[0].id));
  });

  testWidgets('Tapping a task moves it to to-do', (WidgetTester tester) async {
    //setup
    List<Task> tasks = [
      Task("Task1", "1", "", "backlog", 1, DateTime.now(), "456",
          DateTime.now(), DateTime.now()),
    ];
    when(database.getAllTasks(project.id))
        .thenAnswer((_) => Stream.value(AllTasks(tasks)));

    //action
    await pumpBacklogScreen(tester);
    await tester.pumpAndSettle();

    Finder backlogTaskCardKeyFinder =
        find.byKey(Key("${tasks[0].id}$backlogTaskCardKey"));
    await tapAndSettle(tester, backlogTaskCardKeyFinder);

    //assert
    verify(database.setTaskStatus(tasks[0], "todo", project.id, any)).called(1);
  });
}
