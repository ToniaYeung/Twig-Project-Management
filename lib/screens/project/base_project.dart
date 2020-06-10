import 'package:flutter/material.dart';
import 'package:twig/common/ui/theme.dart';
import 'package:twig/common/utility/keys.dart';
import 'package:twig/screens/project/backlog/backlog.dart';
import 'package:twig/screens/project/board/board.dart';
import 'package:twig/screens/project/insights/insights.dart';
import 'package:twig/screens/project/settings/settings.dart';

// The base widgets for the different tabs when a project is selected. E.g. Insights, settings etc.

class BaseProject extends StatefulWidget {
  @override
  _BaseProjectState createState() => _BaseProjectState();
}

class _BaseProjectState extends State<BaseProject>
    with SingleTickerProviderStateMixin {
  PageController _pageController;
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    //vsync keeps track of the screen, so that the animation doesn't render when the screen isnt displayed
    _tabController = TabController(vsync: this, length: 4);
  }

  //Dispose is the same as delete. It is called when the widget is no longer used
  //So we need to clean up any of our objects
  @override
  void dispose() {
    _pageController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          key: Key(baseProjectKey),
          appBar: AppBar(
            backgroundColor: appBarColour,
            elevation: 7.0,
            bottom: TabBar(
              onTap: (int index) {
                _pageController.jumpToPage(index);
              },
              controller: _tabController,
              unselectedLabelColor: textColour,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [gradientYellow, greenDecoration]),
                  borderRadius: BorderRadius.circular(50),
                  color: lightGreenDecoration),
              tabs: <Widget>[
                Tab(text: 'Board'),
                Tab(key: Key(backlogTabKey), text: 'Backlog'),
                Tab(key: Key(insightsScreenKey), text: 'Insights'),
                Tab(
                  key: Key(settingsTabKey),
                  icon: new Image.asset(
                    'images/settings.png',
                    height: 40,
                    width: 45,
                  ),
                ),
              ],
            ),
            centerTitle: true,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/twig.png',
                  fit: BoxFit.contain,
                  height: 65,
                ),
              ],
            ),
          ),
          body: PageView(
            controller: _pageController,
            onPageChanged: (int index) {
              _tabController.animateTo(index);
            },
            children: <Widget>[
              Board(),
              Backlog(),
              Insights(),
              Settings(),
            ],
          ),
        ),
      ),
    );
  }
}
