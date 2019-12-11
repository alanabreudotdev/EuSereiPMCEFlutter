import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import '../teorias/lei_seca_categorias.dart';
import '../question_category_child_screen.dart';
import '../transgressoes/transgressoes_screen.dart';
import '../edital_verticalizado/edital_verticalizado_disciplinas_screen.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_card/animated_card.dart';

class ConcursosCategoriasScreen extends StatefulWidget {
  final id;
  final type;
  final cargo;
  final imageCategory;

  ConcursosCategoriasScreen(this.id, this.type, this.cargo, this.imageCategory);

  @override
  _ConcursosCategoriasScreenState createState() =>
      _ConcursosCategoriasScreenState();
}

class _ConcursosCategoriasScreenState extends State<ConcursosCategoriasScreen> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey();

  bool _isLoading = false;
  bool themeDefault;

  var dio = Dio();

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
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
                    Container(
                      decoration: BoxDecoration(
                        color:
                            themeDefault ? Colors.grey[800] : Colors.grey[200],
                      ),
                      child: Column(
                        children: <Widget>[
                          AppSettings().appBar(
                              context: context,
                              title: widget.type,
                              hasMenu: false,
                              hasBack: true,
                              scaffoldkey: _scaffold.currentState,
                              icon: FontAwesomeIcons.edit),
                          Hero(
                            tag: widget.type,
                            child: ClipRRect(
                              child: CachedNetworkImage(
                                imageUrl: widget.imageCategory,
                                placeholder: (context, url) =>
                                    new AppSettings().buildProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    new Icon(Icons.error),
                                width: 100,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          SizedBox(height: 5,),
                          new Text(
                            "Cargo: ${widget.cargo}".toUpperCase(),
                            style: TextStyle(
                              //color: Colors.black45,
                                fontSize: 12.0,
                                fontWeight: FontWeight.w400),
                          ),

                          SizedBox(
                            height: 30,
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        children: <Widget>[
                          /**
                           * parte teorica
                           */
                          AnimatedCard(
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
                                                    "Teoria"
                                                        .toString()
                                                        .toUpperCase(),
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      //color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    "Legislação comentada, Lei Seca, Disciplinas básicas.",
                                                    softWrap: true,
                                                    style: TextStyle(
                                                        //color: Colors.black,
                                                        fontSize: 12.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Material(
                                              color: Color(int.parse(
                                                  AppSettings.primaryColor)),
                                              borderRadius:
                                                  BorderRadius.circular(24.0),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 30.0),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ), onTap: () {
                                  Navigator.of(context)
                                      .push(new PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        LeiSecaCategorias(),
                                    transitionsBuilder: (context, animation,
                                            secondaryAnimation, child) =>
                                        new FadeTransition(
                                            opacity: animation,  child: child),
                                  ));
                                }),
                              )),

                          /**
                           * QUESTÕES
                           */
                        widget.id != "2" ? AnimatedCard(
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
                                                    "Questões"
                                                        .toString()
                                                        .toUpperCase(),
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      //color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    "Questões para exercitar e reforçar os estudos",
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      //color: Colors.black,
                                                        fontSize: 12.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Material(
                                              color: Color(int.parse(
                                                  AppSettings.primaryColor)),
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 30.0),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ), onTap: () {
                                  Navigator.of(context)
                                      .push(new PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        QuestionCategoryChild(widget.id, widget.type, widget.imageCategory),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    new FadeTransition(
                                        opacity: animation, child: child),
                                  ));
                                }),
                              )):Container(),
                          /**
                           * TRANSGRESSOES
                           */
                          AnimatedCard(
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
                                                    "Transgressões"
                                                        .toString()
                                                        .toUpperCase(),
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      //color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    "Pratique as transgressões e fique fera",
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      //color: Colors.black,
                                                        fontSize: 12.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Material(
                                              color: Color(int.parse(
                                                  AppSettings.primaryColor)),
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 30.0),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ), onTap: () {
                                      var transgressao = "Transgressões - ${widget.type}";
                                  Navigator.of(context)
                                      .push(new PageRouteBuilder(
                                    pageBuilder: (_, __, ___) => TransgressoesScreen(widget.id,
                                        transgressao
                                          .toString(),
                                      0),

                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    new FadeTransition(
                                        opacity: animation, child: child),
                                  ));
                                }),
                              )),
                          /**
                           * EDITAL VERTICALIZADO
                           */
                          AnimatedCard(
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
                                                    "Edital Verticalizado"
                                                        .toString()
                                                        .toUpperCase(),
                                                    overflow: TextOverflow.fade,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      //color: Colors.black,
                                                      fontWeight:
                                                      FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 200,
                                                  child: Text(
                                                    "Controle o seus estudos com o edital verticalizado",
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      //color: Colors.black,
                                                        fontSize: 12.0),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Material(
                                              color: Color(int.parse(
                                                  AppSettings.primaryColor)),
                                              borderRadius:
                                              BorderRadius.circular(24.0),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Icon(
                                                      Icons.arrow_forward_ios,
                                                      size: 30.0),
                                                ),
                                              ),
                                            ),
                                          ]),
                                    ), onTap: () {
                                  Navigator.of(context)
                                      .push(new PageRouteBuilder(
                                    pageBuilder: (_, __, ___) =>
                                        EditalVerticalizadoDisciplinaScreen(widget.id, widget.type, widget.imageCategory),
                                    transitionsBuilder: (context, animation,
                                        secondaryAnimation, child) =>
                                    new FadeTransition(
                                        opacity: animation, child: child),
                                  ));
                                }
                                    ),
                              ))
                        ],
                      ),
                    )
                  ],
                )),
    );
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
    themeDefault = await AppSettings().getThemeDefault();
    setState(() {
      _isLoading = false;

      print("THEME: ${themeDefault}");
    });
  }
}
