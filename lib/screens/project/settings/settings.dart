import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/clickable_card.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/project.dart';
import 'package:twig/screens/project/settings/add_assignees_dialog.dart';
import 'package:twig/screens/project/settings/pick_leader_dialog.dart';
import 'package:twig/screens/project/settings/user_guide_dialog.dart';

import '../../../common/ui/delete_confirmation_dialog.dart';

class Settings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Project project = Provider.of<Project>(context);
    return Scaffold(
      backgroundColor: scaffoldBackgroundColour,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SizedBox(height: 25),
            ClickableCard(
                key: Key(assigneesButtonKey),
                child: Text("Assignees", style: textStyle(22.0)),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddAssigneesDialog(project);
                      });
                }),
            SizedBox(height: 25),
            ClickableCard(
                key: Key(updateTeamLeaderButton),
                child: Text("Team Leader", style: textStyle(22.0)),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return PickLeaderDialog(project);
                      });
                }),
            SizedBox(height: 25),
            ClickableCard(
                key: Key(userGuideButtonKey),
                child: Text("User Guide", style: textStyle(22.0)),
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return UserGuideDialog();
                      });
                }),
            SizedBox(height: 25),
            Container(
              width: double.infinity,
              child: GestureDetector(
                onTap: () async {
                  //if they're the teamleader, show the confirmation  dialog
                  AuthenticationService auth =
                      Provider.of<AuthenticationService>(context);
                  FirebaseUser user = await auth.getCurrentUser();
                  String id = user.uid;
                  if (id == project.teamLeader) {
                    showDeleteConfirmationDialog(context, () {
                      Database database = Provider.of<Database>(context);
                      database.deleteProject(project.id);
                      //first pop is to close the delete dialog
                      Navigator.pop(context);

                      //second pop is to close the project and go back to the home screen
                      Navigator.pop(context);
                    });
                  } else {
                    Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                      "Must be team leader to delete project",
                      style: textStyle2Bold(13.0),
                      textAlign: TextAlign.center,
                    )));
                  }
                },
                child: Card(
                  key: Key(deleteProjectButtonKey),
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
                            image: new AssetImage('images/delete.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Text(
                          "Delete Project",
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
          ],
        ),
      ),
    );
  }
}
