import 'package:appdomoral/model/questao_estatistica_model.dart';
import 'package:appdomoral/utils/appsettings.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/chart_pie_indicators.dart';
import 'dart:async';
import 'package:dio/dio.dart';

class QuestaoEstatisticaScreen extends StatefulWidget {

  final question_id;

  QuestaoEstatisticaScreen(this.question_id);

  @override
  _QuestaoEstatisticaScreenState createState() => _QuestaoEstatisticaScreenState();
}

class _QuestaoEstatisticaScreenState extends State<QuestaoEstatisticaScreen> {


  Dio dio = Dio();

  //chart
  List<PieChartSectionData> pieChartRawSectionsByItens;
  List<PieChartSectionData> showingSectionsByItens;

  StreamController<PieTouchResponse> pieTouchedResultStreamControllerByItens;

  //chart
  List<PieChartSectionData> pieChartRawSectionsByPercentual;
  List<PieChartSectionData> showingSectionsByPercentual;

  StreamController<PieTouchResponse> pieTouchedResultStreamControllerByPercentual;

  int touchedIndex;

  Map<String, dynamic> questionStatistic;

  bool _isLoading = false;

  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();


  @override
  void initState() {
    // TODO: implement initState
    _getStatisticQuestion();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _key,
        body:  Container(
          child: _isLoading ? AppSettings().buildProgressIndicator(isLoading: _isLoading) : Column(
            children: <Widget>[
              AppSettings().appBar(
                  context: context,
                  title: 'QUESTÃO ${widget.question_id}',
                  hasMenu: false,
                  hasBack: true,
                  scaffoldkey: _key.currentState,
                  icon: Icons.book),
              Column(
                children: <Widget>[
                  Text('Itens mais respondidos'),
                  Row(
                    children: <Widget>[

                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: FlChart(
                            chart: PieChart(
                              PieChartData(
                                  pieTouchData: PieTouchData(
                                      touchResponseStreamSink:
                                      pieTouchedResultStreamControllerByItens
                                          .sink),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                  sections: showingSectionsByItens),
                            ),
                          ),
                        ),
                      ),
          questionStatistic['tipoQuestao'] != 0 ? Column(
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
                      ) : Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Indicator(
                color: Colors.green,
                text: "A",
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.blue,
                text: "B",
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.orange,
                text: "C",
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.yellow,
                text: "D",
                isSquare: true,
              ),
              SizedBox(
                height: 4,
              ),
              Indicator(
                color: Colors.purple,
                text: "E",
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
                  Text('Quantidade de acerto e erro'),
                  Row(
                    children: <Widget>[

                      Expanded(
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: FlChart(
                            chart: PieChart(
                              PieChartData(
                                  pieTouchData: PieTouchData(
                                      touchResponseStreamSink:
                                      pieTouchedResultStreamControllerByPercentual
                                          .sink),
                                  borderData: FlBorderData(
                                    show: false,
                                  ),
                                  sectionsSpace: 0,
                                  centerSpaceRadius: 40,
                                  sections: showingSectionsByPercentual),
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

              Text('Questão já resolvida ${questionStatistic['totalAcertos']+questionStatistic['totalErros']} vezes')

        ],
      ),
    ),
      )
    );
  }

  _getStatisticQuestion() async{
    _isLoading = true;
    var url = "${AppSettings.url}/api/questoes/estatistica/${widget.question_id}";

    var response = await dio.get(url);


      questionStatistic = response.data;
      print(questionStatistic);
    if(questionStatistic['totalAcertos'] == 0 && questionStatistic['totalErros'] == 0){
      AppSettings().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'Aviso',
          message: 'Questão ainda não foi resolvida!',
          buttonLabel: 'Fechar');
      setState(() {
        _isLoading = true;
      });
    }else{
      await _getChartByItens();
      await _getChartByPercentual();

      setState(() {
        _isLoading = false;
      });
    }

  }

  _getChartByItens() async{
    final section1 = PieChartSectionData(
      color: Colors.green,
      value: questionStatistic['totalA'].toDouble(),
      title: "${questionStatistic['totalA'].toStringAsFixed(0)}",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );
    final section2 = PieChartSectionData(
      color: Colors.blue,
      value: questionStatistic['totalB'].toDouble(),
      title: "${questionStatistic['totalB'].toStringAsFixed(0)}",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );

    final section3 = PieChartSectionData(
      color: Colors.orange,
      value: questionStatistic['totalC'].toDouble(),
      title: "${questionStatistic['totalC'].toStringAsFixed(0)}",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );
    final section4 = PieChartSectionData(
      color: Colors.yellow,
      value: questionStatistic['totalD'].toDouble(),
      title: "${questionStatistic['totalD'].toStringAsFixed(0)}",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );
    final section5 = PieChartSectionData(
      color: Colors.purple,
      value: questionStatistic['totalE'].toDouble(),
      title: "${questionStatistic['totalE'].toStringAsFixed(0)}",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );

    final items = [
      section1,
      section2,
      section3,
      section4,
      section5,
    ];

    pieChartRawSectionsByItens = items;

    showingSectionsByItens = pieChartRawSectionsByItens;

    pieTouchedResultStreamControllerByItens = StreamController();
    pieTouchedResultStreamControllerByItens.stream.distinct().listen((details) {
      if (details == null) {
        return;
      }

      touchedIndex = -1;
      if (details.sectionData != null) {
        touchedIndex = showingSectionsByItens.indexOf(details.sectionData);
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
          showingSectionsByItens = List.of(pieChartRawSectionsByItens);
        } else {
          showingSectionsByItens = List.of(pieChartRawSectionsByItens);

          if (touchedIndex != -1) {
            final TextStyle style = showingSectionsByItens[touchedIndex].titleStyle;
            showingSectionsByItens[touchedIndex] =
                showingSectionsByItens[touchedIndex].copyWith(
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


  _getChartByPercentual() async{
    final section1 = PieChartSectionData(
      color: Colors.green,
      value: questionStatistic['totalAcertos'].toDouble(),
      title: "${questionStatistic['totalAcertos'].toStringAsFixed(0)}",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );
    final section2 = PieChartSectionData(
      color: Colors.red,
      value: questionStatistic['totalErros'].toDouble(),
      title: "${questionStatistic['totalErros'].toStringAsFixed(0)}",
      radius: 50,
      titleStyle: TextStyle(
          fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xffffffff)),
    );


    final items = [
      section1,
      section2,
    ];

    pieChartRawSectionsByPercentual = items;

    showingSectionsByPercentual = pieChartRawSectionsByPercentual;

    pieTouchedResultStreamControllerByPercentual = StreamController();
    pieTouchedResultStreamControllerByPercentual.stream.distinct().listen((details) {
      if (details == null) {
        return;
      }

      touchedIndex = -1;
      if (details.sectionData != null) {
        touchedIndex = showingSectionsByPercentual.indexOf(details.sectionData);
      }

      setState(() {
        if (details.touchInput is FlLongPressEnd) {
          touchedIndex = -1;
          showingSectionsByPercentual = List.of(pieChartRawSectionsByPercentual);
        } else {
          showingSectionsByPercentual = List.of(pieChartRawSectionsByPercentual);

          if (touchedIndex != -1) {
            final TextStyle style = showingSectionsByPercentual[touchedIndex].titleStyle;
            showingSectionsByPercentual[touchedIndex] =
                showingSectionsByPercentual[touchedIndex].copyWith(
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
