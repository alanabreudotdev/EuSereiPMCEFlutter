import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:day_night_switch/day_night_switch.dart';
import '../../utils/theme_notifier.dart';
import '../../utils/theme.dart';
import 'package:provider/provider.dart';
import 'profile_edit_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/user_model.dart';
import '../../utils/appsettings.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ModoEscuroScreen extends StatefulWidget {
  @override
  _ModoEscuroScreenState createState() => _ModoEscuroScreenState();
}

class _ModoEscuroScreenState extends State<ModoEscuroScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  bool _isLoading = false;
  var userDados;
  var _darkTheme = false;

  SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUID();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _darkTheme = (themeNotifier.getTheme() == darkTheme);
    return SafeArea(
      child: Scaffold(
          key: _scaffold,
          body:
          ScopedModelDescendant<UserModel>(builder: (context, child, model) {
            return _isLoading
                ? Center(
                child: SizedBox(
                    child: AppSettings().buildProgressIndicator(
                        isLoading: _isLoading)))
                : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal:0.0, vertical: 6),
                    child: Row(
                      mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(right: 20),
                          child: IconButton(
                              icon:
                              Icon(FontAwesomeIcons.reply),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                        ),
                        SizedBox(
                          width: 150,
                          child: Text(
                            "Dark Mode",
                            softWrap: true,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Expanded(child: SizedBox()),
                        Expanded(child: SizedBox()),

                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(vertical:10.0),
                      child: AppSettings().buildTile(
                        ListTile(
                          title: Text('Modo Noturno'),
                          contentPadding: const EdgeInsets.only(top:20, bottom: 20, left: 30.0),
                          trailing: Transform.scale(
                            scale: 0.4,
                            child: DayNightSwitch(
                              value: _darkTheme,
                              onChanged: (val) {
                                setState(() {
                                  _darkTheme = val;
                                });
                                onThemeChanged(val, themeNotifier);
                              },
                            ),
                          ),
                        ),
                      )
                  ),
                ],
              ),

            );
          }
          )
      ),
    );

  }

  void onThemeChanged(bool value, ThemeNotifier themeNotifier) async {
    (value)
        ? themeNotifier.setTheme(darkTheme)
        : themeNotifier.setTheme(lightTheme);
    var prefs = await SharedPreferences.getInstance();
    print("VALOR: $value");
    prefs.setBool('darkMode', value);
  }

  void _getUID() async{
    prefs = await SharedPreferences.getInstance();
    String dados = await prefs.getString('userDados');
    print("AQUI VAI os DADOS: $dados");
    userDados = jsonDecode(dados);

    print("USUARIO ID ${userDados["UID"]}");
  }
}
