import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pick_file/data/info_data.dart';
import 'package:flutter_pick_file/pages/main_screen_page.dart';

import '../constants/screens.dart';
import 'about/about_page.dart';

bool get currentIsDark =>
    Screens.mediaQuery.platformBrightness == Brightness.dark;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController controller = PageController();
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    controller.addListener(pageControllerListener);
  }

  void selectIndex(int index) {
    if (index == currentIndex) {
      return;
    }
    controller.animateToPage(
      index,
      duration: kThemeAnimationDuration,
      curve: Curves.easeInOut,
    );
  }

  void pageControllerListener() {
    final int? currentPage = controller.page?.round();
    if (currentPage != null && currentPage != currentIndex) {
      currentIndex = currentPage;
      if (mounted) {
        setState(() {});
      }
    }
  }

  Widget header(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(top: 30.0),
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 1.0,
            child: Hero(
              tag: 'LOGO',
              child: Image.asset(InfoData.appLogo),
            ),
          ),
          const SizedBox(width: 10.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Semantics(
                sortKey: const OrdinalSortKey(0),
                child: Text(
                  InfoData.appName,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              Semantics(
                sortKey: const OrdinalSortKey(0.1),
                child: Text(
                  'Version: ${InfoData.appVersion}',
                  style: Theme.of(context).textTheme.caption,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20.0),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: currentIsDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              header(context),
              Expanded(
                child: PageView(
                  controller: controller,
                  children: const <Widget>[
                    MainScreen(),
                    AboutPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: selectIndex,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.photo_library),
              label: AppData.appBottomMenu0,
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.explore),
              label: AppData.appBottomMenu1,
            ),
          ],
        ),
      ),
    );
  }
}
