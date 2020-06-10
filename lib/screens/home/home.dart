import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/clickable_card.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/common/utility/loading_future_builder.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/firebase/authentication_service.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_projects.dart';
import 'package:twig/models/project.dart';
import 'package:twig/common/ui/colour_picker_dialog.dart';
import 'package:twig/screens/project/base_project.dart';

import '../login/login.dart';
import 'add_project_dialog.dart';

class Home extends StatelessWidget {
  //navigation id
  static const String id = 'home_screen';

  Future<String> getUserId(AuthenticationService auth) async {
    //call authentication and get the id
    FirebaseUser user = await auth.getCurrentUser();
    String id = user.uid;
    return id;
  }

  @override
  Widget build(BuildContext context) {
    // Extracts the values from the stream and rebuilds whenever there is a change
    AuthenticationService auth = Provider.of<AuthenticationService>(context);
    Database database = Provider.of<Database>(context);
    return SafeArea(
      top: false,
      bottom: true,
      child: Scaffold(
        key: Key(homeScreenKey),
        backgroundColor: scaffoldBackgroundColour,
        appBar: AppBar(
          backgroundColor: appBarColour,
          elevation: 7.0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LoadingFutureBuilder<String>(
                future: getUserId(auth),
                builder: (context, id) {
                  return LoadingStreamBuilder<Color>(
                      stream: database.getUserColour(id),
                      builder: (context, userColour) {
                        return FlatButton(
                          key: Key(userColourButtonKey),
                          child: Container(
                            height: 40.0,
                            width: 40.0,
                            decoration: BoxDecoration(
                              color: userColour,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: greenDecoration,
                                  width: 2.0,
                                  style: BorderStyle.solid),
                            ),
                          ),
                          onPressed: () async {
                            //The ColourPickerDialog returns a Color object of the colour chosen by the user when it pops, which we then save in colorPicked
                            Color colourPicked = await showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ColourPickerDialog(userColour);
                                });
                            //prevents the colour being updated with null if the dialog is clicked off
                            if (colourPicked != null) {
                              database.updateUserColour(id, colourPicked);
                            }
                          },
                        );
                      });
                },
              ),
              Image.asset(
                'images/twig.png',
                fit: BoxFit.contain,
                height: 65,
              ),
              FlatButton(
                key: Key(logOutButtonKey),
                child: Container(
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: buttonBackgroundColour,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: greenDecoration,
                        width: 2.0,
                        style: BorderStyle.solid),
                  ),
                  child: Text(
                    "Log out",
                    style: baseTextStyle(19.0, colour: textColour2),
                  ),
                ),
                onPressed: () async {
                  await auth.logOut();
                  Navigator.pushReplacement(
                    context,
                    //page transition
                    MaterialPageRoute(
                      builder: (context) {
                        return Login();
                      },
                    ),
                  );
                },
              ),
            ],
          ),
          centerTitle: true,
        ),
        body: LoadingFutureBuilder<FirebaseUser>(
          future: auth.getCurrentUser(),
          builder: (context, user) {
            return LoadingStreamBuilder<AllProjects>(
                stream: database.getAllProjects(user.uid),
                builder: (context, AllProjects allProjects) {
                  return Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(
                            top: 9.0, bottom: 10.0, left: 115.0, right: 115.0),
                        width: double.infinity,
                        child: GestureDetector(
                          key: Key(newProjectButtonKey),
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AddProjectDialog();
                                });
                          },
                          child: Card(
                            color: buttonBackgroundColour,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: greenDecoration, width: 3.0),
                              borderRadius: BorderRadius.circular(10.0),
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
                                      image:
                                          new AssetImage('images/addnew.png'),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Text(
                                    "New Project",
                                    textAlign: TextAlign.center,
                                    style: textStyleItalic(22.0,
                                        colour: textColour2),
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
                      Expanded(
                        child: ListView.builder(
                          //ListView only occupies the space it needs
                          shrinkWrap: true,
                          itemCount: allProjects.allProjects.length,
                          //rather than creating the widgets manually, using ListView builder creates them for us.
                          itemBuilder: (BuildContext context, int index) {
                            //for each item count, create this container

                            return Padding(
                              child: ClickableCard(
                                key: Key(
                                    "${allProjects.allProjects[index].name}$projectCardKey"),
                                child: Text(
                                  allProjects.allProjects[index].name,
                                  style: textStyle(22.0),
                                ),
                                onTap: () {
                                  //push a new page
                                  Navigator.push(
                                    context,
                                    //page transition
                                    MaterialPageRoute(builder: (context) {
                                      //project card has project variables
                                      Project project =
                                          allProjects.allProjects[index];
                                      return StreamProvider<Project>.value(
                                          //value is the stream
                                          value:
                                              database.getProject(project.id),
                                          initialData: project,
                                          child: BaseProject());
                                    }),
                                  );
                                },
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: 30,
                                horizontal: 18,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
