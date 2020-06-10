import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twig/common/ui/clickable_card.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/models/project.dart';
import 'package:twig/screens/project/insights/burn_down_chart.dart';
import 'package:twig/screens/project/insights/task_progress_chart.dart';
import 'package:twig/screens/project/insights/velocity_tracker.dart';

import 'milestones_timeline.dart';

class Insights extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Project project = Provider.of<Project>(context);
    return Scaffold(
        backgroundColor: scaffoldBackgroundColour,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 15),
              ClickableCard(
                key: Key(progressChartsKey),
                child: Column(
                  children: [
                    Text(
                      "Progress Charts",
                      style: textStyle(22.0),
                    ),
                    Image.asset('images/piechart.png'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    //page transition
                    MaterialPageRoute(
                      builder: (context) {
                        return TaskProgressChart(project.id);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              ClickableCard(
                key: Key(milestonesKey),
                child: Column(
                  children: [
                    Text("Milestones", style: textStyle(22.0)),
                    Image.asset('images/timeline.png'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    //page transition
                    MaterialPageRoute(
                      builder: (context) {
                        return Milestones(project);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              ClickableCard(
                key: Key(burndownChartKey),
                child: Column(
                  children: [
                    Text(
                      "Burn Down Chart",
                      style: textStyle(22.0),
                    ),
                    Image.asset('images/burndown.png'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    //page transition
                    MaterialPageRoute(
                      builder: (context) {
                        return BurnDownChart(project.id);
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 10),
              ClickableCard(
                key: Key(velocityTrackerKey),
                child: Column(
                  children: [
                    Text(
                      "Velocity Tracker",
                      style: textStyle(22.0),
                    ),
                    Image.asset('images/barchart.png'),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    //page transition
                    MaterialPageRoute(
                      builder: (context) {
                        return VelocityTracker(project);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ));
  }
}
