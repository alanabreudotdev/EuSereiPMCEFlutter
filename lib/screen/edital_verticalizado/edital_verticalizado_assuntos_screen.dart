import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import '../../utils/cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_card/animated_card.dart';
import '../../model/edital_verticalizado_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:date_format/date_format.dart';

class EditalVerticalizadoAssuntoScreen extends StatefulWidget {
  final id;
  final type;
  final imageCategory;

  EditalVerticalizadoAssuntoScreen(this.id, this.type, this.imageCategory);

  @override
  _EditalVerticalizadoAssuntoScreenState createState() =>
      _EditalVerticalizadoAssuntoScreenState();
}

class _EditalVerticalizadoAssuntoScreenState
    extends State<EditalVerticalizadoAssuntoScreen> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey();

  List _categories;
  bool _isLoading = false;
  bool themeDefault;

  var dio = Dio();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getDados();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        body: _isLoading
            ? Center(
                child:
                    AppSettings().buildProgressIndicator(isLoading: _isLoading))
            : Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      AppSettings().appBar(
                          context: context,
                          title: widget.type,
                          hasMenu: false,
                          hasBack: true,
                          scaffoldkey: _scaffold.currentState,
                          icon: FontAwesomeIcons.edit),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _categories == null ? 0 : _categories.length,
                      itemBuilder: (context, index) {
                        return AnimatedCard(
                            direction: AnimatedCardDirection.top,
                            curve: Curves
                                .easeInOutCubic, //Initial animation direction
                            initDelay: Duration(
                                milliseconds: 0), //Delay to initial animation
                            duration: Duration(
                                seconds: 1), //Initial animation duration
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AppSettings().buildTile(
                                  Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                width: 200,
                                                child: Text(
                                                  _categories[index]['name']
                                                      .toString()
                                                      .toUpperCase(),
                                                  overflow: TextOverflow.fade,
                                                  softWrap: true,
                                                ),
                                              ),

                                              /*
                                          Row(
                                            children: <Widget>[
                                              Text(_categories[index]['question_count'] == 0 ? "": "${_categories[index]['question_count'].toString()}",
                                                  style: TextStyle(
                                                    //color: Colors.black,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 34.0)),
                                              Text(" assunto(s)",
                                                  style: TextStyle(
                                                    //color: Colors.black,
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 14.0)),

                                            ],
                                          ),
    */
                                            ],
                                          ),
                                          Material(
                                            color: Color(int.parse(
                                                AppSettings.primaryColor)),
                                            borderRadius:
                                                BorderRadius.circular(24.0),
                                            child: Center(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Icon(
                                                    Icons.arrow_forward_ios,
                                                    size: 30.0),
                                              ),
                                            ),
                                          ),
                                        ]),
                                  ), onTap: () {
                                showaAwesomeSheet(index);
                                /*
                                Navigator.of(context).push(
                                    new PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => EditalVerAssDetalhes(
                                          widget.id,
                                          _categories[index]['id'].toString(),
                                          _categories[index]['name']),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                      new FadeTransition(opacity: animation, child: child),
                                    ));
                                    */
                              }),
                            ));
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  showaAwesomeSheet(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return EditalVerAssDetalhes(
                widget.id,
                _categories[index]['id'].toString(),
                _categories[index]['name']);
          },
        );
      },
    );
  }

  _getDados() async {
    themeDefault = await AppSettings().getThemeDefault();
    setState(() {
      _isLoading = true;

      print("THEME: ${themeDefault}");
    });
    try {
      dio.options.baseUrl = "${AppSettings.url}api/";
      dio.interceptors
        ..add(CacheInterceptor())
        ..add(LogInterceptor(requestHeader: false, responseHeader: false));

      var response = await dio.get(
          "editais/verticalizado/disciplina/${widget.id}/assuntos",
          options: Options(extra: {'refresh': true}));
      setState(() {
        _categories = response.data;
        _isLoading = false;
        print(_categories);
      });
    } catch (e) {
      AppSettings().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'Aviso',
          message: 'Erro ao carregar, tente novamente!',
          buttonLabel: 'Fechar');
      setState(() {
        _isLoading = true;
      });
    }
  }
}

class EditalVerAssDetalhes extends StatefulWidget {
  final disciplinaId;
  final assuntoId;
  final assuntoName;
  EditalVerAssDetalhes(this.disciplinaId, this.assuntoId, this.assuntoName);

  @override
  _EditalVerAssDetalhesState createState() => _EditalVerAssDetalhesState();
}

