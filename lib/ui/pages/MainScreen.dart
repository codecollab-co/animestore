import 'package:anime_app/generated/l10n.dart';
import 'package:anime_app/ui/component/AnimeGridWidget.dart';
import 'package:anime_app/ui/component/SearchWidget.dart';
import 'package:anime_app/ui/component/AboutListWidget.dart';
import 'package:anime_app/ui/pages/HomePage.dart';
import 'package:anime_app/ui/theme/ColorValues.dart';
import 'package:flutter/material.dart';

enum MainScreenNavigation { HOME, ANIME_LIST, SEARCH, SETTINGS }

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  MainScreenNavigation currentNav = MainScreenNavigation.HOME;
  late S locale;

  @override
  Widget build(BuildContext context) {
    locale = S.current;

    return Scaffold(
      body: WillPopScope(
          child: _getCurrentPage(),
          onWillPop: () async {
            var flag = true;
            if (currentNav != MainScreenNavigation.HOME) {
              setState(() {
                currentNav = MainScreenNavigation.HOME;
                flag = false;
              });
            }
            return flag;
          }),
      bottomNavigationBar: _createBottomBar(),
    );
  }

  Widget _getCurrentPage() {
    Widget widget;
    switch (currentNav) {
      case MainScreenNavigation.HOME:
        widget = HomePage();
        break;
      case MainScreenNavigation.ANIME_LIST:
        widget = AnimeGridWidget();
        break;
      case MainScreenNavigation.SEARCH:
        widget = SearchWidget();
        break;

      case MainScreenNavigation.SETTINGS:
        widget = AboutListWidget();
        break;
    }
    return widget;
  }

  void _changePageBody(int index) {
    setState(() {
      currentNav = MainScreenNavigation.values[index];
    });
  }

  Widget _createBottomBar() => Container(
        decoration: const BoxDecoration(boxShadow: [
          BoxShadow(
            color: accentColor,
            offset: Offset(.0, 5.0),
            blurRadius: 12.0,
          )
        ]),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: accentColor,
          backgroundColor: primaryColor,
          unselectedItemColor: secondaryColor,
          //fixedColor: primaryColor,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              label: locale.home,
              icon: const Icon(
                Icons.home,
              ),
            ),
            BottomNavigationBarItem(
              label: locale.animes,
              icon: const Icon(
                Icons.live_tv,
              ),
            ),
            BottomNavigationBarItem(
              label: locale.search,
              icon: const Icon(
                Icons.search,
              ),
            ),
            BottomNavigationBarItem(
                label: locale.info, icon: const Icon(Icons.info_outline))
          ],

          onTap: _changePageBody,
          currentIndex: currentNav.index,
        ),
      );
}
