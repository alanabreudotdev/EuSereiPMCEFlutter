import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/appsettings.dart';
import '../model/user_model.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_images_slider/flutter_images_slider.dart';
import 'dart:io';
import 'package:rate_my_app/rate_my_app.dart';
import 'package:dio/dio.dart';
import '../utils/cache_interceptor.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'package:animated_card/animated_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../model/question_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InitialScreen extends StatefulWidget {
  @override
  _InitialScreenState createState() => _InitialScreenState();
}

class _InitialScreenState extends State<InitialScreen> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  QuestionHelper helper = QuestionHelper();
  QuestionResposta qstRes = QuestionResposta();

  int TotalHoje = 0;
  int Total = 0;
  int Acertos = 0;
  int Erros = 0;
  double percAcertos;
  double percErros;
  var perc;
  var tempoGasto;
  var tempoMedio;
  var UID;

  Map userDados;

  List<dynamic> _banners;
  bool _isLoading = false;

  List<T> map<T>(List list, Function handler) {
    List<T> result = [];
    for (var i = 0; i < list.length; i++) {
      result.add(handler(i, list[i]));
    }
    return result;
  }

  int _current = 0;

  RateMyApp _rateMyApp = RateMyApp(
    preferencesPrefix: 'rateMyApp_',
    googlePlayIdentifier: 'moral2.0',
    appStoreIdentifier: '1484519263',
    minDays: 3,
    minLaunches: 5,
    remindDays: 7,
    remindLaunches: 10,
  );

  Dio dio = Dio();

  @override
  void initState() {
    super.initState();
    _rateMyApp.init().then((_) {
      if (_rateMyApp.shouldOpenDialog) {
        if (Platform.isAndroid) {
          _rateMyApp.showRateDialog(
            context,
            title: 'Avalie o APP',
            message:
                'Se você gostou do ${AppSettings.app_name}, por gentileza, deixe sua avaliação, é muito importante para nós!\nNos ajudará com seu feedback e não levará nem um minuto.',
            rateButton: 'AVALIAR',
            noButton: '',
            laterButton: 'DEPOIS',
            ignoreIOS: false,
            dialogStyle: DialogStyle(),
          );
        } else {
          _rateMyApp.showStarRateDialog(
            context,
            title: 'Avalie o App',
            message:
                'Você gostou do ${AppSettings.app_name}? Por gentileza, dedique um pouco do seu tempo para deixar uma classificação :',
            onRatingChanged: (stars) {
              return [
                FlatButton(
                  child: Text('OK'),
                  onPressed: () {
                    print('Obrigado pela(s) ' +
                        (stars == null ? '0' : stars.round().toString()) +
                        ' estrela(s) !');
                    // You can handle the result as you want (for instance if the user puts 1 star then open your contact page, if he puts more then open the store page, etc...).
                    _rateMyApp.doNotOpenAgain = true;
                    _rateMyApp.save().then((v) => Navigator.pop(context));
                  },
                ),
              ];
            },
            ignoreIOS: false,
            dialogStyle: DialogStyle(
              titleAlign: TextAlign.center,
              messageAlign: TextAlign.center,
              messagePadding: EdgeInsets.only(bottom: 20),
            ),
            starRatingOptions: StarRatingOptions(),
          );
        }
      }
    });
    _getDados();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScopedModelDescendant<UserModel>(builder: (context, child, model) {
      model.isLoggedIn() ? UID = model.firebaseUser.uid : UID = null;

      return _isLoading
          ? AppSettings().buildProgressIndicator(isLoading: _isLoading)
          : Scaffold(
              body: StaggeredGridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
                children: <Widget>[
                  AppSettings().appBar(
                      context: context,
                      title: AppSettings.app_name,
                      hasMenu: true,
                      scaffoldkey: _scaffoldKey.currentState,
                      icon: FontAwesomeIcons.stream),
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
                                Text('Resolvi hoje',
                                    style: TextStyle(color: Colors.lightGreen)),
                                Row(
                                  children: <Widget>[
                                    Text(TotalHoje.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 34.0)),
                                    Text(' questões',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.0))
                                  ],
                                )
                              ],
                            ),
                            Material(
                              //color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                child: Center(
                                  child: new SvgPicture.asset(
                                    "assets/images/icons/undraw_segment_analysis_bdn4.svg",
                                    semanticsLabel: 'A red up arrow',
                                    width: 120,
                                  ),
                                )),
                          ]),
                    ),
                  ),
                  AppSettings().buildTile(
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Material(
                              //color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                child: Center(
                                  child: new SvgPicture.asset(
                                    "assets/images/icons/undraw_instat_analysis_ajld.svg",
                                    semanticsLabel: 'A red up arrow',
                                    width: 120,
                                  ),
                                )),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text('Resolvi total de',
                                    style: TextStyle(color: Colors.blueAccent)),
                                Row(
                                  children: <Widget>[
                                    Text(Total.toString(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 34.0)),
                                    Text(' questões',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.0))
                                  ],
                                )
                              ],
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
                              //color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                child: Center(
                                  child: new SvgPicture.asset(
                                    "assets/images/icons/undraw_done_a34v.svg",
                                    semanticsLabel: 'A red up arrow',
                                    width: 120,
                                  ),
                                )),
                            Padding(padding: EdgeInsets.only(bottom: 16.0)),
                            Text(
                                percAcertos == null
                                    ? '0%'
                                    : "${percAcertos.toStringAsFixed(0)}%",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24.0)),
                            Text('Acertos'),
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
                              //color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                child: Center(
                                  child: new SvgPicture.asset(
                                    "assets/images/icons/undraw_cancel_u1it.svg",
                                    semanticsLabel: 'A red up arrow',
                                    width: 120,
                                  ),
                                )),
                            Padding(padding: EdgeInsets.only(bottom: 16.0)),
                            Text(
                                percErros == null
                                    ? '0%'
                                    : "${percErros.toStringAsFixed(0)}%",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24.0)),
                            Text('Erros'),
                          ]),
                    ),
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
                                Text('Tempo total',
                                    style: TextStyle(color: Colors.redAccent)),
                                Text(
                                    tempoGasto == null
                                        ? '00:00:00'
                                        : "${tempoGasto}",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 30.0))
                              ],
                            ),
                            Material(
                              //color: Colors.white,
                                borderRadius: BorderRadius.circular(24.0),
                                child: Center(
                                  child: new SvgPicture.asset(
                                    "assets/images/icons/undraw_in_no_time_6igu.svg",
                                    semanticsLabel: 'A red up arrow',
                                    width: 120,
                                  ),
                                )),
                          ]),
                    ),
                    onTap: () {},
                  ),
                ],
                staggeredTiles: [
                  StaggeredTile.extent(2, 60.0),
                  StaggeredTile.extent(2, 113.0),
                  StaggeredTile.extent(2, 113.0),
                  StaggeredTile.extent(1, 200.0),
                  StaggeredTile.extent(1, 200.0),
                  StaggeredTile.extent(2, 113.0),
                ],
              ),
            );
    });
  }

  Container loadingPlaceHolder = Container(
    height: 300.0,
    child: Center(child: CircularProgressIndicator()),
  );

  _getDados() async {
    setState(() {
      _isLoading = true;
    });
    try {
      //dio.options.baseUrl = "${AppSettings.url}";
      dio.options.baseUrl = "https://www.appdomoral.com.br";
      dio.interceptors
        ..add(CacheInterceptor())
        ..add(LogInterceptor(requestHeader: false, responseHeader: false));

      var response = await dio.get("/slide_home.json",
          options: Options(extra: {'refresh': true}));
      setState(() {
        _banners = response.data;
        if (UID != null) {
          var dataHoje = AppSettings().convertStringFromDate();
          print("Data hoje: $dataHoje");

          _getDataDB(UID, dataHoje).then((result) {
            if (result["Total"] > 0) {
              TotalHoje = result["TotalHoje"];
              Acertos = result["Acertos"];
              Erros = result["Erros"];
              Total = result["Total"];
              percErros = result["percErros"];
              percAcertos = result["percAcertos"];
              tempoGasto = result["tempoGasto"];
              tempoMedio = result["tempoMedio"];
            }
            setState(() {
              _isLoading = false;
            });
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
        setState(() {
          _isLoading = false;
        });
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

  Future _getUserDados() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      userDados = jsonDecode(prefs.getString('userDados'));
    });

    return userDados;
  }

  Future _getDataDB(String userId, String dataHoje) async {
    return await helper.getQuestionsByUser(userId: userId, dataAtual: dataHoje);
  }
}
