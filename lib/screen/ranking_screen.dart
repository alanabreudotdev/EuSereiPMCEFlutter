import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import 'package:share/share.dart';
import 'dart:io';
import '../utils/appsettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RankingScreen extends StatelessWidget {
  int _questionIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.0,
        title: Text('Simulados', style: TextStyle(color: Colors.black),),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: (){
          Navigator.of(context).push(new MaterialPageRoute(builder: (context)=> HomeScreen()));}, color: Colors.black,),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              Platform.isIOS
                  ?
              Share.share('Quer passar no Concurso da PM/CE? Recomendo o App do Antigão ${AppSettings.APP_STORE_URL}')
                  : Share.share('Quer passar no Concurso da PM/CE? Recomendo o App do Antigão ${AppSettings.PLAY_STORE_URL}');
            },
          ),
        ],
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Icon(FontAwesomeIcons.smile),
            SizedBox(width: 10,),
            Text('Em Breve')
          ],
        ),
      )
    );
  }
}