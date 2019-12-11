import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import '../model/question_model.dart';
import 'package:dio/dio.dart';
import '../utils/appsettings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'home_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_card/animated_card.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

class SimuladoGabaritoScreen extends StatefulWidget {
  final simuladoCategoryId;

  SimuladoGabaritoScreen(this.simuladoCategoryId);

  @override
  _SimuladoGabaritoScreenState createState() => _SimuladoGabaritoScreenState();
}

class _SimuladoGabaritoScreenState extends State<SimuladoGabaritoScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  bool _isLoading = false;
  var dio = Dio();
  List _questions;
  var userDados;
  List Respostas;
  bool correct = false;

  SimuladoResposta simRsp = SimuladoResposta();
  SimuladoHelper helper = SimuladoHelper();

  SharedPreferences prefs;

  final controller = StreamController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _get_questions();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        appBar: AppBar(
          leading: Padding(
            padding: EdgeInsets.all(8),
            child: IconButton(
                icon: Icon(FontAwesomeIcons.reply),
                onPressed: () {
                  Navigator.of(context).pop();
                }),
          ),
          backgroundColor: Colors.red[400],
          title: Text('Gabarito'),
          elevation: 0,
        ),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Stack(
                children: <Widget>[
                  ClipPath(
                    clipper: ArcClipper(),
                    child: Container(
                      decoration: BoxDecoration(color: Colors.red[400]),
                      height: 200,
                    ),
                  ),
                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _isLoading
                              ? 0
                              : Respostas == null ? 0 : Respostas.length + 1,
                          itemBuilder: _isLoading
                              ? Center(
                                  child: CircularProgressIndicator(),
                                )
                              : _buildItem,
                        )
                ],
              ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    if ((index + 1) == Respostas.length + 1) {
      return RaisedButton(
        child: Text("Fechar"),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        color: Theme.of(context).primaryColor,
        onPressed: () {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => HomeScreen()));
        },
      );
    }

    correct = Respostas[index].respostaSimuladoId ==
        Respostas[index].respostaEscolhida;

    return AnimatedCard(
        direction: AnimatedCardDirection.right,
        curve: Curves.easeInOutQuart, //Initial animation direction
        initDelay: Duration(milliseconds: 500), //Delay to initial animation
        duration: Duration(seconds: 1), //Initial animation duration
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Html(
                  useRichText: true,
                  data: "${(index + 1).toString()}) ${Respostas[index].titleSimulado}",
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

                SizedBox(height: 5.0),
                Divider(),
                correct
                    ? Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.check,
                            color: Colors.green,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Você acertou!',
                            style: TextStyle(
                                color: Colors.green,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : Row(
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.windowClose,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            'Você errou!',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                SizedBox(height: 10.0),
                Text(
                  'Sua resposta: ${Respostas[index].respostaEscolhida}',
                  style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5.0),
                Divider(),
                Text.rich(
                  TextSpan(children: [
                    TextSpan(
                        text: 'Gabarito / Comentário',
                        style: TextStyle(fontWeight: FontWeight.w500))
                  ]),
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 5.0),
                Html(
                  useRichText: true,
                  data: Respostas[index].explanationSimulado,
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
                SizedBox(height: 5.0),
              ],
            ),
          ),
        ));
  }

  _get_questions() async {
    setState(() {
      _isLoading = true;
    });

    await _getUserPrefs();

    setState(() {
      _getQuestionAnswer(widget.simuladoCategoryId, userDados['UID']);
    });
  }

  _getQuestionAnswer(simuladCategoryId, userSimuladoId) async {
    helper
        .getQuestionRespondidaBySimulado(simuladCategoryId, userSimuladoId)
        .then((result) {
      setState(() {
        Respostas = result;
        print("Repostas: $Respostas");
      });

      if (Respostas.isEmpty) {
        AppSettings().showDialogSingleButtonWithRedirect(
            context: context,
            title: 'Ops!',
            message:
                "Você ainda não resolveu esse simulado. Resolva para ter acesso as estatísticas.",
            buttonLabel: 'Sair');
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  _getUserPrefs() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userDados = jsonDecode(prefs.getString('userDados'));
      //print("USERDADOS:$userDados");
    });
  }
}
