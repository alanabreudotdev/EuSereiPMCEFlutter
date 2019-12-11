import 'package:flutter/material.dart';
import '../utils/appsettings.dart';
import 'package:dio/dio.dart';
import '../utils/cache_interceptor.dart';
import 'dart:async';
import 'home_screen.dart';
import '../model/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:back_button_interceptor/back_button_interceptor.dart';
import 'simulados_resultado_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_card/animated_card.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;

class SimuladosQuestionScreen extends StatefulWidget {
  final category_id;
  final category_name;

  SimuladosQuestionScreen(this.category_id, this.category_name);

  @override
  _SimuladosQuestionScreenState createState() =>
      _SimuladosQuestionScreenState();
}

class _SimuladosQuestionScreenState extends State<SimuladosQuestionScreen> {

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  PageController _pageController = PageController();

  int currentIndex = 0;

  Map<dynamic, dynamic> progress = {};
  bool _isLoading = false;
  var userDados;
  var respostaEscolhidaColumn;

  SimuladoResposta simRsp = SimuladoResposta();
  SimuladoHelper helper = SimuladoHelper();


  SharedPreferences prefs;


  ///BEGIN TIMER
  Stopwatch watch = new Stopwatch();
  Timer timer;

  bool _showTimer = true;

  String elapsedTime = '';

  var dio = Dio();

  List _questions;
  var questionsResposta;
  String selectedRadio;
  int totalQuestionsResolvidas = 0;

  // Changes the selected value on 'onChanged' click on each radio button
  setSelectedRadio(String val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getQuestions();
    resetWatch();
    BackButtonInterceptor.add(_backButtonInterceptor);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    resetWatch();
    stopWatch();
    BackButtonInterceptor.remove(_backButtonInterceptor);
  }


  _getAnswer(simuladoCategoryId, userSimuladoId, questionIdSimulado) async{
    respostaEscolhidaColumn = null;
    helper.getQuestionRespondidaById(simuladoCategoryId, userSimuladoId, questionIdSimulado).then((result){
       setState(() {
         respostaEscolhidaColumn = result;
         if(respostaEscolhidaColumn != null){
           print("RESPOSTAAAA : ${respostaEscolhidaColumn.respostaEscolhida}");

           setSelectedRadio(respostaEscolhidaColumn.respostaEscolhida);
         }
         print("DBRETORNO: $respostaEscolhidaColumn");
       });
     });
  }

