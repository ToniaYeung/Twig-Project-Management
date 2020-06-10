import 'package:flutter/material.dart';
import 'package:twig/common/ui/dialog_title.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';

class UserGuideDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        backgroundColor: buttonBackgroundColour,
        title: DialogTitle(title: "User Guide"),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
            side: BorderSide(color: textColour)),
        elevation: 10,
        titlePadding: EdgeInsets.all(1.0),
        content: Column(
          children: [
            Text(
              "Twig is a project management application aimed to support agile development.  It is best suited for individual or team projects that are small-medium sized.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 15.0),
            Image.asset(
              'images/bonsai.png',
            ),
            SizedBox(height: 20.0),
            Text("Sign in screen:", style: textStyle2Italic(18, textColour3)),
            SizedBox(height: 10.0),
            Text(
                "Twig users can sign in with their account credentials or update them using the forgot password functionality. If the user is not already signed in, this will be the first screen displayed on app launch.",
                textAlign: TextAlign.center),
            SizedBox(height: 20.0),
            Text("Sign up screen:", style: textStyle2Italic(18, textColour3)),
            SizedBox(height: 10.0),
            Text(
                "If the user is not yet registered, this screen is where they are able to sign up for an account. A user name, user colour, email and password are saved.",
                textAlign: TextAlign.center),
            SizedBox(height: 20.0),
            Text("Home screen:", style: textStyle2Italic(18, textColour3)),
            SizedBox(height: 10.0),
            Text(
                "This screen displays all of the projects the user has created and/or is assigned to. Users are also able to create new projects here. They also have the option to update their user colour or log out of their account. If the user is already logged in, they will automatically be brought to the home screen when the app launches.",
                textAlign: TextAlign.center),
            SizedBox(height: 20.0),
            Text("Project board:", style: textStyle2Italic(18, textColour3)),
            SizedBox(height: 10.0),
            Text(
                "The Kanban board displays all of the tasks moved to the board from the backlog for the selected project. These tasks are ready to be moved through stages of completion (‘to do’, ‘in progress’ and ‘done’) to manage and visualise project progress.",
                textAlign: TextAlign.center),
            SizedBox(height: 5.0),
            Text(
              "Clicking on a task card on the board brings up its details. A task detail dialog displays a task's name, assignee, due date and after its completion, an optional captured task photo thumbnail.",
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 5.0),
            Text("Clicking on the thumbnail enlarges the image to full-size.",
                textAlign: TextAlign.center),
            SizedBox(height: 5.0),
            Text("Double clicking a task card returns it to the backlog.",
                textAlign: TextAlign.center),
            SizedBox(height: 20.0),
            Text("Project backlog:", style: textStyle2Italic(18, textColour3)),
            SizedBox(height: 10.0),
            Text(
                "This screen displays the backlog tasks for the project, from here they can be moved to the Kanban board. The list of tasks are created by project assignees. These are tasks that will need to be completed eventually but are not currently being worked on.",
                textAlign: TextAlign.center),
            SizedBox(height: 5.0),
            Text(
                "Tapping on these tasks move it to the 'to do' section of the Kanban board.",
                textAlign: TextAlign.center),
            SizedBox(height: 5.0),
            Text("Tasks can also be added or deleted here.",
                textAlign: TextAlign.center),
            SizedBox(height: 20.0),
            Text("Project Insights:", style: textStyle2Italic(18, textColour3)),
            SizedBox(height: 10.0),
            Text(
                "This screen displays the different data visualisation available to view for the selected project. These include progress charts, milestones timeline, burn down chart and velocity tracking.",
                textAlign: TextAlign.center),
            SizedBox(height: 5.0),
            Text(
                "Visualised data makes it easier to make estimates and aids future planning in being more accurate.",
                textAlign: TextAlign.center),
            SizedBox(height: 20.0),
            Text("Project Settings:", style: textStyle2Italic(18, textColour3)),
            SizedBox(height: 10.0),
            Text(
                "Here configurations can be made for a selected project. Other users can be added to the project, a team leader can be assigned, this user guide can be read and a project can be deleted by the team leader.",
                textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 25, 5),
            child: MaterialButton(
              key: Key(userGuideDoneButtonKey),
              color: fillColour,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(28.0),
              ),
              child: Text('Done', style: textStyle2Italic(18, textColour3)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          )
        ],
      ),
    );
  }
}
