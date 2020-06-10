import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/clickable_card.dart';
import 'package:twig/common/ui/delete_confirmation_dialog.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';
import 'package:twig/screens/project/backlog/add_task_dialog.dart';

class Backlog extends StatefulWidget {
  @override
  _BacklogState createState() => _BacklogState();
}

class _BacklogState extends State<Backlog> {
  @override
  Widget build(BuildContext context) {
    Project project = Provider.of<Project>(context);
    Database database = Provider.of<Database>(context);
    return LoadingStreamBuilder<AllTasks>(
        stream: database.getAllTasks(project.id),
        builder: (context, AllTasks allTasks) {
          List<Task> backlogTasks = allTasks.getTasksWithStatus('backlog');

          return Scaffold(
            backgroundColor: scaffoldBackgroundColour,
            body: Column(
              children: <Widget>[
                SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AddTaskDialog(project);
                          });
                    },
                    child: Card(
                      key: Key(addTaskButtonKey),
                      color: buttonBackgroundColour,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: greenDecoration, width: 3.0),
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 5.0),
                        child: Column(
                          children: <Widget>[
                            new Container(
                              margin: EdgeInsets.only(top: 8.0),
                              width: 44.0,
                              height: 44.0,
                              child: Image(
                                image: new AssetImage('images/add.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Text(
                              "Add task",
                              textAlign: TextAlign.center,
                              style: textStyleItalic(22.0, colour: textColour2),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  decoration: new BoxDecoration(boxShadow: [
                    new BoxShadow(
                      color: lightGreenDecoration,
                      blurRadius: 0.5,
                    ),
                  ]),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: ListView.builder(
                      itemCount: backlogTasks.length,
                      shrinkWrap: true,
                      itemBuilder: (BuildContext context, int index) {
                        Task task = backlogTasks[index];
                        return Container(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: () {
                              //once the task status is changed to to-do the gridview builder knows that it's part of a list of tasks with to-do as the status and so it builds that list as draggables.
                              database.setTaskStatus(
                                  task, "todo", project.id, DateTime.now());
                            },
                            child: Card(
                              key: Key("${task.id}$backlogTaskCardKey"),
                              color: buttonBackgroundColour,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: greenDecoration, width: 3.0),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "${task.name} \n",
                                            style: textStyle(22.0),
                                          ),
                                          Expanded(
                                            child: Text(
                                              "\n ${task.description}",
                                              style: textStyle2Italic(
                                                17.0,
                                                textColour,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        ClickableCard(
                                          key: Key(deleteTaskButtonKey),
                                          padding: 10.0,
                                          child: Image.asset(
                                            'images/cross.png',
                                            height: 15.0,
                                          ),
                                          onTap: () {
                                            showDeleteConfirmationDialog(
                                                context, () {
                                              database.deleteTask(
                                                  project.id, task.id);
                                              Navigator.of(context).pop();
                                            });
                                          },
                                        ),
                                        Text(
                                            formatDate(
                                              task.dueDate,
                                              [
                                                dd,
                                                ' ',
                                                M,
                                              ],
                                            ),
                                            style: textStyle(17.0)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        });
  }
}
