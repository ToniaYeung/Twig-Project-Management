import 'package:test/test.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/task.dart';

void main() {
  //testing getTasksWithStatus(String status);
  test(
      'For tasks that are returned, they should return with the correct status',
      () async {
    // setup
    List<Task> tasks = [
      Task('task1', null, null, 'backlog', null, null, null, null, null),
      Task('task2', null, null, 'to do', null, null, null, null, null),
      Task('task3', null, null, 'in progress', null, null, null, null, null),
      Task('task4', null, null, 'backlog', null, null, null, null, null)
    ];
    AllTasks allTasks = AllTasks(tasks);

    // action
    List<Task> backlogTasks = allTasks.getTasksWithStatus("backlog");

    // assert
    expect(backlogTasks.length, equals(2));
    expect(backlogTasks[0].name, equals("task1"));
    expect(backlogTasks[1].name, equals("task4"));
  });

  test('When there are no tasks of a status, it returns an empty list',
      () async {
    // setup
    List<Task> tasks = [
      Task('task1', null, null, 'backlog', null, null, null, null, null),
      Task('task3', null, null, 'in progress', null, null, null, null, null),
      Task('task4', null, null, 'backlog', null, null, null, null, null)
    ];
    AllTasks allTasks = AllTasks(tasks);

    // action
    List<Task> todoTasks = allTasks.getTasksWithStatus("to do");

    // assert
    expect(todoTasks.length, equals(0));
  });

  test('When there are no tasks in all tasks, it returns an empty list',
      () async {
    // setup
    List<Task> tasks = [];
    AllTasks allTasks = AllTasks(tasks);

    // action
    List<Task> todoTasks = allTasks.getTasksWithStatus("to do");

    // assert
    expect(todoTasks.length, equals(0));
  });
}
