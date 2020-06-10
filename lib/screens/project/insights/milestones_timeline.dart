import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';

class Milestones extends StatelessWidget {
  final Project project;

  const Milestones(this.project);

  @override
  Widget build(BuildContext context) {
    Database database = Provider.of<Database>(context);
    return Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text(
                'Milestones',
                style: textStyleDefaultColour(25.0),
              ),
              Text(
                'Timeline',
                style: textStyleDefaultColour(25.0),
              ),
              Image.asset('images/milestones.png', height: 50),
            ],
          ),
          backgroundColor: insightsColour3,
          elevation: 15,
        ),
        backgroundColor: insightsBackgroundColour,
        body: LoadingStreamBuilder<AllTasks>(
            stream: database.getAllTasks(project.id),
            builder: (context, AllTasks allTasksStream) {
              List<Task> allTasks = allTasksStream.allTasks;

              if (allTasks.isEmpty) {
                return Center(
                    child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            gradient: LinearGradient(
                                begin: Alignment.topRight,
                                end: Alignment.bottomLeft,
                                colors: [
                                  insightsColour,
                                  insightsColour2,
                                ])),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "No tasks to display yet!",
                            style: whiteFont(30.0),
                          ),
                        )));
              }
              DateTime firstTaskDueDate = allTasks.first.dueDate;
              DateTime finalTaskDueDate = allTasks.last.dueDate;

              //Remove the time so that we can correctly get the number of days between the dates
              DateTime firstDueDateWithoutTime = DateTime(firstTaskDueDate.year,
                  firstTaskDueDate.month, firstTaskDueDate.day);
              DateTime finalDueDateWithoutTime = DateTime(finalTaskDueDate.year,
                  finalTaskDueDate.month, finalTaskDueDate.day);

              int numDaysToLastTask = finalDueDateWithoutTime
                  .difference(firstDueDateWithoutTime)
                  .inDays;

              return ListView.builder(
                itemCount: numDaysToLastTask + 1,
                itemBuilder: (context, index) {
                  DateTime date =
                      firstDueDateWithoutTime.add(Duration(days: index));

                  // Loop through all the tasks and get the ones where the due date is the
                  // same as the date we're currently evaluating
                  List<String> tasksForDay = allTasks
                      .where((task) => isSameDay(task.dueDate, date))
                      .map((task) => task.name)
                      .toList();

                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        tasksForDay.isEmpty
                            ? Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 0.0, bottom: 3.0),
                                  child: Container(
                                      height: 20,
                                      width: 5,
                                      color: insightsColour2),
                                ))
                            : Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isSameDay(date, DateTime.now())
                                        ? "Today "
                                        : formatDate(date, [dd, "/", mm, " "]),
                                    style: baseTextStyle(
                                      20,
                                      colour: insightsColour2,
                                    ),
                                  ),
                                  Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: <Color>[
                                            insightsColour2,
                                            insightsColour5
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: insightsShadowColour
                                                .withOpacity(0.5),
                                            spreadRadius: 2,
                                            blurRadius: 7,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                          children: tasksForDay
                                              .map((taskName) => Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Text("$taskName",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: whiteFont(20.0)),
                                                  ))
                                              .toList()))
                                ],
                              ),
                      ],
                    ),
                  );
                },
              );
            }));
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    //Check the number of days between the two dates is 0
    return DateTime(date1.year, date1.month, date1.day)
            .difference(DateTime(date2.year, date2.month, date2.day))
            .inDays ==
        0;
  }
}
