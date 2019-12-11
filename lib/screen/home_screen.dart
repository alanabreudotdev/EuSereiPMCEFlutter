import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/appsettings.dart';
import '../screen/concursos/concursos_screen.dart';
import '../screen/profile/profile_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import '../screen/videos_screen.dart';
import 'initial_page_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  int _selectedIndex = 0;


  @override
  Widget build(BuildContext context) {
    PageController pageController = PageController(
      initialPage: 0,
      keepPage: false,
    );

    void pageChanged(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    Widget buildPageView() {
      return PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: (index) {
          pageChanged(index);
        },
        children: <Widget>[
          InitialScreen(),
          ConcursosCategory(),
          VideosScreen(),
          ProfileScreen(),


          /*
          ScopedModelDescendant<UserModel>(
            builder: (context, child, model) {
              return model.isLoggedIn() ? ProfileScreen() : LoginScreen();
            },
          ),
      */
        ],
      );
    }

    return SafeArea(
      child: Scaffold(

        key: _scaffoldKey,
        body:
         Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0),
            child: buildPageView(),
          ),


        bottomNavigationBar: BottomNavyBar(
          animationDuration: Duration(milliseconds: 500),
          //backgroundColor:  Color( 0xfff1f1f1 ),
          selectedIndex: _selectedIndex,
          showElevation: true,
          onItemSelected: (index) =>
              setState(() {
                _selectedIndex = index;
                pageController.animateToPage(
                    index,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.ease
                );
              }),
          items: [
            BottomNavyBarItem(
              inactiveColor: Colors.grey,
              icon: Icon(FontAwesomeIcons.home),
              title: Text('Início'),
              activeColor: Color(int.parse(AppSettings.primaryColor)),
            ),
            BottomNavyBarItem(
                inactiveColor: Colors.grey,
                icon: Icon(FontAwesomeIcons.bookReader),
                title: Text('Concurso'),
                activeColor: Color(int.parse(AppSettings.primaryColor))),
            BottomNavyBarItem(
                inactiveColor: Colors.grey,
                icon: Icon(FontAwesomeIcons.youtube),
                title: Text('Video'),
                activeColor: Color(int.parse(AppSettings.primaryColor))),
            BottomNavyBarItem(
              inactiveColor: Colors.grey,
              icon: Icon(FontAwesomeIcons.userCircle),
              title: Text('Perfil'),
              activeColor: Color(int.parse(AppSettings.primaryColor)),
            ),
          ],
        ),
        //drawer: DrawerPage(),
      ),
    );
  }

}