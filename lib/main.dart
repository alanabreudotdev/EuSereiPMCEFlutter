import 'package:appdomoral/screen/navigation_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scoped_model/scoped_model.dart';
import 'model/user_model.dart';
import 'package:advanced_splashscreen/advanced_splashscreen.dart';
import 'utils/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/theme_notifier.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  //* Forcing only portrait orientation
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await SharedPreferences.getInstance().then((prefs) {
    //prefs.remove('darkMode');
    var darkModeOn = prefs.getBool('darkMode') ?? false;
    print("THEME: ${prefs.getBool('darkMode')}");
    print("darkModeOn: ${darkModeOn}");
    runApp(
      ChangeNotifierProvider<ThemeNotifier>(
        builder: (_) => ThemeNotifier(darkModeOn ?  darkTheme : lightTheme),
        child: MainApp(),
      ),
    );
  });
}


class MainApp extends StatefulWidget {
  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return ScopedModel<UserModel>(
      model: UserModel(),
      child: MaterialApp(
      title: 'Eu Serei PM/CE 2020!',
      debugShowCheckedModeBanner: false,
          theme: themeNotifier.getTheme(),
      home: SafeArea(
        child: ScopedModelDescendant<UserModel>(
            builder: (context, child, model){
              return AdvancedSplashScreen(
                bgImageOpacity: 0.0,
                child: NavigationHomeScreen(),
                seconds: 8,
                colorList: [
                  Color(0xffffffff),
                ],
                animate: true,
                appTitle: 'desenvolvido por Criatees',
                appTitleStyle: TextStyle(color: Colors.black87),


                appIcon: "assets/images/logo_eu_serei_pm.png",
              );



            }),
      )
    )
    );
  }
}


