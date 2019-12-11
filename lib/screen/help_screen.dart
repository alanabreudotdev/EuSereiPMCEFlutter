import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/appsettings.dart';


class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  var _textoAjuda;
  bool _isLoading = false;

  @override
  void initState() {
    _isLoading = true;
    // TODO: implement initState
    super.initState();
    _getTutorial();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading ? Center(child: AppSettings()
            .buildProgressIndicator(isLoading: _isLoading)) : SingleChildScrollView(
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
                padding: const EdgeInsets.all(12.0),
                child: Html(
                  useRichText: true,
                  data: _textoAjuda['content'],
                  //Optional parameters:

                  linkStyle: const TextStyle(
                    color: Colors.redAccent,
                    decorationColor: Colors.redAccent,
                    decoration: TextDecoration.underline,
                  ),
                  onLinkTap: (url) {
                    print("Opening $url...");
                  },
                  onImageTap: (src) {
                    print(src);
                  },
                  //Must have useRichText set to false for this to work
                  customRender: (node, children) {
                    if (node is dom.Element) {
                      switch (node.localName) {
                        case "custom_tag":
                          return Column(children: children);
                      }
                    }
                    return null;
                  },
                  customTextAlign: (dom.Node node) {
                    if (node is dom.Element) {
                      switch (node.localName) {
                        case "p":
                          return TextAlign.justify;
                      }
                    }
                    return null;
                  },

                ),

              ),
            ],
          )
        ),
      ),
    );
  }

  _getTutorial() async {
    Response response;
    Dio dio = new Dio();
    response = await dio.get("http://www.appdoantigao.com.br/api/tutorial");
    setState(() {
      _textoAjuda = response.data;
      print(_textoAjuda['content']);
      _isLoading = false;

    });

  }
}
