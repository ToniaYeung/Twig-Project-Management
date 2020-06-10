import 'package:twig/models/task.dart';

class AllTasks {
  final List<Task> allTasks;

  AllTasks(this.allTasks);

  List<Task> getTasksWithStatus(String status) {
    List<Task> tasksWithStatus = allTasks.where((Task task) {
      return task.status == status;
    }).toList();

    return tasksWithStatus;
  }
}
