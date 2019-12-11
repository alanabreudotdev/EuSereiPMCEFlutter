import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/appsettings.dart';
import '../model/question_model.dart';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import '../utils/chart_pie_indicators.dart';
import 'dart:async';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class QuestionDisciplinaEstatistica extends StatefulWidget {
  final String disciplina;
  QuestionDisciplinaEstatistica(this.disciplina);

  @override
  _QuestionDisciplinaEstatisticaState createState() =>
      _QuestionDisciplinaEstatisticaState();
}

class _QuestionDisciplinaEstatisticaState
    extends State<QuestionDisciplinaEstatistica> {


  //chart
  List<PieChartSectionData> pieChartRawSections;
  List<PieChartSectionData> showingSections;

  StreamController<PieTouchResponse> pieTouchedResultStreamController;

  int touchedIndex;

  bool _isLoading = false;

  int Total = 0;
  int Acertos = 0;
  int Erros = 0;
  double percAcertos;
  double percErros;
  var perc;
  var tempoGasto;
  var tempoMedio;

  QuestionResposta qstRes = QuestionResposta();
  QuestionHelper helper = QuestionHelper();

  SharedPreferences prefs;
  var userDados;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isLoading = true;
    _getUserDados().then((result) {
      _getDataDB(result["UID"], widget.disciplina).then((result) {
        if (result["Total"] > 0) {
          Acertos = result["Acertos"];
          Erros = result["Erros"];
          Total = result["Total"];
          percErros = result["percErros"];
          percAcertos = result["percAcertos"];
          tempoGasto = result["tempoGasto"];
          tempoMedio = result["tempoMedio"];

          setState(() {
            _isLoading = false;
            _getChart();
          });
        } else {
          AppSettings().showDialogSingleButtonWithRedirect(
              context: context,
              title: 'OPS!',
              message: "Você ainda não resolveu nenhuma questão.",
              buttonLabel: 'Voltar');
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(right: 20),
                            child: IconButton(
                                icon: Icon(FontAwesomeIcons.reply),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                          ),
                          SizedBox(
                            width: 250,
                            child: Text(
                              widget.disciplina,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                          Expanded(child: SizedBox()),
                          Expanded(child: SizedBox()),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    AppSettings().buildTile(
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text('Questões resolvidas',
                                      style:
                                          TextStyle(color: Colors.blueAccent)),
                                  Text(Total.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 34.0))
                                ],
                              ),
                              Material(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(24.0),
                                  child: Center(
                                      child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Icon(Icons.timeline,
                                        color: Colors.white, size: 30.0),
                                  )))
                            ]),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        AppSettings().buildTile(
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Material(
                                      color: Colors.teal,
                                      shape: CircleBorder(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(26.0),
                                        child: Text(
                                          Acertos.toString(),
                                          style: TextStyle(fontSize: 30),
                                        ),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 16.0)),
                                  Text('Questões',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24.0)),
                                  Text(
                                    'certas',
                                  ),
                                ]),
                          ),
                        ),
                        AppSettings().buildTile(
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Material(
                                      color: Colors.red,
                                      shape: CircleBorder(),
                                      child: Padding(
                                        padding: const EdgeInsets.all(26.0),
                                        child: Text(
                                          Erros.toString(),
                                          style: TextStyle(fontSize: 30),
                                        ),
                                      )),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 16.0)),
                                  Text('Questões',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24.0)),
                                  Text(
                                    'erradas',
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    AppSettings().buildTile(Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(
                                height: 18,
                              ),
                              Expanded(
                                child: AspectRatio(
                                  aspectRatio: 1,
                                  child: FlChart(
                                    chart: PieChart(
                                      PieChartData(
                                          pieTouchData: PieTouchData(
                                              touchResponseStreamSink:
                                                  pieTouchedResultStreamController
                                                      .sink),
                                          borderData: FlBorderData(
                                            show: false,
                                          ),
                                          sectionsSpace: 0,
                                          centerSpaceRadius: 40,
                                          sections: showingSections),
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Indicator(
                                    color: Colors.green,
                                    text: "Acertos",
                                    isSquare: true,
                                  ),
                                  SizedBox(
                                    height: 4,
                                  ),
                                  Indicator(
                                    color: Colors.red,
                                    text: "Erros",
                                    isSquare: true,
                                  ),
                                  SizedBox(
                                    height: 18,
                                  ),
                                ],
                              ),
                              SizedBox(
                                width: 28,
                              ),
                            ],
                          ),
                        ],
                      ),
                    )),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        AppSettings().buildTile(
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Material(
                                      color: Colors.lime,
                                      borderRadius: BorderRadius.circular(24.0),
                                      child: Center(
                                          child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          tempoGasto.toString(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ))),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 16.0)),
                                  Text('Tempo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24.0)),
                                  Text(
                                    'total',
                                  ),
                                ]),
                          ),
                        ),
                        AppSettings().buildTile(
                          Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Material(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(24.0),
                                      child: Center(
                                          child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Text(
                                          tempoMedio.toString(),
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ))),
                                  Padding(
                                      padding: EdgeInsets.only(bottom: 16.0)),
                                  Text('Média',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 24.0)),
                                  Text(
                                    'por questão',
                                  ),
                                ]),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28.0),
                      child: RaisedButton(
                        padding: EdgeInsets.all(10),
                        onPressed: () {
                          print("DADOS: $userDados");
                          zerar(widget.disciplina, userDados['UID']);
                        },
                        child: Text(
                          'Zerar estatística',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Ao clicar no botão acima você irá será todas as questões resolvidas para o assunto: ${widget.disciplina}',
                        style: TextStyle(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
      ),
    );
  }

  Future _getUserDados() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userDados = jsonDecode(prefs.getString('userDados'));
    });

    return userDados;
  }

  Future _getDataDB(String userId, String categoryName) async {
    return await helper.getQuestionsByCategoryName(
        userId: userId, categoryName: categoryName);
  }

  Future zerar(String categoryName, String userId) async {
    helper.deleteQuestionByCategoryName(categoryName, userId);
    AppSettings().showDialogSingleButtonWithRedirect(
        context: context,
        title: "Ops!",
        buttonLabel: "Fechar",
        message: "${widget.disciplina} foi zerado com sucesso!");
  }

  _getChart() {
    final section2 = PieChartSectionData(
      color: Colors.green,
      value: percAcertos,
      title: "${percAcertos.toStringAsFixed(0)}%",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );

    final section3 = PieChartSectionData(
      color: Colors.red,
      value: percErros,
      title: "${percErros.toStringAsFixed(0)}%",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );

    final items = [
      section2,
      section3,
    ];

    pieChartRawSections = items;

    showingSections = pieChartRawSections;

    pieTouchedResultStreamController = StreamController();
    pieTouchedResultStreamController.stream.distinct().listen((details) {
      if (details == null) {
        return;
      }

      touchedIndex = -1;
      if (details.sectionData != null) {
        touchedIndex = showingSections.indexOf(details.sectionData);
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
          showingSections = List.of(pieChartRawSections);
        } else {
          showingSections = List.of(pieChartRawSections);

          if (touchedIndex != -1) {
            final TextStyle style = showingSections[touchedIndex].titleStyle;
            showingSections[touchedIndex] =
                showingSections[touchedIndex].copyWith(
              titleStyle: style.copyWith(
                fontSize: 24,
              ),
              radius: 60,
            );
          }
        }
      });
    });
  }
}
