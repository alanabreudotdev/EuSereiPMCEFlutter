import 'package:appdomoral/screen/profile/profile_screen.dart';
import '../widget/drawerUserController.dart';
import '../widget/homeDrawer.dart';
import 'package:flutter/material.dart';
import '../screen/questoes/questoes_filtros_screen.dart';
import 'initial_page_screen.dart';
import '../screen/teorias/lei_seca_categorias.dart';

class NavigationHomeScreen extends StatefulWidget {
  @override
  _NavigationHomeScreenState createState() => _NavigationHomeScreenState();
}

class _NavigationHomeScreenState extends State<NavigationHomeScreen> {
  Widget screenView;
  DrawerIndex drawerIndex;
  AnimationController sliderAnimationController;

  @override
  void initState() {
    drawerIndex = DrawerIndex.HOME;
    screenView = InitialScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: AppdoMoral.nearlyWhite,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(

          body: DrawerUserController(
            screenIndex: drawerIndex,
            drawerWidth: MediaQuery.of(context).size.width * 0.75,
            animationController: (AnimationController animationController) {
              sliderAnimationController = animationController;
            },
            onDrawerCall: (DrawerIndex drawerIndexdata) {
              changeIndex(drawerIndexdata);
            },
            screenView: screenView,
          ),
        ),
      ),
    );
  }

  void changeIndex(DrawerIndex drawerIndexdata) {
    if (drawerIndex != drawerIndexdata) {
      drawerIndex = drawerIndexdata;
      if (drawerIndex == DrawerIndex.HOME) {
        setState(() {
          screenView = InitialScreen();
        });
      } else if (drawerIndex == DrawerIndex.Questoes) {
        setState(() {
          screenView = QuestionsFiltrosScreen();
        });
      } else if (drawerIndex == DrawerIndex.Teoria) {
        setState(() {
          screenView = LeiSecaCategorias();
        });
      } else if (drawerIndex == DrawerIndex.Profile) {
        setState(() {
          screenView = ProfileScreen();
        });
      } else {
        //do in your way......
      }
    }
  }
}
