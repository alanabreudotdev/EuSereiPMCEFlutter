import 'package:flutter/material.dart';
import '../model/category_model.dart';
import '../utils/appsettings.dart';
import 'question_screen.dart';
import '../utils/cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widget/separator.dart';
import 'package:animated_card/animated_card.dart';
import 'dart:convert';

class QuestionCategoryChild extends StatefulWidget {
  final id;
  final type;
  final imageCategory;

  QuestionCategoryChild(this.id, this.type, this.imageCategory);

  @override
  _QuestionCategoryChildState createState() => _QuestionCategoryChildState();
}

class _QuestionCategoryChildState extends State<QuestionCategoryChild> {
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
                  child: AppSettings()
                      .buildProgressIndicator(isLoading: _isLoading))
              : Column(
                  children: <Widget>[
                    Column(
                        children: <Widget>[
                          AppSettings().appBar(
                              context: context,
                              title: 'QUESTÕES',
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
                          return  AnimatedCard(
                              direction: AnimatedCardDirection.top,
                              curve: Curves.easeInOutCubic,//Initial animation direction
                              initDelay: Duration(milliseconds: 0), //Delay to initial animation
                          duration: Duration(seconds: 1), //Initial animation duration
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AppSettings().buildTile(
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
                                          SizedBox(width: 200,
                                          child: Text(_categories[index]['title']
                                              .toString()
                                              .toUpperCase(),
                                              overflow: TextOverflow.fade,
                                              softWrap: true,
                                              ),),


                                            Row(
                                              children: <Widget>[
                                                Text(_categories[index]['question_count'] == 0 ? "": "${_categories[index]['question_count'].toString()}",
                                                    style: TextStyle(
                                                        //color: Colors.black,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 34.0)),
                                                Text(" questões",
                                                    style: TextStyle(
                                                        //color: Colors.black,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 14.0)),

                                              ],
                                            ),

                                        ],
                                      ),
                                      Material(
                                          color: Color(int.parse(AppSettings.primaryColor)),
                                          borderRadius: BorderRadius.circular(24.0),
                                          child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(16.0),
                                                child: Icon(Icons.arrow_forward_ios,
                                                     size: 30.0),
                                              ),
                                          ),
                                      ),
                                    ]),
                              ),
                              onTap: (){
                                /*
                                _categories[index]['children_count'] == 0
                                    ? Navigator.of(context).push(
                                    new PageRouteBuilder(
                                        pageBuilder: (_, __, ___) => QuestionScreen(
                                            widget
                                                .category_id,
                                            widget
                                                .category_name,
                                            widget.dadosFiltros,
                                            widget.assuntosId,
                                            0),
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                      new FadeTransition(opacity: animation, child: child),
                                    ))
                                    : Navigator.of(context).push(
                                    new MaterialPageRoute(
                                        builder: (context) =>
                                            QuestionCategoryChild(
                                              _categories[index]['id']
                                                  .toString(),
                                              _categories[index]['paid'] == 0
                                                  ? 'free'
                                                  : 'premium',
                                              "${AppSettings.url}/uploads/category/${_categories[index]['thumbnail']}",
                                            )));
                                            */
                              }
                            ),
                          )
                          );

                           /* InkWell(
                            onTap: () {
                              _categories[index]['children_count'] == 0
                                  ? Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) => QuestionScreen(
                                              _categories[index]['id']
                                                  .toString(),
                                              _categories[index]['title']
                                                  .toString(),
                                              0)))
                                  : Navigator.of(context).push(
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              QuestionCategoryChild(
                                                _categories[index]['id']
                                                    .toString(),
                                                _categories[index]['paid'] == 0
                                                    ? 'free'
                                                    : 'premium',
                                                "${AppSettings.url}/uploads/category/${_categories[index]['thumbnail']}",
                                              )));
                            },
                            child: Card(
                              margin: EdgeInsets.only(top: 10),
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: ListTile(
                                  title: Text(_categories[index]['title']
                                      .toString()
                                      .toUpperCase()),
                                  subtitle: Text(
                                      "${_categories[index]['description'].toString()}\n${_categories[index]['question_count'].toString()} questões"),
                                  //leading: Text(_categories[index]['question_count'] == 0 ? "": "${_categories[index]['question_count'].toString()}"),
                                  trailing: Icon(Icons.arrow_forward_ios),
                                ),
                              ),
                            ),
                          ); */
                        },
                      ),
                    ),

                  ],
                )),
    );
  }

  _cardCustom(
      {BuildContext context,
      String image,
      String title,
      String subtitle,
      String questoes}) {
    return new Container(
        height: 130.0,
        margin: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 24.0,
        ),
        child: new Stack(
          children: <Widget>[
            Container(
              child: Container(
                margin: new EdgeInsets.fromLTRB(76.0, 16.0, 16.0, 16.0),
                constraints: new BoxConstraints.expand(),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(height: 3.0),
                    new Text(
                      title,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600),
                    ),
                    new Container(height: 4.0),
                    new Separator(),
                    new Text(
                      subtitle,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w400),
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Expanded(
                            flex: 1,
                            child: Container(
                              child: new Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Icon(
                                      FontAwesomeIcons.edit,
                                      size: 11.0,
                                      color: Colors.white70,
                                    ),
                                    new Container(width: 8.0),
                                    new Text('Questoes: ',
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w400)),
                                  ]),
                            )),
                        new Container(
                          width: 8.0,
                        ),
                        new Expanded(
                            flex: 1,
                            child: Container(
                              child: new Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    new Text(questoes,
                                        style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11.0,
                                            fontWeight: FontWeight.w400)),
                                  ]),
                            ))
                      ],
                    ),
                  ],
                ),
              ),
              height: 124.0,
              margin: new EdgeInsets.only(left: 46.0),
              decoration: new BoxDecoration(
                color: Color(0xffcb4336),
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.0),
                  ),
                ],
              ),
            ),
            Container(
              margin: new EdgeInsets.symmetric(vertical: 16.0),
              alignment: FractionalOffset.centerLeft,
              child: new Image(
                image: new CachedNetworkImageProvider(image),
                height: 92.0,
                width: 92.0,
              ),
            ),
          ],
        ));
  }

/*
  void _getCategorias() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await CallApi().getData('categories/${widget.id}/premium').then((result){
        print(result);
        setState(() {
          _categories = result;
          _isLoading = false;
        });

      });



    } catch (e) {
      print(e);
    }
  }
  */

  _getDados() async {

    setState(() {
      _isLoading = true;

      print("THEME: ${themeDefault}");
    });

    String data = await DefaultAssetBundle.of(context).loadString("assets/json/pmce_disciplinas.json");
    _categories = json.decode(data);
    print(_categories);

    themeDefault = await AppSettings().getThemeDefault();

    setState(() {
      _isLoading = false;
    });

   /* try {
      dio.options.baseUrl = "${AppSettings.url}api/";
      dio.interceptors
        ..add(CacheInterceptor())
        ..add(LogInterceptor(requestHeader: false, responseHeader: false));

      var response = await dio.get("/questions/edital/${widget.id}/disciplinas",
          options: Options(extra: {'refresh': true}));
      setState(() {
        _categories = response.data;
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
    */
  }
}
