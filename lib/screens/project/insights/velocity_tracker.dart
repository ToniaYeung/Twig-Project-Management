import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/project.dart';
import 'package:twig/models/task.dart';
import 'package:twig/screens/project/insights/burn_down_chart.dart';

class VelocityTracker extends StatelessWidget {
  final Project project;
  const VelocityTracker(this.project);

  Widget build(BuildContext context) {
    Database database = Provider.of<Database>(context);
    return SafeArea(
      child: Scaffold(
          backgroundColor: insightsBackgroundColour,
          body: LoadingStreamBuilder<AllTasks>(
              stream: database.getAllTasks(project.id),
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
                              style: whiteFont(30),
                            ),
                          )));
                }
                // Get graph start date
                DateTime startDate = removeTime(project.creationDate);
                // Get graph end date
                DateTime endDate = removeTime(project.dueDate);
                // For every week from the start to date to the end date
                int numWeeks =
                    (endDate.difference(startDate).inDays / 7).floor();

                List<BarChartGroupData> barCharData = [];
                for (int i = 0; i < numWeeks; i++) {
                  DateTime weekStartDate = startDate.add(Duration(days: 7 * i));
                  DateTime weekEndDate =
                      startDate.add(Duration(days: 7 * (i + 1)));

                  //- Get all the completed tasks for that week
                  List<Task> completedTasks = allTasks.allTasks.where((task) {
                    if (task.movedToDone == null) {
                      return false;
                    }

                    DateTime movedToDone = removeTime(task.movedToDone);

                    // check the status is done
                    // AND (movedToDone is the same or later than weekStartDate
                    // OR before the weekEnddate
                    return task.status == "done" &&
                        (movedToDone.isAtSameMomentAs(weekStartDate) ||
                            (movedToDone.isAfter(weekStartDate) &&
                                movedToDone.isBefore(weekEndDate)));
                  }).toList();

                  //- Sum the estimation
                  double totalEstimation =
                      getTotalEstimationForTasks(completedTasks);

                  //- Divide by the number of assignees
                  double averageEstimationPerAssignee =
                      totalEstimation / project.assignees.length;
                  //- Divide by the number of working days

                  double averageEstimationPerAssigneePerDay =
                      averageEstimationPerAssignee / 5;

                  //- Create the spot
                  barCharData.add(BarChartGroupData(x: i, barRods: [
                    BarChartRodData(
                        y: averageEstimationPerAssigneePerDay,
                        color: insightsColour2)
                  ], showingTooltipIndicators: [
                    0
                  ]));
                }

                return Center(child: BarChartSample3(startDate, barCharData));
              })),
    );
  }

  double getTotalEstimationForTasks(List<Task> tasks) {
    if (tasks.isEmpty) {
      return 0;
    }
    double statusEstimationTotal = tasks
        .map((task) => task
            .estimation) // converts all the tasks to a list of integer estimations
        .reduce((sum, currentValue) =>
            sum + currentValue) // Sums all the integer estimations together
        .toDouble(); //Converts from the integer total to a double
    return statusEstimationTotal;
  }
}

class BarChartSample3 extends StatefulWidget {
  final DateTime startDate;
  final List<BarChartGroupData> barCharData;

  BarChartSample3(this.startDate, this.barCharData);

  @override
  State<StatefulWidget> createState() => BarChartSample3State();
}

class BarChartSample3State extends State<BarChartSample3> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 80, 0, 80),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(75.0),
        ),
        elevation: 15.0,
        shadowColor: insightsCardShadow,
        color: insightsCardColour,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 40.0, 8.0, 50.0),
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [insightsColour2, insightsColour5])),
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    'Average Velocity',
                    style: whiteFont(20.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Row(
                children: [
                  RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      "Average velocity/assignee/day",
                      style: textStyleBold(colour: insightsColour5),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    color: insightsColour4,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barTouchData: BarTouchData(
                          enabled: false,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBgColor: transparent,
                            tooltipPadding: const EdgeInsets.all(0),
                            tooltipBottomMargin: 8,
                            getTooltipItem: (
                              BarChartGroupData group,
                              int groupIndex,
                              BarChartRodData rod,
                              int rodIndex,
                            ) {
                              return BarTooltipItem(
                                rod.y.toStringAsPrecision(2),
                                textStyleBold(colour: insightsColour5),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: SideTitles(
                            showTitles: true,
                            textStyle: textStyleBold(
                                fontSize: 14.0, colour: insightsColour2),
                            margin: 20,
                            getTitles: (double value) {
                              DateTime weekStartDate = widget.startDate
                                  .add(Duration(days: 7 * value.toInt()));
                              return "${weekStartDate.day}/${weekStartDate.month}";
                            },
                          ),
                          leftTitles: SideTitles(showTitles: false),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        barGroups: widget.barCharData,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              "Weeks",
              style: textStyleBold(colour: insightsColour5),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                "This chart displays the average velocity of work completed by assignees per day for a week",
                style: textStyleColour(insightsColour2),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