class _EditalVerAssDetalhesState extends State<EditalVerAssDetalhes> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey();

  EditalVerticalizadoHelper helper = EditalVerticalizadoHelper();
  EditalVerticalizado edtVert = EditalVerticalizado();

  SharedPreferences prefs;

  bool _isLoading = false;
  var userDados;

  bool leituraVal = false;
  bool resumoVal = false;
  bool videoaulaVal = false;
  bool revisaoVal = false;
  bool questoesVal = false;

  String leituraData;
  String resumoData;
  String videoaulaData;
  String revisaoData;
  String questoesData;

  @override
  void initState() {
    _isLoading = true;
    // TODO: implement initState
    super.initState();
    _getUID();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        body: _isLoading
            ? Center(
                child:
                    AppSettings().buildProgressIndicator(isLoading: _isLoading))
            : Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  AppSettings().appBar(
                      context: context,
                      title: widget.assuntoName,
                      hasMenu: false,
                      hasBack: true,
                      scaffoldkey: _scaffold.currentState,
                      icon: FontAwesomeIcons.edit,
                      foto: false),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(0.0),
                          child: AppSettings().buildTile(
                            Column(
                              children: <Widget>[
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'EDITAL VERTICALIZADO',
                                  style: TextStyle(fontWeight: FontWeight.w900),
                                ),
                                Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: leituraVal,
                                          onChanged: (bool value) {
                                            leituraVal
                                                ? setState(() {
                                                    print(value);
                                                    leituraVal = value;
                                                    helper.deleteAssunto(
                                                        int.parse(
                                                            widget.assuntoId),
                                                        userDados['UID'],
                                                        "Leitura");
                                                  })
                                                : setState(() {
                                                    print(value);
                                                    leituraVal = value;
                                                    edtVert.disciplinaId =
                                                        widget.disciplinaId;
                                                    edtVert.assuntoId =
                                                        widget.assuntoId;
                                                    edtVert.name = "Leitura";
                                                    edtVert.valor =
                                                        value ? "1" : "0";
                                                    edtVert.userId =
                                                        userDados['UID'];
                                                    edtVert.data =
                                                        DateTime.now()
                                                            .toIso8601String();

                                                    helper.saveStatus(edtVert);
                                                  });
                                          },
                                        ),
                                        Text('Leitura'),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: leituraData != null ? Text(leituraData) :Text(''),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: resumoVal,
                                          onChanged: (bool value) {
                                            resumoVal
                                                ? setState(() {
                                                    print(value);
                                                    resumoVal = value;
                                                    helper.deleteAssunto(
                                                        int.parse(
                                                            widget.assuntoId),
                                                        userDados['UID'],
                                                        "Resumo");
                                                  })
                                                : setState(() {
                                                    print(value);
                                                    resumoVal = value;
                                                    edtVert.disciplinaId =
                                                        widget.disciplinaId;
                                                    edtVert.assuntoId =
                                                        widget.assuntoId;
                                                    edtVert.name = "Resumo";
                                                    edtVert.valor =
                                                        value ? "1" : "0";
                                                    edtVert.userId =
                                                        userDados['UID'];
                                                    edtVert.data =
                                                        DateTime.now()
                                                            .toIso8601String();

                                                    helper.saveStatus(edtVert);
                                                  });
                                          },
                                        ),
                                        Text('Resumo'),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: resumoData != null ? Text(resumoData) : Text(''),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: videoaulaVal,
                                          onChanged: (bool value) {
                                            videoaulaVal
                                                ? setState(() {
                                                    print(value);
                                                    videoaulaVal = value;
                                                    helper.deleteAssunto(
                                                        int.parse(
                                                            widget.assuntoId),
                                                        userDados['UID'],
                                                        "Videoaula");
                                                  })
                                                : setState(() {
                                                    print(value);
                                                    videoaulaVal = value;
                                                    edtVert.disciplinaId =
                                                        widget.disciplinaId;
                                                    edtVert.assuntoId =
                                                        widget.assuntoId;
                                                    edtVert.name = "Videoaula";
                                                    edtVert.valor =
                                                        value ? "1" : "0";
                                                    edtVert.userId =
                                                        userDados['UID'];
                                                    edtVert.data =
                                                        DateTime.now()
                                                            .toIso8601String();

                                                    helper.saveStatus(edtVert);
                                                  });
                                          },
                                        ),
                                        Text('Videoaula'),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: videoaulaData != null ? Text(videoaulaData) : Text(''),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: revisaoVal,
                                          onChanged: (bool value) {
                                            revisaoVal
                                                ? setState(() {
                                                    print(value);
                                                    revisaoVal = value;
                                                    helper.deleteAssunto(
                                                        int.parse(
                                                            widget.assuntoId),
                                                        userDados['UID'],
                                                        "Revisao");
                                                  })
                                                : setState(() {
                                                    print(value);
                                                    revisaoVal = value;
                                                    edtVert.disciplinaId =
                                                        widget.disciplinaId;
                                                    edtVert.assuntoId =
                                                        widget.assuntoId;
                                                    edtVert.name = "Revisao";
                                                    edtVert.valor =
                                                        value ? "1" : "0";
                                                    edtVert.userId =
                                                        userDados['UID'];
                                                    edtVert.data =
                                                        DateTime.now()
                                                            .toIso8601String();

                                                    helper.saveStatus(edtVert);
                                                  });
                                          },
                                        ),
                                        Text('Revisão'),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: revisaoData != null ? Text(revisaoData) : Text(''),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Checkbox(
                                          value: questoesVal,
                                          onChanged: (bool value) {
                                            questoesVal
                                                ? setState(() {
                                                    print(value);
                                                    questoesVal = value;
                                                    helper.deleteAssunto(
                                                        int.parse(
                                                            widget.assuntoId),
                                                        userDados['UID'],
                                                        "Questoes");
                                                  })
                                                : setState(() {
                                                    print(value);
                                                    questoesVal = value;
                                                    edtVert.disciplinaId =
                                                        widget.disciplinaId;
                                                    edtVert.assuntoId =
                                                        widget.assuntoId;
                                                    edtVert.name = "Questoes";
                                                    edtVert.valor =
                                                        value ? "1" : "0";
                                                    edtVert.userId =
                                                        userDados['UID'];
                                                    edtVert.data =
                                                        DateTime.now()
                                                            .toIso8601String();

                                                    helper.saveStatus(edtVert);
                                                  });
                                          },
                                        ),
                                        Text('Questões'),
                                      ],
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 8.0),
                                      child: questoesData != null ? Text(questoesData) : Text(''),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Text('*Marque a opção ao concluir a tarefa.', style: TextStyle(fontSize: 11),),
                                SizedBox(
                                  height: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  showaAwesomeSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    " Sheet",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Divider(height: 0),
                Expanded(
                  child: GridView.builder(
                    itemBuilder: (context, index) {
                      return Text(index.toString());
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: 100,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _getUID() async {
    prefs = await SharedPreferences.getInstance();
    String dados = await prefs.getString('userDados');
    print("AQUI VAI os DADOS: $dados");
    userDados = jsonDecode(dados);

    print("USUARIO ID ${userDados["UID"]}");

    setState(() {
      _isLoading = false;
      _getValor();
    });
  }

  _getValor() async {

    await helper
        .getValorByAssunto(
      userId: userDados['UID'],
      assuntoId: int.parse(widget.assuntoId),
    )
        .then((result) async {

      // print("RESULTADO: ${result}");
      //print("RESULTADO: ${result['Leitura']}");

      if (result['Leitura'] == 1) {



        setState(() {
          leituraVal = true;
          //pegar data que foi inserido no bd
           helper
              .getDataByAssunto(
              name: 'Leitura',
              assuntoId: int.parse(widget.assuntoId),
              userId: userDados['UID'])
              .then((resultado) {

             leituraData = convertDateFromString(resultado.data);
             print("LEITURA_DATA: $leituraData");
          });

        });
      }
      if (result['Resumo'] == 1) {
        setState(() {
          resumoVal = true;
          //pegar data que foi inserido no bd
          helper
              .getDataByAssunto(
              name: 'Resumo',
              assuntoId: int.parse(widget.assuntoId),
              userId: userDados['UID'])
              .then((resultado) {

            resumoData = convertDateFromString(resultado.data);
            print("RESUMO_DATA: $resumoData");
          });
        });
      }
      if (result['Videoaula'] == 1) {
        setState(() {
          videoaulaVal = true;
          //pegar data que foi inserido no bd
          helper
              .getDataByAssunto(
              name: 'Videoaula',
              assuntoId: int.parse(widget.assuntoId),
              userId: userDados['UID'])
              .then((resultado) {

            videoaulaData = convertDateFromString(resultado.data);
            print("VIDEOAULA_DATA: $videoaulaData");
          });
        });
      }
      if (result['Revisao'] == 1) {
        setState(() {
          revisaoVal = true;
          helper
              .getDataByAssunto(
              name: 'Revisao',
              assuntoId: int.parse(widget.assuntoId),
              userId: userDados['UID'])
              .then((resultado) {

            revisaoData = convertDateFromString(resultado.data);
            print("REVISAO_DATA: $revisaoData");
          });
        });
      }
      if (result['Questoes'] == 1) {
        setState(() {
          questoesVal = true;
          helper
              .getDataByAssunto(
              name: 'Questoes',
              assuntoId: int.parse(widget.assuntoId),
              userId: userDados['UID'])
              .then((resultado) {

            questoesData = convertDateFromString(resultado.data);
            print("QUESTOES_DATA: $questoesData");
          });
        });
      }
    });

    //return 'LEITURA: $totALLEITURA';
  }

  convertDateFromString(String strDate) {
    DateTime todayDate = DateTime.parse(strDate);
    print(todayDate);
    return (formatDate(todayDate, [dd, '/', mm, '/', yyyy]));
  }
}
