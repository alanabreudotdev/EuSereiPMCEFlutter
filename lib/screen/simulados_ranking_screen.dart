import 'package:flutter/material.dart';
import 'dart:io';
import 'package:share/share.dart';
import '../utils/appsettings.dart';
import '../utils/api.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animated_card/animated_card.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class SimuladosRankingScreen extends StatefulWidget {
  final title;
  final categoryIdSimulado;

  SimuladosRankingScreen(this.title, this.categoryIdSimulado);

  @override
  _SimuladosRankingScreenState createState() => _SimuladosRankingScreenState();
}

class _SimuladosRankingScreenState extends State<SimuladosRankingScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();
  List dadosRnk;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      _isLoading = true;
    });
    _getDados();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
          body: _isLoading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child:  Column(
                    children: <Widget>[

                      AppSettings().appBar(
                          context: context,
                          title: "Ranking ${widget.title}",
                          hasMenu: false,
                          hasBack: true,
                          scaffoldkey: _scaffold.currentState,
                          icon: FontAwesomeIcons.listOl),
                      SizedBox(height: 10,),
                      dadosRnk.isEmpty
                          ? Center(
                        child: Text('Ranking vazio'),
                      )
                          : Expanded(
                          child: ListView.builder(
                              itemCount: dadosRnk.length,
                              itemBuilder: (context, AppSettings) {
                                return AnimatedCard(
                                  curve: Curves.bounceOut,
                                    direction: AnimatedCardDirection
                                        .left, //Initial animation direction
                                    initDelay: Duration(
                                        milliseconds:
                                        0), //Delay to initial animation
                                    duration: Duration(
                                        seconds: 2), //Initial animation duration
                                    child:
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10.0, vertical: 5),
                                            child: Column(
                                              children: <Widget>[

                                                Container(
                                                  child: Stack(
                                                    children: <Widget>[
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15.0),
                                                        margin: const EdgeInsets.only(top: 4 ,left: 35.0, right: 5.0,bottom: 10.0),
                                                        decoration: BoxDecoration(
                                                            color: Colors.grey[200],
                                                            borderRadius: BorderRadius.circular(20.0)
                                                        ),
                                                        child: Row(
                                                          children: <Widget>[
                                                            SizedBox(
                                                              width: 50,
                                                              child: CircleAvatar(
                                                                backgroundColor: Colors.transparent,
                                                                child: Text(
                                                                  (AppSettings + 1).toString(),
                                                                  style: TextStyle(
                                                                      color: Colors.black,
                                                                      fontWeight: FontWeight.w500),
                                                                ),
                                                              ),


                                                            ),

                                                            Expanded(child: Text(dadosRnk[AppSettings]['name'],style: TextStyle(
                                                                color: Colors.black,
                                                                fontWeight: FontWeight.w500), textAlign: TextAlign.center,),),

                                                            Text(
                                                              "${dadosRnk[AppSettings]['pontuacao']}",
                                                              textAlign: TextAlign.center,
                                                              style: TextStyle(
                                                                  color: Colors.black,
                                                                  fontWeight: FontWeight.w500),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      FloatingActionButton(
                                                        child: CircleAvatar(
                                                            radius: 40,
                                                            backgroundColor: Colors.white,
                                                            child: Material(
                                                              child: CachedNetworkImage(
                                                                fadeInCurve: Curves.easeInOut,
                                                                placeholder:
                                                                    (context, url) =>
                                                                    Container(
                                                                      child:
                                                                      CircularProgressIndicator(
                                                                        strokeWidth: 1.0,
                                                                        valueColor:
                                                                        AlwaysStoppedAnimation<
                                                                            Color>(
                                                                            Colors.amber),
                                                                      ),
                                                                      width: 60.0,
                                                                      height: 60.0,
                                                                      padding:
                                                                      EdgeInsets.all(0.0),
                                                                    ),
                                                                imageUrl: dadosRnk[AppSettings]
                                                                ["photo_url"],
                                                                width: 50.0,
                                                                height: 50.0,
                                                                fit: BoxFit.cover,
                                                              ),
                                                              borderRadius:
                                                              BorderRadius.all(
                                                                  Radius.circular(
                                                                      40.0)),
                                                              clipBehavior: Clip.hardEdge,
                                                            )),
                                                        backgroundColor: Colors.white,
                                                        onPressed: (){},
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              ],
                                            ))
                                    );
                              }),)
                    ],
                  )
                )),
    );
  }

  _getDados() async {
    var response = await CallApi().getData('ranking/${widget.categoryIdSimulado}/get');
    if (response['success']) {
      setState(() {
        dadosRnk = response['data'];
        _isLoading = false;
      });
    } else {
      AppSettings().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'OPS!',
          message:
              'Não foi possível carregar as informações. Tente novamente e certifique-se de estar conectado a internet.',
          buttonLabel: "Voltar");
    }
  }
}
