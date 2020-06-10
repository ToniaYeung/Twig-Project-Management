import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/dialog_title.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';
import 'package:uuid/uuid.dart';

class AddTaskDialog extends StatefulWidget {
  final Project project;

  const AddTaskDialog(this.project);

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  //allows access to manipulate the form, e.g: validate the form
  //a key of formstate type is used to get the state of the form
  final _formKey = GlobalKey<FormState>();
  String _name;
  String _description;
  int _estimation;
  DateTime _dueDate;

  @override
  //override the stateful widgets original initState
  void initState() {
    //still want parent class to run initState
    super.initState();
    _dueDate = DateTime.now();
    _estimation = 1;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      key: Key(addTaskDialogKey),
      title: DialogTitle(title: "New Task"),
      backgroundColor: buttonBackgroundColour,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: textColour)),
      elevation: 10,
      titlePadding: EdgeInsets.all(1.0),
      children: <Widget>[
        Form(
          //setting the key
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, bottom: 18.0),
                child: TextFormField(
                  key: Key(addTaskDialogNameKey),
                  onChanged: (String value) {
                    _name = value;
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      return "Please enter a name";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Task name',
                    labelStyle: textStyle(19.0),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 18.0, right: 18.0, bottom: 18.0),
                child: TextFormField(
                  key: Key(addTaskDialogDescriptionKey),
                  onChanged: (String value) {
                    _description = value;
                  },
                  decoration: InputDecoration(
                    labelText: 'Task description',
                    labelStyle: textStyle(19.0),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Difficulty estimation", style: defaultTextStyle),
                  IconButton(
                    icon: Icon(Icons.remove, color: textColour),
                    onPressed: () {
                      if (_estimation > 1) {
                        setState(() {
                          _estimation--;
                        });
                      }
                    },
                  ),
                  Text(_estimation.toString(), style: defaultTextStyle),
                  IconButton(
                    icon: Icon(Icons.add, color: textColour),
                    onPressed: () {
                      if (_estimation < 10) {
                        setState(() {
                          _estimation++;
                        });
                      }
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Due date", style: defaultTextStyle),
                  RaisedButton(
                    color: lightGreenDecoration,
                    child: Text(formatDate(_dueDate, [dd, ' ', M, ' ', yyyy]),
                        style: defaultTextStyle),
                    onPressed: () async {
                      DateTime now = DateTime.now();

                      //code knows not to go any further until they pick a date
                      DateTime picked = await showDatePicker(
                        context: context,
                        initialDate: now,
                        firstDate: now,
                        lastDate: DateTime(2100, 1, 1),
                      );
                      //if there is a value in picked, then set _dueDate to picked
                      if (picked != null) {
                        setState(() {
                          _dueDate = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              FlatButton(
                key: Key(submitTaskButtonKey),
                color: transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(60.0),
                ),
                child: Image(
                  image: new AssetImage('images/add.png'),
                  fit: BoxFit.cover,
                ),
                onPressed: () async {
                  //validates everything in the form

                  if (_formKey.currentState.validate()) {
                    Uuid uuid = Uuid();
                    final id = uuid.v4();
                    Task task = Task(
                        _name,
                        id,
                        //do this but if its null return empty string
                        _description ?? "",
                        "backlog",
                        _estimation,
                        _dueDate,
                        null,
                        null,
                        null);
                    Database database = Provider.of<Database>(context);
                    await database.addTask(task, widget.project.id);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
