import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'dart:async' show Future;
import 'package:flutter_plugin_pdf_viewer/flutter_plugin_pdf_viewer.dart';
import '../../utils/appsettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_plugin_tts/flutter_plugin_tts.dart';




class LeiSecaScreen extends StatefulWidget {

  final titulo;
  final nameLei;

  LeiSecaScreen(this.titulo, this.nameLei);

  @override
  _LeiSecaScreenState createState() => _LeiSecaScreenState();
}

class _LeiSecaScreenState extends State<LeiSecaScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  var lei;
  bool _isLoading = false;
  Map<String, dynamic> document;
  int currentIndex = 0;


  @override
  void initState()  {
    _isLoading = true;
    FlutterPluginTts.setLanguage('pt-BR');
    // TODO: implement initState
    super.initState();
    loadAsset();

  }
  @override
  void dispose() {
    // TODO: implement dispose
    FlutterPluginTts.stop();
    document = null;
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        title: const Text('Plugin example app'),
          leading: Container(),
    ),
    body: Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            Expanded(

              child: ListView.builder(

                  itemCount: document.length,
                  itemBuilder: (context, index){

                    return Text(document['Lei'][currentIndex].toString());
                  }

              ),
            ),
            RaisedButton(onPressed: (){
              _nextSubmit();
            },child: Text( currentIndex == (document['Lei'].length - 1) ? "Submit" : "Next"),),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                RaisedButton(

                    child: const Icon(Icons.play_arrow), onPressed: () {
                  setState(() {
                    FlutterPluginTts.speak (document['Lei'][currentIndex]);
                  });
                }),
                RaisedButton(child: const Icon(Icons.stop), onPressed: () {
                  FlutterPluginTts.stop();
                }),
                RaisedButton(child: const Text('1'), onPressed: () {
                  FlutterPluginTts.setSpeechRate(0.5);
                }),

                RaisedButton(child: const Text('+2'), onPressed: () {
                  setState(() {
                    FlutterPluginTts.setSpeechRate(1.5);
                  });
                }),

              ],
            )
          ],


        ),
      ),
    )
    );
  }

  void _nextSubmit() {

    if(currentIndex < (document['Lei'].length - 1)){
      setState(() {
        currentIndex++;
      });
      print(document['Lei'].length);
    }
  }


  Future<PDFDocument> loadAsset() async {

    String data = await DefaultAssetBundle.of(context).loadString("assets/json/lei.json");
    document = await json.decode(data);
    print(document['Lei']);
    setState(() {
      _isLoading = false;
    });


  }



}


