import 'package:appdomoral/screen/navigation_home_screen.dart';
import 'package:flutter/material.dart';
import '../screen/home_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/user_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:date_format/date_format.dart';

class AppSettings {
  static List<Color> multiColors = [
    Colors.blue,
    Colors.red,
    Colors.cyanAccent,
    Colors.amber,
  ];

  //* URL PADRAO
  static const String url = "https://questoes.eusereiaprovado.com.br/";
  //static const String url = "http://192.168.0.103/";

  static const String APP_STORE_URL =
      'https://apps.apple.com/br/app/apple-store/id1480078685';
  static const String PLAY_STORE_URL =
      'https://play.google.com/store/apps/details?id=br.com.criatees.appdomoral';

  static const String app_version = "1.0.0";

  static const String app_name = "Eu Serei PM/CE 2020";

  static const String primaryColor = "0xfff44336";

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color nearlyBlack = Color(0xFF213333);

  static List<Color> colorsLinearGradient = [
    Color(0xffff5e62),
    Color(0xffff9966),
  ];

  Color corIcone;

  SharedPreferences prefs;

  void showMsg(String msg, BuildContext context) {
    //
    final snackBar = SnackBar(
      content: Text(msg),
      action: SnackBarAction(
        label: 'Fechar',
        onPressed: () {
          // Some code to undo the change!
        },
      ),
    );
    Scaffold.of(context).showSnackBar(snackBar);
  }

  //ALERT DIALOG COM REDIRECT TO HOME
  void showDialogSingleButtonWithRedirect(
      {@required BuildContext context,
      @required String title,
      @required String message,
      @required String buttonLabel}) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(message),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text(buttonLabel),
              onPressed: () {
                Navigator.push(context,
                    new MaterialPageRoute(builder: (context) => NavigationHomeScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //colors
  static List<Color> kitGradients = [
    // new Color.fromRGBO(103, 218, 255, 1.0),
    // new Color.fromRGBO(3, 169, 244, 1.0),
    // new Color.fromRGBO(0, 122, 193, 1.0),
    Colors.blueGrey.shade800,
    Colors.black87,
  ];
  static List<Color> kitGradients2 = [
    Colors.cyan.shade600,
    Colors.blue.shade900
  ];

  Widget appBar(
      {context,
      ScaffoldState scaffoldkey,
      String title,
      bool hasMenu = true,
      bool hasBack = false,
      IconData icon,
      bool foto = true}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Padding(
              padding: EdgeInsets.only(top: 0),
              child: hasBack
                  ? IconButton(
                      icon: Icon(FontAwesomeIcons.reply),
                      onPressed: () {
                        Navigator.of(context).pop();
                      })
                  : hasMenu
                      ? Container()
                      : IconButton(icon: Icon(icon), onPressed: () {})),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          ),
          /*foto
              ? ScopedModelDescendant<UserModel>(
                  builder: (context, child, model) {
                    return Column(
                      children: <Widget>[
                        Container(
                          width: 35,
                          height: 35,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                  colors: AppdoMoral.colorsLinearGradient)),
                          child: GestureDetector(
                            child: CircleAvatar(
                              radius: 15,
                              backgroundImage: model.isLoggedIn()
                                  ? model.userData['photoUrl'] == null
                                      ? AssetImage(
                                          'assets/images/user_perfil.png')
                                      : CachedNetworkImageProvider(
                                        model.userData['photoUrl'])
                                  : AssetImage('assets/images/user_perfil.png'),
                            ),
                            onTap: () {
                              *//*Navigator.of(context).push(
                            !model.isLoggedIn()
                                ? new PageRouteBuilder(
                              pageBuilder: (_, __, ___) => LoginScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                              new ScaleTransition(scale: animation, child: child),
                            )
                                :
                            new PageRouteBuilder(
                              pageBuilder: (_, __, ___) => ProfileScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                              new FadeTransition(opacity: animation, child: child),
                            ));*//*
                            },
                          ),
                        ),
                      ],
                    );
                  },
                )
              : Container(),*/
        ],
      ),
    );
  }

  Widget buildProgressIndicator({bool isLoading = false}) {
    return Scaffold(
      body: new Padding(
          padding: const EdgeInsets.all(0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              new Center(
                child: new Opacity(
                  opacity: isLoading ? 1.0 : 00,
                  child:SpinKitHourGlass(
                    color: multiColors[Random().nextInt(4)],

                  ),
                ),
              ),
              SizedBox(height: 5,),
              Text('carregando', style: TextStyle(fontSize: 11),)
            ],
          )),
    );
  }

  Widget buildTile(Widget child, {Function() onTap}) {
    return Material(
        elevation: 14.0,
        borderRadius: BorderRadius.circular(12.0),
        shadowColor: Colors.black26,
        child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null
                ? () => onTap()
                : () {
                    print('Not set yet');
                  },
            child: child));
  }

  Widget buildTileCustom(Widget child, Color cor1, Color cor2, context, {Function() onTap}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        elevation: 14,
        color: Colors.transparent,
        child: Container(
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [cor1, cor2],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter),
            borderRadius: new BorderRadius.only(
              topLeft: new Radius.circular(20.0),
              topRight: new Radius.circular(5.0),
              bottomLeft: new Radius.circular(5.0),
              bottomRight: new Radius.circular(20.0),
            ),
            boxShadow: [
              new BoxShadow(
                color: Colors.black26,
                offset: new Offset(1.0, 1.0),
              )
            ],
          ),
          child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
              onTap: onTap != null
                  ? () => onTap()
                  : () {
                print('Not set yet');
              },
              child: child)
        ),
      ),
    );


      /*Material(
        elevation: 14.0,
        borderRadius: new BorderRadius.only(
          topLeft: new Radius.circular(20.0),
          //topRight: new Radius.circular(20.0),
          //bottomRight: new Radius.circular(20.0),
          bottomLeft: new Radius.circular(20.0),
        ),
        shadowColor: Colors.black26,
        child: InkWell(
            // Do onTap() if it isn't null, otherwise do print()
            onTap: onTap != null
                ? () => onTap()
                : () {
                    print('Not set yet');
                  },
            child: child));
            */
  }

  getThemeDefault() async {
    prefs = await SharedPreferences.getInstance();
    var theme = false;
    theme = await prefs.getBool('darkMode');
    if (theme == null) {
      theme = false;
    }

    return theme;
  }

  String convertStringFromDate() {
    final todayDate = DateTime.now();
    print(formatDate(todayDate, [yyyy, '-', mm, '-', dd]));
    return formatDate(todayDate, [yyyy, '-', mm, '-', dd]);
  }
}
