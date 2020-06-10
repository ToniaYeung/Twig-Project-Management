import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/assignees.dart';
import 'package:twig/models/project.dart';

import 'loading_future_builder.dart';
import 'loading_stream_builder.dart';

//A function that returns a widget, and has a parameter AllUsers
typedef AssigneesBuilder = Widget Function(Assignees);

class StreamProjectAssignees extends StatelessWidget {
  final AssigneesBuilder builder;
  final Project initialProject;

  const StreamProjectAssignees({this.builder, this.initialProject});

  //A StreamBuilder is chained with a FutureBuilder in order to get a list of users representing the assignees
  //This is done because:
  // - the list of users requires the project assignees (future builder),
  // - and the project assignees requires a project (stream builder)
  // The project is a stream of projects, as project needs to stay up to date.
  // The list of users is a future builder (a one off), as it will get called again whenever the project is updated

  @override
  Widget build(BuildContext context) {
    Database database = Provider.of<Database>(context);
    return //This means everything below (including the future builder) are built again
        LoadingStreamBuilder<Project>(
            stream: database.getProject(initialProject.id),
            //so a loading screen wont be seen, it pre loads it with a project
            initialData: initialProject,
            builder: (context, project) {
              //This gets the users associated with the ids in the assignees list
              return LoadingFutureBuilder<Assignees>(
                  future: database.getUsersFromIds(project.assignees),
                  builder: (context, allAssignees) {
                    return builder(allAssignees);
                  });
            });
  }
}
