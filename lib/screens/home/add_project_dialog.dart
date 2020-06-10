import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/dialog_title.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/project.dart';
import 'package:uuid/uuid.dart';

class AddProjectDialog extends StatefulWidget {
  @override
  _AddProjectDialogState createState() => _AddProjectDialogState();
}

class _AddProjectDialogState extends State<AddProjectDialog> {
  //a key of formstate type is used to get the state of the form
  //allows me to access and manipulate the form, e.g: validate the form
  final _formKey = GlobalKey<FormState>();
  String _name;
  DateTime _dueDate;

  @override
  //override the stateful widgets original initState
  void initState() {
    //still want parent class to run initState
    super.initState();
    _dueDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: DialogTitle(title: "New Project"),
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
                  key: Key(newProjectNameFieldKey),
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
                    labelText: 'Project name',
                    labelStyle: textStyle(19.0),
                  ),
                  keyboardType: TextInputType.text,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Due date", style: defaultTextStyle),
                  RaisedButton(
                    color: lightGreenDecoration,
                    child: Text(formatDate(_dueDate, [dd, ' ', MM, ' ', yyyy]),
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
                  key: Key(newProjectSubmitButtonKey),
                  color: transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(60.0),
                  ),
                  child: Image(
                    image: new AssetImage(
                      'images/addnew.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState.validate()) {
                      //set leader to current user
                      AuthenticationService auth =
                          Provider.of<AuthenticationService>(context);
                      FirebaseUser currentUser = await auth.getCurrentUser();
                      final teamLeader = currentUser.uid;
                      Uuid uuid = Uuid();
                      final projectId = uuid.v4();
                      Project project = Project(
                        _name,
                        teamLeader,
                        [teamLeader],
                        _dueDate,
                        projectId,
                        DateTime.now(),
                      );
                      Database database = Provider.of<Database>(context);
                      await database.addProject(project);
                      Navigator.pop(context);
                    }
                  }),
            ],
          ),
        ),
      ],
    );
  }
}
