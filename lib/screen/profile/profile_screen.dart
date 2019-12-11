import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/user_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'profile_edit_screen.dart';
import 'profile_modo_escuro_screen.dart';
import '../help_screen.dart';
import '../about_screen.dart';
import '../home_screen.dart';
import '../videos_screen.dart';
import '../login_screen.dart';
import 'package:animated_card/animated_card.dart';
import '../simulados_category_child_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
    return SafeArea(
      child: Scaffold(
          key: _scaffold,
          body: ScopedModelDescendant<UserModel>(
              builder: (context, child, model) {
            return _isLoading
                ? Center(
                    child: SizedBox(
                        child: AppSettings()
                            .buildProgressIndicator(isLoading: _isLoading)))
                : SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        Padding(padding: EdgeInsets.only(top: 10),
                child: AppSettings().appBar(
                    context: context,
                    title: 'MEU PERFIL ',
                    hasMenu: true,
                    hasBack: false,
                    scaffoldkey: _scaffold.currentState,
                    icon: Icons.book), ),
                        /**
                         * USER
                         */
                        AnimatedCard(
                          direction: AnimatedCardDirection
                              .top, //Initial animation direction
                          initDelay: Duration(
                              milliseconds: 400), //Delay to initial animation
                          duration:
                              Duration(seconds: 1), //Initial animation duration
                          child: Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: AppSettings().buildTile(
                                ListTile(
                                    leading: Container(
                                      height: 60,
                                      width: 60,
                                      //margin: EdgeInsets.only(top: 60),
                                      child: CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.white,
                                          child: !model.isLoggedIn()
                                              ? Image.asset(
                                                  'assets/images/user_perfil.png')
                                              : (model.userData['photoUrl'] ==
                                                          null ||
                                                      model.userData[
                                                              'photoUrl'] ==
                                                          "")
                                                  ? Image.asset(
                                                      'assets/images/user_perfil.png')
                                                  : Material(
                                                      child: CachedNetworkImage(
                                                        placeholder:
                                                            (context, url) =>
                                                                Container(
                                                          child:
                                                              CircularProgressIndicator(
                                                            strokeWidth: 2.0,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                        Color>(
                                                                    Colors
                                                                        .amber),
                                                          ),
                                                          width: 45.0,
                                                          height: 45.0,
                                                        ),
                                                        imageUrl:
                                                            model.userData[
                                                                'photoUrl'],
                                                        height: 45.0,
                                                        width: 45,
                                                        fit: BoxFit.cover,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  20.0)),
                                                      clipBehavior:
                                                          Clip.hardEdge,
                                                    )),
                                    ),
                                    title: Text(
                                      "${!model.isLoggedIn() ? "Futuro(a) Concursado(a)" : model.isLoggedIn() ? model.userData['name'] != null ? model.userData['name'] : 'Futuro(a) Concursado(a)' : "Futuro(a) Concursado(a)"}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16),
                                      textAlign: TextAlign.left,
                                    ),
                                    subtitle: Text(
                                        "${!model.isLoggedIn() ? "#eusereipmce2020" : model.isLoggedIn() ? model.firebaseUser.email != null ? model.firebaseUser.email : '---------' : "---------"}",
                                        style: TextStyle(fontSize: 10)),
                                    trailing:
                                        Icon(FontAwesomeIcons.caretRight)),
                                onTap: () {
                              Navigator.of(context).push(
                                !model.isLoggedIn()
                                    ? new PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            LoginScreen(),
                                        transitionsBuilder: (context, animation,
                                                secondaryAnimation, child) =>
                                            new FadeTransition(
                                                opacity: animation,
                                                child: child),
                                      )
                                    : new PageRouteBuilder(
                                        pageBuilder: (_, __, ___) =>
                                            ProfileEditScreen(),
                                        transitionsBuilder: (context, animation,
                                                secondaryAnimation, child) =>
                                            new FadeTransition(
                                                opacity: animation,
                                                child: child),
                                      ),
                              );
                            }),
                          ),
                        ),

                        SizedBox(
                          height: 5,
                        ),
                        Divider(),
                        SizedBox(
                          height: 5,
                        ),
                        /**
                         * DARK MODE
                         */
                        AnimatedCard(
                            direction: AnimatedCardDirection
                                .left, //Initial animation direction
                            initDelay: Duration(
                                milliseconds: 400), //Delay to initial animation
                            duration: Duration(
                                seconds: 1), //Initial animation duration
                            child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: AppSettings().buildTile(
                                    ListTile(
                                        leading: Icon(
                                          FontAwesomeIcons.solidMoon,
                                          size: 30,
                                        ),
                                        title: Text('Dark Mode'),
                                        subtitle: Text('Ativar modo noturno'),
                                        trailing:
                                            Icon(FontAwesomeIcons.caretRight)),
                                    onTap: () {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              ModoEscuroScreen()));
                                }))),
                        /**
                         * TUTORIAL
                         */
                        AnimatedCard(
                            direction: AnimatedCardDirection
                                .left, //Initial animation direction
                            initDelay: Duration(
                                milliseconds: 400), //Delay to initial animation
                            duration: Duration(
                                seconds: 1), //Initial animation duration
                            child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: AppSettings().buildTile(
                                    ListTile(
                                        leading: Icon(
                                          FontAwesomeIcons.questionCircle,
                                          size: 30,
                                        ),
                                        title: Text('Ajuda'),
                                        subtitle: Text('Como usar o app'),
                                        trailing:
                                            Icon(FontAwesomeIcons.caretRight)),
                                    onTap: () {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) => HelpScreen()));
                                }))),
                        /**
                         * SOBRE O APP
                         */
                        AnimatedCard(
                            direction: AnimatedCardDirection
                                .left, //Initial animation direction
                            initDelay: Duration(
                                milliseconds: 400), //Delay to initial animation
                            duration: Duration(
                                seconds: 1), //Initial animation duration
                            child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: AppSettings().buildTile(
                                    ListTile(
                                        leading: Icon(
                                          FontAwesomeIcons.info,
                                          size: 30,
                                        ),
                                        title: Text('Sobre'),
                                        subtitle:
                                            Text('Informações sobre o app'),
                                        trailing:
                                            Icon(FontAwesomeIcons.caretRight)),
                                    onTap: () {
                                  Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) => AboutScreen()));
                                }))),
                        SizedBox(
                          height: 5,
                        ),
                        Divider(),
                        SizedBox(
                          height: 5,
                        ),
                        /**
                         * LOGOUT O APP
                         */
                        AnimatedCard(
                            direction: AnimatedCardDirection
                                .bottom, //Initial animation direction
                            initDelay: Duration(
                                milliseconds: 400), //Delay to initial animation
                            duration: Duration(
                                seconds: 1), //Initial animation duration
                            child: Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: AppSettings().buildTile(
                                        ListTile(
                                            leading: Icon(
                                              FontAwesomeIcons.signOutAlt,
                                              size: 30,
                                            ),
                                            title: Text('Logout'),
                                            subtitle: Text('Deslogar do App'),
                                            trailing: Icon(
                                                FontAwesomeIcons.caretRight)),
                                        onTap: () {
                                      model.signOut();
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  HomeScreen()));
                                    })))),
                      ],
                    ),
                  );
          })),
    );
  }

  void _getUID() async {
    prefs = await SharedPreferences.getInstance();
    String dados = await prefs.getString('userDados');
    print("AQUI VAI os DADOS: $dados");
    userDados = jsonDecode(dados);

    print("USUARIO ID ${userDados["UID"]}");
  }
}
