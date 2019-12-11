import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../utils/appsettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share/share.dart';
import 'dart:io';

class AboutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
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
                          "Sobre o App",
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
                  padding: const EdgeInsets.all(18.0),
                  child: Center(
                    child: Column(
                      children: <Widget>[
                        SizedBox(height: 10,),

                            Image.asset('assets/images/logo_moral.png', width: 100,),
                            SizedBox(width: 10,),
                            Image.asset('assets/images/criatees_logo.jpg', width: 120,),

                        SizedBox(height: 10,),
                        Text('Desenvolvido por Criatees - Solucões Web www.criatees.com.br', textAlign: TextAlign.center,),
                        SizedBox(height: 20,),
                        Text('Em caso de bugs, dúvidas, sugestões ou críticas, envie um email para contato@criatees.com.br ou mande uma mensagem via Whatsapp clicando no ícone abaixo:', textAlign: TextAlign.center,),
                        IconButton(
                          icon: Icon(FontAwesomeIcons.whatsapp, color: Colors.green,),
                          onPressed: () async {
                            await _launchURL(
                                "http://api.whatsapp.com/send?phone=5585986152512");
                          },
                        ),
                        SizedBox(height: 10,),
                        Text('Versão ${AppSettings.app_version}'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
