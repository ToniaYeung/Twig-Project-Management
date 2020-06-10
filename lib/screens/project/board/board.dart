import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/common/utility/stream_project_assignees.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';
import 'package:twig/screens/project/board/camera_screen.dart';
import 'package:twig/screens/project/board/picture_confirmation_dialog.dart';
import 'package:twig/screens/project/board/task_grid.dart';

class Board extends StatefulWidget {
  @override
  _BoardState createState() => _BoardState();
}

class _BoardState extends State<Board> {
  @override
  Widget build(BuildContext context) {
    Project project = Provider.of<Project>(context);
    Database database = Provider.of<Database>(context);
    return LoadingStreamBuilder<AllTasks>(
        stream: database.getAllTasks(project.id),
        builder: (context, AllTasks allTasks) {
          List<Task> todoTasks = allTasks.getTasksWithStatus('todo');
          List<Task> inProgressTasks =
              allTasks.getTasksWithStatus('in progress');
          List<Task> doneTasks = allTasks.getTasksWithStatus('done');

          //build kanban board
          return Scaffold(
            backgroundColor: scaffoldBackgroundColour,
            body: StreamProjectAssignees(
                initialProject: project,
                builder: (Assignees assignees) {
                  return Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: greenDecoration),
                              gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [greenDecoration, gradientYellow])),
                          width: 500.0,
                          height: 50.0,
                          margin: new EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
                          child: Center(
                            child: Text(
                              project.name,
                              style: textStyle(22.0),
                            ),
                          ),
                        ),
                      ),
                      TaskGrid(
                          title: "To-do",
                          tasks: todoTasks,
                          project: project,
                          assignees: assignees,
                          onAccept: (Task task) {
                            database.setTaskStatus(
                                task, "todo", project.id, DateTime.now());
                          }),
                      TaskGrid(
                          title: "In \n Progress",
                          tasks: inProgressTasks,
                          project: project,
                          assignees: assignees,
                          onAccept: (Task task) {
                            database.setTaskStatus(task, "in progress",
                                project.id, DateTime.now());
                          }),
                      TaskGrid(
                          title: "Done",
                          tasks: doneTasks,
                          project: project,
                          assignees: assignees,
                          onAccept: (Task task) {
                            showPictureConfirmationDialog(context, () async {
                              await Navigator.push(
                                context,
                                //page transition
                                MaterialPageRoute(
                                  builder: (context) {
                                    return (CameraScreenLoader(task.id));
                                  },
                                ),
                              );
                              Navigator.pop(context);
                            });

                            database.setTaskStatus(
                                task, "done", project.id, DateTime.now());
                          }),
                    ],
                  );
                }),
          );
        });
  }
}
