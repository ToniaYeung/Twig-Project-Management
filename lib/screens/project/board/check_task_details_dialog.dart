import 'dart:io';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/loading_future_builder.dart';
import 'package:twig/firebase/storage.dart';
import 'package:twig/common/utility/stream_project_assignees.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/task.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/user.dart';

class CheckTaskDetailsDialog extends StatefulWidget {
  final Project project;
  final Task task;

  const CheckTaskDetailsDialog(this.task, this.project);

  @override
  _CheckTaskDetailsDialogState createState() => _CheckTaskDetailsDialogState();
}

class _CheckTaskDetailsDialogState extends State<CheckTaskDetailsDialog> {
  String dropdownValue;

  @override
  void initState() {
    super.initState();
    dropdownValue = widget.task.assignedTo;
  }

  @override
  Widget build(BuildContext context) {
    Storage storage = Provider.of<Storage>(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0))),
      backgroundColor: defaultYellow,
      title: Container(
        color: lightGreenDecoration,
        padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        child: Center(
          child: Text(
            widget.task.name,
            style: textStyle(22.0),
          ),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "${widget.task.description} \n",
            style: textStyle2Italic(
              17.0,
              textColour,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StreamProjectAssignees(
                initialProject: widget.project,
                builder: ((Assignees assignees) {
                  return DropdownButton<String>(
                    hint: Text("Set assignee"),
                    dropdownColor: defaultYellow,
                    focusColor: lightGreenDecoration,
                    value: dropdownValue,
                    icon: Icon(Icons.keyboard_arrow_down,
                        color: textColour, size: 20),
                    elevation: 16,
                    style: textStyle(17.0),
                    underline: Container(
                      height: 1.5,
                      color: lightGreenDecoration,
                    ),
                    onChanged: (String chosenAssignee) async {
                      setState(() {
                        dropdownValue = chosenAssignee;
                      });
                      Database database = Provider.of<Database>(context);
                      await database.updateTaskAssignee(
                          widget.project.id, widget.task.id, chosenAssignee);
                    },
                    items: assignees.users
                        //converts from a list of users into a list of dropdown menu items
                        .map<DropdownMenuItem<String>>((User assignee) {
                      return DropdownMenuItem<String>(
                        value: assignee.id,
                        child: Text(
                          assignee.name,
                          style: textStyle(20.0),
                        ),
                      );
                    }).toList(),
                  );
                }),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                alignment: Alignment.bottomRight,
                child: Text(
                  formatDate(widget.task.dueDate, [
                    dd,
                    ' ',
                    M,
                  ]),
                  style: textStyle(17.0),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          LoadingFutureBuilder<String>(
              future: storage.getTaskPhoto(widget.task.id),
              builder: (context, photoPath) {
                //if it is empty it will be true
                bool photoDoesNotExist = photoPath == "";

                return photoDoesNotExist
                    ? Container()
                    : GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return FullScreenImage(photoPath: photoPath);
                              },
                            ),
                          );
                        },
                        child: SizedBox(
                            height: 75,
                            width: 75,
                            child: Image.file(File(photoPath))),
                      );
              })
        ],
      ),
      actions: <Widget>[
        FlatButton(
          child: Text('OK'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class FullScreenImage extends StatelessWidget {
  const FullScreenImage({
    Key key,
    @required this.photoPath,
  }) : super(key: key);

  final String photoPath;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Image.file(File(photoPath)));
  }
}