  _getTotalQuestionsResolvidas(simuladoCategoryId, userSimuladoId) async{
    helper.getTotalQuestionsResolvidas(userSimuladoId, simuladoCategoryId).then((result){
      setState(() {
        totalQuestionsResolvidas = result;

        _onWillPopFinalizarSimulado();

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          key: _scaffoldKey,

          bottomNavigationBar: _isLoading
              ? Container() : bottomBar(context, _questions.length),
          body: _isLoading
              ? Center(
                  child: AppSettings()
                      .buildProgressIndicator(isLoading: _isLoading),
                )
              : PageView.builder(

                  controller: _pageController,
                  onPageChanged: (index) async {
                    setState(() {
                      currentIndex = index;
                      print('INDEX: $index');
                      print('QUESTAO: ${_questions[index]['id'].toString()}');
                      selectedRadio = null;
                      resetWatch();
                      startWatch();
                    });

                    setState(() {
                      _getAnswer(widget.category_id.toString(), userDados['UID'], _questions[index]['id'].toString());

                    });

                  },
                  itemBuilder: (context, index) {

                    return SingleChildScrollView(
                      child: AnimatedCard(
                        direction: AnimatedCardDirection.bottom,
                        curve: Curves.bounceOut,//Initial animation direction
                        initDelay: Duration(milliseconds: 0), //Delay to initial animation
                        duration: Duration(seconds: 1), //Initial animation duration
                        child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(0.0),
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
                                        _onWillPop();
                                      }),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    widget.category_name,
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 20),
                                  ),
                                ),
                                Expanded(child: SizedBox()),
                                Expanded(child: SizedBox()),
                                _isLoading
                                    ? Container()
                                    : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Center(
                                      child: Text(
                                        elapsedTime,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                _isLoading
                                    ? Container()
                                    : InkWell(
                                  onTap: showaAwesomeSheet,
                                  child: Container(
                                    alignment: Alignment.center,
                                    height: 40,
                                    margin: EdgeInsets.all(8.0),
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      progress.length == null
                                          ? "0/${_questions.length}"
                                          : "${progress.length}/${_questions.length} ",

                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 15.0, bottom: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.fromLTRB(15, 10, 10, 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 2,
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    'Questão ${currentIndex + 1}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppSettings().buildTile(
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Html(
                                  useRichText: true,
                                  data: _questions[currentIndex]['title']
                                  ,
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

                                )
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppSettings().buildTile(
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    (_questions[currentIndex]['choice_a'] != null && _questions[currentIndex]['choice_a'] != "")
                                        ? RadioListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 5),
                                        child: Text(
                                          _questions[currentIndex]
                                          ['number_of_answer'] >
                                              2
                                              ? 'a)'
                                              : _questions[currentIndex]
                                          ['choice_a'],
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      groupValue: selectedRadio,
                                      value: _questions[currentIndex]
                                      ['choice_a'],
                                      onChanged: (value) {
                                        setState(() {
                                          questionsResposta = value;
                                          setSelectedRadio(value);
                                          print(questionsResposta);
                                        });
                                      },
                                    )
                                        : Container(),
                                    (_questions[currentIndex]['choice_b'] != null && _questions[currentIndex]['choice_b'] != "")
                                        ? RadioListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 5),
                                        child: Text(
                                          _questions[currentIndex]
                                          ['number_of_answer'] >
                                              2
                                              ? 'b)'
                                              : _questions[currentIndex]
                                          ['choice_b'],
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      groupValue: selectedRadio,
                                      value: _questions[currentIndex]
                                      ['choice_b'],
                                      onChanged: (value) {
                                        setState(() {
                                          questionsResposta = value;
                                          setSelectedRadio(value);
                                          print(questionsResposta);
                                        });
                                      },
                                    )
                                        : Container(),
                                    (_questions[currentIndex]['choice_c'] != null && _questions[currentIndex]['choice_c'] != "")
                                        ? RadioListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 5),
                                        child: Text(
                                          _questions[currentIndex]
                                          ['number_of_answer'] >
                                              2
                                              ? 'c)'
                                              : _questions[currentIndex]
                                          ['choice_c'],
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      groupValue: selectedRadio,
                                      value: _questions[currentIndex]
                                      ['choice_c'],
                                      onChanged: (value) {
                                        setState(() {
                                          questionsResposta = value;
                                          setSelectedRadio(value);
                                          print(questionsResposta);
                                        });
                                      },
                                    )
                                        : Container(),
                                    (_questions[currentIndex]['choice_d'] != null && _questions[currentIndex]['choice_d'] != "")
                                        ? RadioListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 5),
                                        child: Text(
                                          _questions[currentIndex]
                                          ['number_of_answer'] >
                                              2
                                              ? 'd)'
                                              : _questions[currentIndex]
                                          ['choice_d'],
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      groupValue: selectedRadio,
                                      value: _questions[currentIndex]
                                      ['choice_d'],
                                      onChanged: (value) {
                                        setState(() {
                                          questionsResposta = value;
                                          setSelectedRadio(value);
                                          print(value);
                                        });
                                      },
                                    )
                                        : Container(),
                                    (_questions[currentIndex]['choice_e'] != null && _questions[currentIndex]['choice_e'] != "")
                                        ? RadioListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.only(
                                            top: 5.0, bottom: 5),
                                        child: Text(
                                          _questions[currentIndex]
                                          ['number_of_answer'] >
                                              2
                                              ? 'e)'
                                              : _questions[currentIndex]
                                          ['choice_e'],
                                          style: TextStyle(fontSize: 15),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                      groupValue: selectedRadio,
                                      value: _questions[currentIndex]
                                      ['choice_e'],
                                      onChanged: (value) {
                                        setState(() {
                                          questionsResposta = value;
                                          setSelectedRadio(value);
                                          print(questionsResposta);
                                        });
                                      },
                                    )
                                        : Container(),
                                  ],
                                )
                            )
                          ),
                          SizedBox(height: 10.0),
                        ],
                      ),
                    )
                    );
                  },
                  itemCount: _questions.length,
                )),
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
                    " Questões",
                    style: TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ),
                Divider(height: 0),
                Expanded(
                  child: GridView.builder(
                    itemBuilder: (context, index) {
                      return getTile(index);
                    },
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8,
                    ),
                    itemCount: _questions.length,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  bottomBar(
    context, total
  ) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BottomAppBar(
        elevation: 0,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            //BOTTOM BACK
            RaisedButton(
              child: Icon(
                FontAwesomeIcons.arrowCircleLeft,
                color: Colors.white,
              ),
              color: Colors.black45,
              onPressed: () {
                _pageController.animateToPage(_pageController.page.ceil() - 1,
                    duration: Duration(seconds: 1), curve: Curves.fastOutSlowIn);
                // .jumpToPage(_pageController.page.ceil() - 1);
              },
            ),

            //BOTTOM RESPONDER
            RaisedButton(
              color: progress.containsKey(progress[currentIndex])
                  ? Colors.green
                  : Colors.red,
              onPressed: () {
                if (progress.containsKey(progress[currentIndex]))
                  setState(() {
                    progress.remove(progress[currentIndex]);
                  });
                else if (selectedRadio == null) {
                  _notSelected();
                } else {
                  setState(() {
                    /**** SAVE RESPOSTA ON DB ****/
                    simRsp.userIdSimulado = userDados['UID'].toString();
                    simRsp.questionSimuladoId = _questions[currentIndex]
                    ['id'].toString();
                    simRsp.idCategorySimulado = widget.category_id.toString();
                    simRsp.timeSimulado = elapsedTime;
                    simRsp.respostaSimuladoId = _questions[currentIndex]
                    ['answer'];
                    simRsp.respostaEscolhida = questionsResposta;
                    simRsp.totalQuestions = _questions.length.toString();
                    simRsp.position = (currentIndex + 1).toString();
                    simRsp.titleSimulado = _questions[currentIndex]
                    ['title'];
                    simRsp.explanationSimulado = _questions[currentIndex]
                    ['explanation'];


                    if(questionsResposta == _questions[currentIndex]
                    ['answer']){
                      print('ACERTOU');
                      simRsp.acertouSimulado = "1";
                    }else{
                      print('ERROU');
                      simRsp.acertouSimulado = "0";
                    }
                    print('RESPOSTA QUESTAO:${_questions[currentIndex]
                    ['answer']}');
                    stopWatch();
                    //SALVAR RESPOSTA NO BD
                    helper.saveRespostaSimulado(simRsp);

                    progress[currentIndex] = currentIndex;
                    print("Resposta: $questionsResposta");
                    print("Total: $total");
                  });
                }
              },
              child: Text(
                progress.containsKey(progress[currentIndex])
                    ? 'Respondida'
                    : 'Responder',
                style: TextStyle(color: Colors.white),
              ),
              splashColor: Colors.red,
            ),

           //BOTTOM AVANCAR/FINALIZAR SIMULADO
            total == (currentIndex+1) ? RaisedButton(
              child: Icon(
                Icons.check,
                color: Colors.white,
              ),
              color: Colors.green[600],
              onPressed: () {
                _getTotalQuestionsResolvidas(widget.category_id.toString(), userDados['UID']);

              }

            ):
            RaisedButton(
              child: Icon(
                FontAwesomeIcons.arrowCircleRight,
                color: Colors.white,
              ),
              color: Colors.black45,
              onPressed: () {
                _pageController.animateToPage(_pageController.page.ceil() + 1,
                    duration: Duration(seconds: 1), curve: Curves.fastLinearToSlowEaseIn);
                // .jumpToPage(_pageController.page.ceil() + 1);
              },
            ),
          ],
        ),
      ),
    );
  }

  getTile(key) {
    int index = key;
    bool hasVisited = progress[key] != null;
    return GestureDetector(
      onTap: () {
        setState(() {
          _pageController.jumpToPage(index);
          Navigator.pop(context);
        });
      },
      child: Container(
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: currentIndex == index
                  ? Colors.green[900]
                  : Colors.black12),
          color: hasVisited ? Colors.green : Colors.white,
        ),
        child: Text(
          "${index + 1}",
          style: TextStyle(
            color: hasVisited ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

  _getQuestions() async {
    setState(() {
      _isLoading = true;
    });


    try {
      dio.options.baseUrl = "${AppSettings.url}api/";
      dio.interceptors
        ..add(CacheInterceptor())
        ..add(LogInterceptor(requestHeader: false, responseHeader: false));

      await dio
          .get("simulados/${widget.category_id}/questions",
              options: Options(extra: {'refresh': true}))
          .then((result) async {
        await _getUserPrefs();
        _questions = result.data['questoes'];

        helper.deleteQuestionsBySimulado(widget.category_id, userDados['UID']);

        //print(_questions);

        //_questions.shuffle();

        setState(() {
          _isLoading = false;
        });
        startWatch();
      });
    } catch (e) {
      print(e);
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

  void _notSelected() {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('Selecione uma opção!'),
        backgroundColor: Theme.of(context).accentColor,
        duration: Duration(seconds: 2)));
  }



  Future<bool> _onWillPop() async {
    return showDialog<bool>(
        context: context,
        builder: (_) {
          return AlertDialog(
            content: Text(
                "Você tem que certeza que quer sair?"),
            title: Text("Aviso!"),
            actions: <Widget>[
              FlatButton(
                child: Text("Sim"),
                onPressed: () async {
                  await helper.deleteQuestionsBySimulado(widget.category_id, userDados['UID']);
                  Navigator.of(context).pop();
                  Navigator.of(context).push(new MaterialPageRoute(
                      builder: (context) => HomeScreen()));
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

  Future<bool> _onWillPopFinalizarSimulado() async {
    print("Total Question Resolvidas: $totalQuestionsResolvidas");
    print("Index: ${currentIndex+1}");
    return showDialog<bool>(
        context: context,
        builder: (_) {
          if(totalQuestionsResolvidas == (currentIndex+1)){
            return AlertDialog(
              content: totalQuestionsResolvidas > 0 ? Text(
                  "Você respondeu $totalQuestionsResolvidas de um total de ${_questions.length} questões. \nTem certeza que deseja finalizar o simulado?")
                  :Text("Você precisa resolver pelo menos uma questão para finalizar o simulado."),
              title: Text("Finalizar Simulado!"),
              actions: <Widget>[
                totalQuestionsResolvidas > 0 ? FlatButton(
                  child: Icon(Icons.check),
                  onPressed: () {
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => SimuladoResultadoScreen(widget.category_id, widget.category_name)));
                  },
                ):Container(),
                FlatButton(
                  child: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }else{
            return AlertDialog(
              content: Text("Para finalizar o simulado você precisa responder todas as questões."),
              title: Text("Finalizar Simulado!"),
              actions: <Widget>[

                FlatButton(
                  child: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          }

        });
  }

  _getUserPrefs() async{
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userDados = jsonDecode(prefs.getString('userDados'));
      print("USERDADOS:$userDados");

    });
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

  bool _backButtonInterceptor(bool stopDefaultButtonEvent) {
    print("BACK BUTTON!"); // Do some stuff.
    _onWillPop();
  }

  /// FIM TIMER

}
