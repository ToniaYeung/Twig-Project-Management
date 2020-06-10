import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/dialog_title.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/stream_project_assignees.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/user.dart';

class PickLeaderDialog extends StatefulWidget {
  final Project project;

  const PickLeaderDialog(this.project);

  @override
  _PickLeaderDialogState createState() => _PickLeaderDialogState();
}

class _PickLeaderDialogState extends State<PickLeaderDialog> {
  bool showErrorMessage = false;
  @override
  Widget build(BuildContext context) {
    AuthenticationService auth = Provider.of<AuthenticationService>(context);
    return StreamProjectAssignees(
      initialProject: widget.project,
      builder: ((Assignees assignees) {
        return SimpleDialog(
          backgroundColor: buttonBackgroundColour,
          title: DialogTitle(title: "Team Leader"),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
              side: BorderSide(color: textColour)),
          elevation: 10,
          titlePadding: EdgeInsets.all(1.0),
          children: <Widget>[
            Container(
              width: double.maxFinite,
              child: ListView.builder(
                itemCount: assignees.users.length,
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  User user = assignees.users[index];

                  return Container(
                    child: GestureDetector(
                      onTap: () async {
                        FirebaseUser currentUser = await auth.getCurrentUser();
                        // if they're not the current team leader,
                        // don't update and show an error message
                        if (currentUser.uid == widget.project.teamLeader) {
                          Database database = Provider.of<Database>(context);
                          await database.updateTeamLeader(
                              user.id, widget.project.id);
                          Navigator.pop(context);
                        } else {
                          setState(() {
                            showErrorMessage = true;
                          });
                        }
                      },
                      child: Container(
                          color: widget.project.teamLeader == user.id
                              ? lightGreenDecoration
                              : buttonBackgroundColour,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 10.0),
                            child: Text(user.name),
                          )),
                    ),
                  );
                },
              ),
            ),
            showErrorMessage
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 5),
                    child: Text(
                      "Only the current team leader can update this",
                      style: baseTextStyle2(13.0, colour: textColour4),
                      textAlign: TextAlign.center,
                    ),
                  )
                : Container(),
          ],
        );
      }),
    );
  }
}
