import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../model/edital_verticalizado_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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
                  AppSettings().appBar(
                      context: context,
                      title: widget.assuntoName,
                      hasMenu: false,
                      hasBack: true,
                      scaffoldkey: _scaffold.currentState,
                      icon: FontAwesomeIcons.edit),
                  Expanded(
                    child: ListView(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: AppSettings().buildTile(Column(
                            children: <Widget>[
                              SizedBox(
                                height: 8,
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
                                                  edtVert.data = DateTime.now()
                                                      .toIso8601String();

                                                  helper.saveStatus(edtVert);
                                                });
                                        },
                                      ),
                                      Text('Leitura'),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('10/10/2019'),
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
                                            edtVert.data = DateTime.now()
                                                .toIso8601String();

                                            helper.saveStatus(edtVert);
                                          });
                                        },
                                      ),
                                      Text('Resumo'),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('10/10/2019'),
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
                                            edtVert.data = DateTime.now()
                                                .toIso8601String();

                                            helper.saveStatus(edtVert);
                                          });
                                        },
                                      ),

                                      Text('Videoaula'),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('10/10/2019'),
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
                                            edtVert.data = DateTime.now()
                                                .toIso8601String();

                                            helper.saveStatus(edtVert);
                                          });
                                        },
                                      ),

                                      Text('Revisão'),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('10/10/2019'),
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
                                            edtVert.data = DateTime.now()
                                                .toIso8601String();

                                            helper.saveStatus(edtVert);
                                          });
                                        },
                                      ),
                                      Text('Questões'),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: Text('10/10/2019'),
                                  )
                                ],
                              ),
                            ],
                          )),
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
        .then((result) {
      print("RESULTADO: ${result}");
      print("RESULTADO: ${result['Leitura']}");

      if (result['Leitura'] == 1) {

          setState(() {
            leituraVal = true;
          });

      }
      if (result['Resumo'] == 1) {

          setState(() {
            resumoVal = true;
          });

      }
      if (result['Videoaula'] == 1) {

          setState(() {
            videoaulaVal = true;
          });

      }
      if (result['Revisao'] == 1) {

          setState(() {
            revisaoVal = true;
          });

      }
      if (result['Questoes'] == 1) {
          setState(() {
            questoesVal = true;
          });

      }
      });

    //return 'LEITURA: $totALLEITURA';
  }


}
