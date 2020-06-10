import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/loading_stream_builder.dart';
import 'package:twig/firebase/database.dart';
import 'package:twig/models/all_tasks.dart';
import 'package:twig/models/task.dart';
import 'package:twig/screens/project/insights/task_progress_chart.dart';

class BurnDownChart extends StatelessWidget {
  final String projectId;
  const BurnDownChart(this.projectId);

  @override
  Widget build(BuildContext context) {
    Database database = Provider.of<Database>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: insightsBackgroundColour,
        body: LoadingStreamBuilder<AllTasks>(
            stream: database.getAllTasks(projectId),
            builder: (context, AllTasks allTasksStream) {
              List<Task> allTasks = allTasksStream.allTasks;
              //where this function evaluated to true, put it in board tasks
              List<Task> boardTasks = allTasks.where((task) {
                return task.movedToToDo != null;
              }).toList();

              if (boardTasks.isEmpty) {
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
              // Sorts the board tasks based on the task's movedToToDo field
              boardTasks.sort((task1, task2) {
                //compareTo sorts it form earliest to latest
                return task1.movedToToDo.compareTo(task2.movedToToDo);
              });
              DateTime firstDate = removeTime(boardTasks.first.movedToToDo);
              DateTime today = removeTime(DateTime.now());

              int numDaysFromFirstDateToNow =
                  today.difference(firstDate).inDays;

              List<FlSpot> numberOfTasksSpots = [];
              List<FlSpot> estimationValueSpots = [];

              //i = x axis dates
              for (int i = 0; i < numDaysFromFirstDateToNow + 1; i++) {
                //Get the date to calculate on
                DateTime date = removeTime(firstDate.add(Duration(days: i)));

                // find all tasks on board for the date
                List<Task> toDoTasksForDate = boardTasks.where((task) {
                  DateTime movedToToDo = removeTime(task.movedToToDo);
                  return movedToToDo.isBefore(date) ||
                      movedToToDo.isAtSameMomentAs(date);
                }).toList();

                // find done tasks on board for the date
                List<Task> doneTasksForDate = boardTasks.where((task) {
                  if (task.movedToDone == null) {
                    return false;
                  }
                  DateTime movedToDone = removeTime(task.movedToDone);
                  return movedToDone.isBefore(date) ||
                      movedToDone.isAtSameMomentAs(date);
                }).toList();

                //y axis
                //all tasks on board - done tasks
                int numNotDoneTasks =
                    toDoTasksForDate.length - doneTasksForDate.length;
                FlSpot numOfTaskSpots =
                    FlSpot(i.toDouble(), numNotDoneTasks.toDouble());
                numberOfTasksSpots.add(numOfTaskSpots);

                //y axis
                double notDoneEstimation =
                    getTotalEstimationForTasks(toDoTasksForDate) -
                        getTotalEstimationForTasks(doneTasksForDate);

                FlSpot estimationSpot = FlSpot(i.toDouble(), notDoneEstimation);
                estimationValueSpots.add(estimationSpot);
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 100, 10, 90),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(75.0),
                  ),
                  elevation: 15.0,
                  shadowColor: insightsCardShadow,
                  color: insightsCardColour,
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 50.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: <Color>[
                                  insightsColour6,
                                  insightsColour5
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: insightsShadowColour.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 7,
                                  offset: Offset(
                                      0, 3), // changes position of shadow
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Burn Down Chart',
                                style: whiteFont(20.0,
                                    fontStyle: FontStyle.italic),
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: LineChart(LineChartData(
                            lineTouchData: LineTouchData(
                              enabled: false,
                            ),
                            gridData: FlGridData(
                              show: true,
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: SideTitles(
                                  showTitles: true,
                                  margin: 10,
                                  getTitles: (value) {
                                    //modulus function to spread out the x axis
                                    if (value % 2 == 0) {
                                      return "";
                                    }
                                    DateTime date = firstDate
                                        .add(Duration(days: value.toInt()));

                                    return "${date.day}/${date.month}";
                                  }),
                              leftTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 20,
                                  getTitles: (value) {
                                    //modulus function to spread out the y axis
                                    if (value % 2 == 0) {
                                      return "";
                                    }
                                    return value.toInt().toString();
                                  }),
                            ),
                            borderData: FlBorderData(
                              show: false,
                            ),
                            minY: 0,
                            lineBarsData: [
                              createLine(numberOfTasksSpots, insightsColour5),
                              createLine(estimationValueSpots, insightsColour6)
                            ],
                          )),
                        ),
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0, top: 20),
                          child: LegendItem(
                              insightsColour6, "Total Estimation Value"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 100.0, top: 20),
                          child: LegendItem(
                              insightsColour5, "Number of Incomplete Tasks"),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
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

  LineChartBarData createLine(List<FlSpot> spots, Color colour) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      colors: [colour],
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: FlDotData(
        show: false,
      ),
      belowBarData: BarAreaData(),
    );
  }
}

DateTime removeTime(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
