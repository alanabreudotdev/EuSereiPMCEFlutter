

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/appsettings.dart';
import 'dart:io';
import 'package:share/share.dart';
import 'package:scoped_model/scoped_model.dart';
import '../model/user_model.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/home_screen.dart';

class DrawerPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();
  final Color primary = Color(0xff303030);
  final Color active = Colors.black;
  final Color activeIcon = Colors.black26;
  final Color divider = Colors.black12;



  @override
  Widget build(BuildContext context) {
    return _buildDrawer(context);
  }

  _buildDrawer(context) {
    final String image = "0";
    return ScopedModelDescendant<UserModel>(
      builder: (context, child, model) {
        return
     ClipPath(
      //clipper: OvalRightBorderClipper(),
      child: Drawer(

        child: Container(
          padding: const EdgeInsets.only(left: 16.0, right: 40),
          //decoration: BoxDecoration(
            //  color: primary, boxShadow: [BoxShadow(color: Colors.black45)]),
          width: 300,

          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        Icons.power_settings_new,
                        //color: active,
                      ),
                      onPressed: () {
                        model.signOut();
                        Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(
                                builder: (context) =>
                                    HomeScreen()));
                      },
                    ),
                  ),
                   Column(
                        children: <Widget>[
                          Container(
                            height: 90,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                    colors: [Colors.lime, Colors.limeAccent])),
                            child: CircleAvatar(
                              radius: 40,
                              backgroundImage: model.isLoggedIn()
                                  ? model.firebaseUser.photoUrl == null
                                  ? AssetImage(
                                  'assets/images/user_perfil.png')
                                  : CachedNetworkImageProvider(
                                  model.firebaseUser.photoUrl)
                                  : AssetImage(
                                  'assets/images/user_perfil.png'),
                            ),
                          ),
                          SizedBox(height: 5.0),

                          Text(
                            "${!model.isLoggedIn() ? "Aluno Moral"
                                : model.userData['name'] != null ? model.userData['name'] : 'Aluno Moral' }",
                            style: TextStyle(
                                color: Colors.lime,
                                fontSize: 18.0,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            "#alunoMoral",
                            style: TextStyle( fontSize: 16.0),
                          ),
                        ],
                      ),


                  SizedBox(height: 30.0),
                  //_buildRow(FontAwesomeIcons.home, "Início"),
                  //_buildDivider(),
                  InkWell(
                    onTap: (){},
                    child: _buildRow(FontAwesomeIcons.edit, "Questões",
                  ),
                      //showBadge: true
                  ),
                  _buildDivider(),
                  InkWell(
                    onTap: (){},
                    child:  _buildRow(FontAwesomeIcons.bookReader, "Legislação",
                    ),
                  ),
                  _buildDivider(),
                  InkWell(
                    onTap: (){},
                    child:  _buildRow(FontAwesomeIcons.elementor, "Simulados"),
                    ),
                  _buildDivider(),
                  InkWell(
                    onTap: (){},
                    child:  _buildRow(FontAwesomeIcons.handsHelping, "Ajuda"),
                  ),

                  _buildDivider(),
                  InkWell(
                    onTap: (){},
                    child:  _buildRow(FontAwesomeIcons.mailBulk, "Contato"),
                  ),

                  _buildDivider(),
                  InkWell(
                    onTap: (){},
                    child:  _buildRow(Icons.info_outline, "Sobre"),
                  ),

                  _buildDivider(),
                  socialActions(context),
                  SizedBox(height: 20,),
                  Text(
                    AppSettings.app_version,
                    style:
                    Theme.of(context).textTheme.caption.copyWith(fontSize: 10),
                  ),

                ],
              ),
            ),
          ),
        ),
      ),

    );
      },
    );
  }

  Widget socialActions(context) => FittedBox(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        IconButton(
          icon: Icon(FontAwesomeIcons.facebookF, ),
          onPressed: () async {
            await AppSettings().launchURL(
                "https://www.facebook.com/professorwagnerlobo/");
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.youtube, ),
          onPressed: () async {
            await AppSettings().launchURL(
                "https://www.youtube.com/channel/UCU6At0WRtUb0othsptuosoA");
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.instagram, ),
          onPressed: () async {
            await AppSettings().launchURL(
                "https://www.instagram.com/professorwagnerlobo/");
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.whatsapp, ),
          onPressed: () async {
            await AppSettings().launchURL(
                "http://api.whatsapp.com/send?phone=5585997750693");
          },
        ),
        IconButton(
          icon: Icon(Icons.share, ),
          onPressed: () async {
            Platform.isIOS
                ?
            Share.share('Quer passar no Concurso da PM/CE? Recomendo o App do Antigão ${AppSettings.APP_STORE_URL}')
                : Share.share('Quer passar no Concurso da PM/CE? Recomendo o App do Antigão ${AppSettings.PLAY_STORE_URL}');
          },
        ),
      ],
    ),
  );

  Divider _buildDivider() {
    return Divider(
      color: divider,
    );
  }



  Widget _buildRow(IconData icon, String title, {bool showBadge = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(children: [
        Icon(
          icon,
          //color: activeIcon,
          size: 20,
        ),
        SizedBox(width: 15.0),
        Text(
          title,
          //style: tStyle,
        ),
        Spacer(),
        if (showBadge)
          Material(
            color: Colors.deepOrange,
            elevation: 5.0,
            shadowColor: Colors.red,
            borderRadius: BorderRadius.circular(5.0),
            child: Container(
              width: 25,
              height: 25,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.deepOrange,
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Text(
                "10+",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold),
              ),
            ),
          )
      ]),
    );
  }
}