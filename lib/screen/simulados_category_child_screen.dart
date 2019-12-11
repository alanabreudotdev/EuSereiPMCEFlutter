import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../utils/appsettings.dart';
import 'dart:convert';
import '../utils/api.dart';
import 'question_screen.dart';
import '../utils/cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'simulados_questions_screen.dart';
import 'simulados_resultado_screen.dart';
import 'simulado_gabarito_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'simulados_ranking_screen.dart';
import 'package:animated_card/animated_card.dart';
import 'simulados_instrucoes_screen.dart';

class SimuladosCategoryChild extends StatefulWidget {
  final id;
  final type;

  SimuladosCategoryChild(this.id, this.type);

  @override
  _SimuladosCategoryChildState createState() => _SimuladosCategoryChildState();
}

class _SimuladosCategoryChildState extends State<SimuladosCategoryChild> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  List _categories;
  bool _isLoading = false;

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
            ? Center(child: CircularProgressIndicator())
            :
        Column(
          children: <Widget>[
            AppSettings().appBar(
                context: context,
                title: 'SIMULADOS',
                hasMenu: false,
                hasBack: true,
                scaffoldkey: _scaffold.currentState,
                icon: FontAwesomeIcons.listOl),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: _categories == null ? 0 : _categories.length,
                  itemBuilder: (context, index) {
                    return AppSettings().buildTile(
                        AnimatedCard(
                            direction: AnimatedCardDirection.bottom, //Initial animation direction
                            initDelay: Duration(milliseconds: 0), //Delay to initial animation
                            duration: Duration(seconds: 1), //Initial animation duration
                            child: Padding(
                          padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            width: 100,
                            child: Icon(FontAwesomeIcons.thList),/*CachedNetworkImage(
                              imageUrl:
                              "${AppSettings.url}/uploads/category/${_categories[index]['thumbnail']}",
                              placeholder: (context, url) =>
                              new CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                              new Icon(Icons.error),
                            ), */
                          ),
                          SizedBox(height: 10,),
                          Text("${_categories[index]['title']
                                .toString()
                                .toUpperCase()}",
                            softWrap: true,
                          style: TextStyle(fontWeight: FontWeight.w500, fontSize: 18),),
                          Text("${_categories[index]['description'].toString()}\n${_categories[index]['question_count'].toString()} questões", textAlign: TextAlign.center,),
                          SizedBox(height: 10,),
                          Divider(),
                          Column(
                            children: <Widget>[
                              Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        _categories[index]['children_count'] == 0
                                            ? Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context)
                                                // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                                =>
                                                    SimuladoInstrucoes(
                                                        _categories[index]['id']
                                                            .toString(),
                                                        _categories[index]
                                                        ['title']
                                                            .toString())))
                                            : Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    SimuladosCategoryChild(
                                                        _categories[index]['id']
                                                            .toString(),
                                                        _categories[index]
                                                        ['paid'] ==
                                                            0
                                                            ? 'free'
                                                            : 'premium')));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.edit),
                                          SizedBox(height: 5,),
                                          Text('Resolver', style: TextStyle(fontSize: 11),)
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    InkWell(
                                      onTap: () {
                                        _categories[index]['children_count'] == 0
                                            ? Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context)
                                                // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                                =>
                                                    SimuladoResultadoScreen(_categories[index]['id']
                                                        .toString(),
                                                        _categories[index]
                                                        ['title']
                                                            .toString())))
                                            : Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    SimuladosCategoryChild(
                                                        _categories[index]['id']
                                                            .toString(),
                                                        _categories[index]
                                                        ['paid'] ==
                                                            0
                                                            ? 'free'
                                                            : 'premium')));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.pollH),
                                          SizedBox(height: 5,),
                                          Text('Resultado', style: TextStyle(fontSize: 11),)
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    InkWell(
                                      onTap: () {
                                        _categories[index]['children_count'] == 0
                                            ? Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context)
                                                // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                                =>
                                                    SimuladosRankingScreen(
                                                        _categories[index]
                                                        ['title']
                                                            .toString(), _categories[index]['id']
                                                        .toString())))
                                            : Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    SimuladosCategoryChild(
                                                        _categories[index]['id']
                                                            .toString(),
                                                        _categories[index]
                                                        ['paid'] ==
                                                            0
                                                            ? 'free'
                                                            : 'premium')));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.chartBar),
                                          SizedBox(height: 5,),
                                          Text('Ranking', style: TextStyle(fontSize: 11),)
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 15,),
                                    InkWell(
                                      onTap: () {
                                        _categories[index]['children_count'] == 0
                                            ? Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context)
                                                // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                                =>
                                                    SimuladoGabaritoScreen(_categories[index]['id'].toString())))
                                            : Navigator.of(context).push(
                                            new MaterialPageRoute(
                                                builder: (context) =>
                                                    SimuladosCategoryChild(
                                                        _categories[index]['id']
                                                            .toString(),
                                                        _categories[index]
                                                        ['paid'] ==
                                                            0
                                                            ? 'free'
                                                            : 'premium')));
                                      },
                                      child: Column(
                                        children: <Widget>[
                                          Icon(FontAwesomeIcons.listOl),
                                          SizedBox(height: 5,),
                                          Text('Gabarito', style: TextStyle(fontSize: 11),)
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          )
                        ],
                      ),)
                      /*
                        Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              leading: CachedNetworkImage(
                                imageUrl:
                                "${AppSettings.url}/uploads/category/${_categories[index]['thumbnail']}",
                                placeholder: (context, url) =>
                                new CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                new Icon(Icons.error),
                              ),
                              title: Text(_categories[index]['title']
                                  .toString()
                                  .toUpperCase()),
                              subtitle: Text(
                                  "${_categories[index]['description'].toString()}\n${_categories[index]['question_count'].toString()} questões"),
                              //leading: Text(_categories[index]['question_count'] == 0 ? "": "${_categories[index]['question_count'].toString()}"),
                            ),
                            SizedBox(height: 5),
                            Divider(),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  InkWell(
                                    onTap: () {
                                      _categories[index]['children_count'] == 0
                                          ? Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context)
                                              // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                              =>
                                                  SimuladoInstrucoes(
                                                      _categories[index]['id']
                                                          .toString(),
                                                      _categories[index]
                                                      ['title']
                                                          .toString())))
                                          : Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  SimuladosCategoryChild(
                                                      _categories[index]['id']
                                                          .toString(),
                                                      _categories[index]
                                                      ['paid'] ==
                                                          0
                                                          ? 'free'
                                                          : 'premium')));
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(FontAwesomeIcons.edit),
                                        SizedBox(height: 5,),
                                        Text('Resolver')
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _categories[index]['children_count'] == 0
                                          ? Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context)
                                              // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                              =>
                                                  SimuladoResultadoScreen(_categories[index]['id']
                                                      .toString(),
                                                      _categories[index]
                                                      ['title']
                                                          .toString())))
                                          : Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  SimuladosCategoryChild(
                                                      _categories[index]['id']
                                                          .toString(),
                                                      _categories[index]
                                                      ['paid'] ==
                                                          0
                                                          ? 'free'
                                                          : 'premium')));
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(FontAwesomeIcons.pollH),
                                        SizedBox(height: 5,),
                                        Text('Resultado')
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _categories[index]['children_count'] == 0
                                          ? Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context)
                                              // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                              =>
                                                  SimuladosRankingScreen(
                                                      _categories[index]
                                                      ['title']
                                                          .toString(), _categories[index]['id']
                                                      .toString())))
                                          : Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  SimuladosCategoryChild(
                                                      _categories[index]['id']
                                                          .toString(),
                                                      _categories[index]
                                                      ['paid'] ==
                                                          0
                                                          ? 'free'
                                                          : 'premium')));
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(FontAwesomeIcons.chartBar),
                                        SizedBox(height: 5,),
                                        Text('Ranking')
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      _categories[index]['children_count'] == 0
                                          ? Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context)
                                              // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                                              =>
                                                  SimuladoGabaritoScreen(_categories[index]['id'].toString())))
                                          : Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (context) =>
                                                  SimuladosCategoryChild(
                                                      _categories[index]['id']
                                                          .toString(),
                                                      _categories[index]
                                                      ['paid'] ==
                                                          0
                                                          ? 'free'
                                                          : 'premium')));
                                    },
                                    child: Column(
                                      children: <Widget>[
                                        Icon(FontAwesomeIcons.listOl),
                                        SizedBox(height: 5,),
                                        Text('Gabarito')
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),*/
                        )
                    );
                  },
                ),
              ),
            ),
          ],
        )
      )
    );
  }

  _getDados() async {
    setState(() {
      _isLoading = true;
    });
    try {
      dio.options.baseUrl = "${AppSettings.url}api/";
      dio.interceptors
        ..add(CacheInterceptor())
        ..add(LogInterceptor(requestHeader: false, responseHeader: false));

      var response = await dio.get("simulados",
          options: Options(extra: {'refresh': true}));
      setState(() {
        _categories = response.data;
        print(_categories);
        _isLoading = false;
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
