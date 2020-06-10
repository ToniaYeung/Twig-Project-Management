import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/dialog_title.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/common/utility/loading_future_builder.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/user.dart';

import '../../../common/ui/delete_confirmation_dialog.dart';

class AddAssigneesDialog extends StatefulWidget {
  final Project project;

  const AddAssigneesDialog(this.project);

  @override
  _AddAssigneesDialogState createState() => _AddAssigneesDialogState();
}

class _AddAssigneesDialogState extends State<AddAssigneesDialog> {
  final _formKey = GlobalKey<FormState>();
  String email;
  bool showErrorMessage = false;
  TextEditingController emailController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    Database database = Provider.of<Database>(context);
    return SimpleDialog(
      backgroundColor: buttonBackgroundColour,
      title: DialogTitle(title: "Assignees"),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
          side: BorderSide(color: textColour)),
      elevation: 10,
      titlePadding: EdgeInsets.all(1.0),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 5),
          child: Form(
            key: _formKey,
            child: TextFormField(
              key: Key(addAssigneesEmailKey),
              controller: emailController,
              onChanged: (value) {
                email = value;
              },
              // Matches the email value with the regular expression. If there is a match then it is a valid email, else it is not
              validator: (value) =>
                  RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+.[a-zA-Z]+")
                          .hasMatch(value)
                      ? null
                      : 'Please enter a valid email',
              keyboardType: TextInputType.emailAddress,
              autofocus: false,
              decoration: new InputDecoration(
                fillColor: fillColour,
                filled: true,
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Image.asset(
                    'images/email.png',
                    width: 20,
                    height: 20,
                    fit: BoxFit.fill,
                  ),
                ),
                hintText: 'Email',
                hintStyle: hintStyle,
                contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: whiteColour,
                  ),
                  borderRadius: BorderRadius.circular(32.0),
                ),
              ),
            ),
          ),
        ),
        showErrorMessage
            ? Center(
                child: Text(
                  "This user does not exist",
                  style: textStyle2Bold(13.0, colour: textColour4),
                  textAlign: TextAlign.center,
                ),
              )
            : Container(),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0),
          child: Material(
            borderRadius: BorderRadius.circular(30.0),
            color: buttonBackgroundColour,
            child: Padding(
              padding: EdgeInsets.fromLTRB(100.0, 0, 100.0, 0.0),
              child: MaterialButton(
                key: Key(inviteAssigneeButtonKey),
                shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(28.0),
                ),
                minWidth: 200.0,
                height: 50.0,
                onPressed: () async {
                  if (_formKey.currentState.validate()) {
                    try {
                      await database.addAssigneeToProject(
                          email, widget.project.id);
                      //if it adds, then exception wont be thrown
                      // so clear and set state can happen
                      emailController.clear();
                      setState(() {
                        showErrorMessage = false;
                      });
                    } on EmailDoesNotExistException catch (_) {
                      setState(() {
                        showErrorMessage = true;
                      });
                    }
                  }
                },
                color: lightGreenDecoration,
                child: Text(
                  'Invite',
                  style: textStyleColour(textColour),
                ),
              ),
            ),
          ),
        ),

        //Listens to the project and updates when there is a change
        //This means  everything below (including the loadingfuturebuilder) are built again
        LoadingStreamBuilder<Project>(
            stream: database.getProject(widget.project.id),
            initialData: widget.project,
            builder: (context, project) {
              //This gets the users associated with the ids in the assignees list
              return LoadingFutureBuilder<Assignees>(
                  future: database.getUsersFromIds(project.assignees),
                  builder: (context, allUsers) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Container(
                        height: 200,
                        width: double.maxFinite,
                        child: ListView.builder(
                          itemCount: allUsers.users.length,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            User assignee = allUsers.users[index];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                    color: whiteColour,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20))),
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "${assignee.name} ",
                                        style: textStyle(20.0),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "(${assignee.email})",
                                          textAlign: TextAlign.center,
                                          style: textStyle2DefaultColour(16.0),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDeleteConfirmationDialog(context,
                                              () {
                                            database.deleteAssigneeFromProject(
                                                project.id, assignee.id);
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        child: Card(
                                          key: Key(deleteAssigneeButtonKey),
                                          color: buttonBackgroundColour,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: lightGreenDecoration,
                                                width: 3.0),
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.all(10.0),
                                            child: Center(
                                              child: Image.asset(
                                                'images/cross.png',
                                                height: 15.0,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  });
            })
      ],
    );
  }
}
