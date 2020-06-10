import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';

import 'check_task_details_dialog.dart';

//Typedef gives a function definition a name, so we can use it as a type
typedef OnAccept = void Function(Task);

class TaskGrid extends StatelessWidget {
  final List<Task> tasks;
  final Project project;
  final String title;
  final OnAccept onAccept;
  final Assignees assignees;

  const TaskGrid({
    Key key,
    @required this.tasks,
    @required this.project,
    @required this.title,
    @required this.onAccept,
    @required this.assignees,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: <Widget>[
          Container(
              width: 100.0,
              height: double.infinity,
              child: Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textStyle(18.0),
                ),
              ),
              decoration: boxDecoration),
          Expanded(
            child: DragTarget(
                builder: (context, candidate, rejected) {
                  return Container(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5),
                        itemCount: tasks.length,
                        itemBuilder: (BuildContext context, int index) {
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return CheckTaskDetailsDialog(
                                      tasks[index], project);
                                },
                              );
                            },
                            onDoubleTap: () {
                              Database database =
                                  Provider.of<Database>(context);
                              database.setTaskStatus(tasks[index], "backlog",
                                  project.id, DateTime.now());
                            },
                            child: Draggable(
                              data: tasks[index],
                              //what it looks like whilst its dragging
                              feedback: Container(
                                height: 70,
                                width: 70,
                                decoration: new BoxDecoration(
                                  boxShadow: <BoxShadow>[
                                    new BoxShadow(
                                      color: shadowColour,
                                      blurRadius: 10.0,
                                      offset: new Offset(0.0, 1.0),
                                    ),
                                  ],
                                ),
                                child: Card(
                                  color: Color(assignees
                                      .getColour(tasks[index].assignedTo)),
                                  child: Text(tasks[index].name,
                                      textAlign: TextAlign.center,
                                      style: textStyleColour(
                                        textColour,
                                      )),
                                ),
                              ),
                              //what it looks like at rest
                              child: Container(
                                decoration: new BoxDecoration(
                                  boxShadow: <BoxShadow>[
                                    new BoxShadow(
                                      color: shadowColour,
                                      blurRadius: 10.0,
                                      offset: new Offset(0.0, 1.0),
                                    ),
                                  ],
                                ),
                                child: Card(
                                  color: Color(
                                    assignees
                                        .getColour(tasks[index].assignedTo),
                                  ),
                                  child: Container(
                                    child: Text(tasks[index].name,
                                        textAlign: TextAlign.center,
                                        style: textStyleColour(
                                          textColour,
                                        )),
                                  ),
                                ),
                              ),
                              childWhenDragging: Container(),
                            ),
                          );
                        }),
                    decoration: boxDecoration,
                  );
                },
                onWillAccept: (data) => true,
                // handling successful landings
                onAccept: onAccept),
          ),
        ],
      ),
    );
  }
}

final BoxDecoration boxDecoration = BoxDecoration(
    color: lightGreenDecoration,
    border: Border.all(width: 1.75, color: greenDecoration));
