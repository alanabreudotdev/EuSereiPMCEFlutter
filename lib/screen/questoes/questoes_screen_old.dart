import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/user_model.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import '../../model/question_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../navigation_home_screen.dart';
import 'package:animated_card/animated_card.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:expandable/expandable.dart';
import '../../utils/api.dart';
import '../../model/questoes_model.dart';
import 'dart:convert';


class QuestionScreen extends StatefulWidget {

  final assuntosId;
  final orgaosId;
  final bancasId;
  final cargosId;
  final anosId;
  final certo_errado;
  final acertei;
  final errei;
  final resolvi;
  final naoResolvi;
  final aleatoria;


  QuestionScreen(this.assuntosId, this.orgaosId, this.bancasId, this.cargosId,
      this.anosId, this.certo_errado, this.acertei, this.errei, this.resolvi,
      this.naoResolvi, this.aleatoria);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {


  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  PageController _pageController = PageController();
  int currentIndex = 0;
  Map<dynamic, dynamic> progress = {};

  var nextPage = 'http://192.168.10.18/api/questoes';


  var themeDefault;
  var UserUid;

  var dio = Dio();

  Questoes questions;
  List<Data> itemQst;
  var dataFiltros;
  var response;

  ///BEGIN TIMER
  Stopwatch watch = new Stopwatch();
  Timer timer;

  String elapsedTime = '';

  bool _isLoading = false;
  // Declare this variable
  String selectedRadio;

  @override
  void initState() {
    _getQuestions();
    // TODO: implement initState
    super.initState();
    resetWatch();

    setState(() {
      dataFiltros = {
        "assuntosId": widget.assuntosId,
        "orgaosId": widget.orgaosId ,
        "bancasId": widget.bancasId ,
        "cargosId": widget.cargosId ,
        "anosId": widget.anosId ,
        "certo_errado": widget.certo_errado,
        "acertei": widget.acertei,
        "errei": widget.errei,
        "resolvi": widget.resolvi,
        "naoResolvi": widget.naoResolvi,
        "aleatoria": widget.aleatoria,
      };
    });

  }

  @override
  void dispose() {
    resetWatch();
    stopWatch();
    super.dispose();
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
        r"<[^>]*>",
        multiLine: true,
        caseSensitive: true
    );

    return htmlText.replaceAll(exp, '');
  }




  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          key: _key,
          body: _isLoading
              ? Center(
              child: AppSettings()
                  .buildProgressIndicator(isLoading: _isLoading))
              : ScopedModelDescendant<UserModel>(
            builder: (context, child, model) {
              UserUid = model.firebaseUser.uid;

              return PageView.builder(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index+1;
                  });
                },
                itemBuilder: (context, index) {
                  print("INDEX: $currentIndex");
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[

                      Container(
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              RaisedButton(
                                child: Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                ),
                                color: Theme.of(context).primaryColor,
                                onPressed: () {
                                  _pageController.animateToPage(
                                      _pageController.page.ceil() - 1,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.easeInBack);
                                  // .jumpToPage(_pageController.page.ceil() - 1);
                                },
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                padding: EdgeInsets.fromLTRB(15, 0, 10, 0),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 1,
                                      color: Theme.of(context).primaryColor),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Page ${currentIndex + 1}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700, fontSize: 35),
                                ),
                              ),
                              RaisedButton(
                                child: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                                color: Theme.of(context).primaryColor,
                                onPressed: () async {
                                  _getQuestions();
                                  _pageController.animateToPage(
                                      _pageController.page.ceil() + 1,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.easeIn);
                                  // .jumpToPage(_pageController.page.ceil() + 1);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
                itemCount: questions.limit,
              );

              /*PageView.builder(

                  controller: _pageController,
                onPageChanged: (index) async {
                  setState(() {
                    currentIndex = index;

                  });
                  _getQuestions();
                },
                  itemBuilder: (context, index){

                    return Column(
                      children: <Widget>[
                        Html(
                          data: itemQst[0].enunciado,
                          useRichText: true,
                        ),
                        Material(
                          child: InkWell(
                            child: Card(
                              child: Text( removeAllHtmlTags(itemQst[0].alternativaA).replaceAll('a)', '')),
                            ),
                          ),
                        ),
                        Material(
                          child: InkWell(
                            child: Card(
                              child: Text( removeAllHtmlTags(itemQst[0].alternativaB).replaceAll('b)', '')),
                            ),
                          ),
                        ),
                        Material(
                          child: InkWell(
                            child: Card(
                              child: Text( removeAllHtmlTags(itemQst[0].alternativaC).replaceAll('c)', '')),
                            ),
                          ),
                        )
                      ],
                    );

                  },

                  itemCount: questions.total,

                  );*/
            },
          )),
    );
  }

  Future<bool> _onWillPop() async {

    return showDialog<bool>(
        context: context,
        builder: (_) {

          return AlertDialog(
            content: Text("Você tem que certeza que quer sair?"),
            title: Text("Aviso!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Sim"),
                onPressed: () {

                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => NavigationHomeScreen()));
                },
              ),
              FlatButton(
                child: Text("Não"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }


  void _getQuestions() async {

    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      if (questions == null) {
        nextPage = 'http://192.168.10.18/api/questoes/?'+
            "assuntosId=${widget.assuntosId}&"+
            "orgaosId=${widget.orgaosId}&"+
            "bancasId=${widget.bancasId}&"+
            "cargosId=${widget.cargosId}&"+
            "anosId=${widget.anosId}&"+
            "certo_errado=${widget.certo_errado}&"+
            "acertei=${widget.acertei}&"+
            "errei=${widget.errei}&"+
            "resolvi=${widget.resolvi}&"+
            "naoResolvi=${widget.naoResolvi}&"+
            "aleatoria=${widget.aleatoria}";
        print(nextPage);
      }

      final response = await dio.get(nextPage);


      if (response.data['next_page_url'] != null) {
        nextPage =
            response.data['next_page_url']+"&"+
                "assuntosId=${widget.assuntosId}&"+
                "orgaosId=${widget.orgaosId}&"+
                "bancasId=${widget.bancasId}&"+
                "cargosId=${widget.cargosId}&"+
                "anosId=${widget.anosId}&"+
                "certo_errado=${widget.certo_errado}&"+
                "acertei=${widget.acertei}&"+
                "errei=${widget.errei}&"+
                "resolvi=${widget.resolvi}&"+
                "naoResolvi=${widget.naoResolvi}&"+
                "aleatoria=${widget.aleatoria}";
        print(nextPage);
      } else {
        nextPage = null;
      }

      questions = Questoes.fromJson(response.data);
      print("Questoes: ${questions}");

      setState(() {
        itemQst = questions.data;
        _isLoading = false;
        // questions.addAll(tempList);
      });

    }
  }

  void _getQuestionssss() async {

    themeDefault = themeDefault = await AppSettings().getThemeDefault();

    setState(() {
      _isLoading = true;
    });

    try {
      response = await CallApi().getData(nextPage);

      var res = response;
      print(res[0]['total']);
      /*setState(() async {
         questions = Questoes.fromJson(response);
         nextPage = questions.nextPageUrl;
       });

       setState(() {
         itemQst = questions.data;
       });

      print("proxima: ${itemQst}");*/

      //print("ITem da Questao: ${ itemQst[0].alternativaA}");

      setState(() {
        _isLoading = false;
      });

    } catch (e) {
      print(e);
    }
  }


  ///BEGIN TIMER
  startWatch() {
    watch.start();
    timer = new Timer.periodic(new Duration(milliseconds: 100), updateTime);
  }

  stopWatch() {
    watch.stop();
    setTime();
  }

  resetWatch() {
    watch.reset();
    setTime();
  }

  setTime() {
    var timeSoFar = watch.elapsedMilliseconds;
    setState(() {
      elapsedTime = transformMilliSeconds(timeSoFar);
    });
  }

  transformMilliSeconds(int milliseconds) {
    //Thanks to Andrew
    int hundreds = (milliseconds / 10).truncate();
    int seconds = (hundreds / 100).truncate();
    int minutes = (seconds / 60).truncate();

    String minutesStr = (minutes % 60).toString().padLeft(2, '0');
    String secondsStr = (seconds % 60).toString().padLeft(2, '0');

    return "$minutesStr:$secondsStr";
  }

  ///END TIMER

  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

/// FIM TIMER




}
