import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/task.dart';

class TaskProgressChart extends StatelessWidget {
  final String projectId;

  const TaskProgressChart(this.projectId);

  @override
  Widget build(BuildContext context) {
    Database database = Provider.of<Database>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: insightsBackgroundColour,
        body: LoadingStreamBuilder<AllTasks>(
            stream: database.getAllTasks(projectId),
            builder: (context, AllTasks allTasks) {
              if (allTasks.allTasks.isEmpty) {
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
                            style: baseTextStyle(
                              30,
                              colour: whiteColour,
                            ),
                          ),
                        )));
              }
              return Padding(
                padding: const EdgeInsets.all(15.0),
                child: Wrap(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(75.0),
                      ),
                      elevation: 15.0,
                      shadowColor: insightsCardShadow,
                      color: insightsCardColour,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          SizedBox(height: 1),
                          Text(
                            "Progress Charts",
                            style: defaultItalic(20.0),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 6.0, right: 5),
                                child: Text(
                                  "Progress \n by status",
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              PieChart(PieChartData(
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 5,
                                centerSpaceRadius: 40,
                                sections:
                                    createSectionsByNumberOfTasks(allTasks),
                              )),
                            ],
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 150.0, top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LegendItem(insightsColour7, "Backlog"),
                                LegendItem(insightsColour6, "To-do"),
                                LegendItem(insightsColour, "In progress"),
                                LegendItem(insightsColour5, "Done"),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                "Progress \n by \n difficulty \n estimation",
                                textAlign: TextAlign.center,
                              ),
                              PieChart(PieChartData(
                                borderData: FlBorderData(show: false),
                                sectionsSpace: 5,
                                centerSpaceRadius: 40,
                                sections: createSectionsByEstimation(allTasks),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
      ),
    );
  }

  List<PieChartSectionData> createSectionsByNumberOfTasks(AllTasks allTasks) {
    double backlogTotal = getTotalNumberOfTasksForStatus("backlog", allTasks);
    double toDoTotal = getTotalNumberOfTasksForStatus("todo", allTasks);
    double inProgressTotal =
        getTotalNumberOfTasksForStatus("in progress", allTasks);
    double doneTotal = getTotalNumberOfTasksForStatus("done", allTasks);

    return _createSections(backlogTotal, toDoTotal, inProgressTotal, doneTotal);
  }

  List<PieChartSectionData> createSectionsByEstimation(AllTasks allTasks) {
    double backlogTotal = getTotalEstimationForStatus("backlog", allTasks);
    double toDoTotal = getTotalEstimationForStatus("todo", allTasks);
    double inProgressTotal =
        getTotalEstimationForStatus("in progress", allTasks);
    double doneTotal = getTotalEstimationForStatus("done", allTasks);

    return _createSections(backlogTotal, toDoTotal, inProgressTotal, doneTotal);
  }

  List<PieChartSectionData> _createSections(double backlogTotal,
      double toDoTotal, double inProgressTotal, double doneTotal) {
    List<PieChartSectionData> sections = [];
    if (backlogTotal != 0) {
      sections.add(_createPieChartSection(backlogTotal, insightsColour7));
    }
    if (toDoTotal != 0) {
      sections.add(_createPieChartSection(toDoTotal, insightsColour6));
    }
    if (inProgressTotal != 0) {
      sections.add(_createPieChartSection(inProgressTotal, insightsColour));
    }
    if (doneTotal != 0) {
      sections.add(_createPieChartSection(doneTotal, insightsColour5));
    }

    return sections;
  }

  double getTotalEstimationForStatus(String status, AllTasks allTasks) {
    List<Task> tasksWithStatus = allTasks.getTasksWithStatus(status);
    if (tasksWithStatus.isEmpty) {
      return 0;
    }
    double statusEstimationTotal = tasksWithStatus
        .map((task) => task
            .estimation) // converts all the tasks to a list of integer estimations
        .reduce((sum, currentValue) =>
            sum + currentValue) // Sums all the integer estimations together
        .toDouble(); //Converts from the integer total to a double
    return statusEstimationTotal;
  }

  double getTotalNumberOfTasksForStatus(String status, AllTasks allTasks) {
    List<Task> tasksWithStatus = allTasks.getTasksWithStatus(status);
    return tasksWithStatus.length.toDouble();
  }

  PieChartSectionData _createPieChartSection(
      double estimationTotal, Color color) {
    return PieChartSectionData(
      color: color,
      value: estimationTotal,
      title: estimationTotal
          .toInt()
          .toString(), // convert to int so it says e.g. 9 instead of 9.0
      radius: 50,
    );
  }
}

class LegendItem extends StatelessWidget {
  final Color colour;
  final String taskStatus;

  const LegendItem(this.colour, this.taskStatus);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 16,
          width: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colour,
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        Text(
          taskStatus,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
