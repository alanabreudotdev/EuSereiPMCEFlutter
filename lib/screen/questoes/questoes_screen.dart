import 'package:appdomoral/model/questao_estatistica_model.dart';
import 'package:appdomoral/screen/questoes/questao_estatistica_screen.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../utils/appsettings.dart';
import '../../model/questoes_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:skeleton_text/skeleton_text.dart';
import 'dart:async';
import '../../model/user_model.dart';
import '../../utils/api.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';



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

  QuestionScreen(
      this.assuntosId,
      this.orgaosId,
      this.bancasId,
      this.cargosId,
      this.anosId,
      this.certo_errado,
      this.acertei,
      this.errei,
      this.resolvi,
      this.naoResolvi,
      this.aleatoria);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey<ScaffoldState>();

  int touchedIndex;

  var dataFiltros;
  Questoes questions;

  List<Data> itemQst;
  var nextPage;
  var hasPage;

  bool firstLoading = false;
  bool _isLoading = false;
  bool _isLoadingResposta = false;


  var currentPage;
  var totalPages;

  Color colorAcerto = Colors.green[300];
  Color colorErro = Colors.red[300];

  Dio dio = Dio();

  Color selectedColorItemA;
  Color selectedColorItemB;
  Color selectedColorItemC;
  Color selectedColorItemD;
  Color selectedColorItemE;

  Color itemSelectedA;
  Color itemSelectedB;
  Color itemSelectedC;
  Color itemSelectedD;
  Color itemSelectedE;

  bool selectedItemA = false;
  bool selectedItemB = false;
  bool selectedItemC = false;
  bool selectedItemD = false;
  bool selectedItemE = false;

  var selectedItem;

  bool itemIsSelected = false;

  bool itemResposta = false;
  bool questaoRespondida = false;
  bool statusResposta = false; //false = errou ; true = acertou

  var dadosRespostaUser; //data to send via api to server with answer of user

  var UserUid;

  var themeDefault; //get if theme is dark or not

  ///BEGIN TIMER
  Stopwatch watch = new Stopwatch();
  Timer timer;
  bool _showTimer = true;
  String elapsedTime = '';

  @override
  void initState() {
    setState(() {
      firstLoading = true;
    });
    dataFiltros = {
      "assuntosId": widget.assuntosId,
      "orgaosId": widget.orgaosId,
      "bancasId": widget.bancasId,
      "cargosId": widget.cargosId,
      "anosId": widget.anosId,
      "certo_errado": widget.certo_errado,
      "acertei": widget.acertei,
      "errei": widget.errei,
      "resolvi": widget.resolvi,
      "naoResolvi": widget.naoResolvi,
      "aleatoria": widget.aleatoria,
    };

    // TODO: implement initState
    _getQuestions();
    resetWatch();
    super.initState();

  }

  @override
  void dispose() {
    resetWatch();
    stopWatch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SafeArea(
      child: Scaffold(
        key: _key,
        body:  ScopedModelDescendant<UserModel>(
            builder: (context, child, model) {
              UserUid = model.firebaseUser.uid;
              return firstLoading ? AppSettings().buildProgressIndicator(isLoading: firstLoading) :
       ListView.builder(
                  physics: BouncingScrollPhysics(),
                  itemCount: totalPages,
                  itemBuilder: (context, index) {

                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          AppSettings().appBar(
                              context: context,
                              title: 'QUESTÃO ${itemQst[index].id}',
                              hasMenu: false,
                              hasBack: true,
                              scaffoldkey: _key.currentState,
                              icon: Icons.book),

                          _isLoading ? _loadingCabecalho() : Container(
                            width: MediaQuery.of(context).size.width,
                            child: Card(
                              color: themeDefault ? Colors.grey[800] : Colors.blue.withOpacity(0.5),
                              elevation: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    //Text("Q${itemQst[index].id}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),),
                                    Text("Disciplina: ${itemQst[index].disciplina.nome}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),),
                                itemQst[index].assuntoId != null ?
                                    Text("Assunto: ${itemQst[index].assunto.nome}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),)
                                    :Container(),
                                    Text("Prova: ${itemQst[index].prova.nome}", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),),

                              ],
                                ),
                              ),
                            ),
                          ),
                          _isLoading ? Container() : Container(
                            width: double.infinity,
                            child: Card(
                              elevation: 0,
                              child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          itemQst[index].respostaUser != null
                                              ? itemQst[index].respostaUser.respostaUser == 0
                                                ? Row(children: <Widget>[
                                                    Icon(FontAwesomeIcons.windowClose, color: Colors.red),
                                                    SizedBox(width: 5,),
                                                    Text("Resolvi errado!", style: TextStyle(color: Colors.red, fontSize: 12),)
                                                  ],)
                                                : Row(children: <Widget>[
                                            Icon(FontAwesomeIcons.checkSquare, color: Colors.green,),
                                            SizedBox(width: 5,),
                                            Text("Resolvi Certo!",style: TextStyle(color: Colors.green, fontSize: 12),)
                                          ],)

                                              : Text("Não resolvida!",style: TextStyle(color: Colors.blue, fontSize: 12),)
                                        ],
                                      ),
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.timelapse),
                                          Text(elapsedTime, textAlign: TextAlign.center,),
                                        ],
                                      )
                                    ],
                                  )
                              ),
                            ),
                          ),
                          _isLoading ? _loadingEnunciado() : Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Html(
                              data: replaceLinkImage(itemQst[index].enunciado),
                              useRichText: true,
                            ),
                                  ),
                            _isLoading ? _isLoadingItems() : Card(
                                color: selectedColorItemA,
                                elevation: 0,
                                child: InkWell(

                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Html(
                                        data: replaceDivDiv(replaceSpaceFive(replaceSpanItem(replaceSpaceFour(replacePSpan(replaceSpaceThree(replaceQuebra(replaceSpace(replaceHiddenPrintTwo(replaceHiddenPrint(replaceLinkImageSpan(replaceLinkImage(replaceHmtlLabelOut(replaceHmtlLabelIn(replaceHtmlSpanOut(replaceHtmlSpanIn(replaceHtmlTypeRadio(replaceHmtlItemA(replaceHmtlFa(replaceInputRadio(itemQst[index].alternativaA)))))))))))))))))))),
                                        customTextAlign: (dom.Node node) {
                                        return TextAlign.left;
                                        },

                                  ),
                                ),
                              splashColor: Colors.blueAccent,
                                  onTap: () async {
                                    !questaoRespondida ? setState(() {
                                      if(selectedItemA){
                                        selectedItemA = false;
                                        selectedColorItemA = Theme.of(context).cardColor;
                                        itemIsSelected = false;
                                      }else{
                                        print('Item A Selecionado');
                                        selectedItemA = true;
                                        selectedItem = "1";
                                        selectedColorItemA = Colors.blue;
                                        itemIsSelected = true;
                                        
                                        //REMOVE SELECAO E COR DOS DEMAIS ITENS
                                        selectedItemB = false;
                                        selectedColorItemB = Theme.of(context).cardColor;
                                        selectedItemC = false;
                                        selectedColorItemC = Theme.of(context).cardColor;
                                        selectedItemD = false;
                                        selectedColorItemD = Theme.of(context).cardColor;
                                        selectedItemE = false;
                                        selectedColorItemE = Theme.of(context).cardColor;
                                      }
                                    }) : null;
                                },
                              ),
                            ),

                          _isLoading ? _isLoadingItems() : Card(
                            color: selectedColorItemB,
                            elevation: 0,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Html(
                                  data: replaceDivDiv(replaceSpaceFive(replaceSpaceFour(replacePSpan(replaceSpaceThree(replaceQuebra(replaceSpace(replaceHiddenPrintTwo(replaceHiddenPrint(replaceLinkImageSpan(replaceLinkImage(replaceHmtlLabelOut(replaceHmtlLabelIn(replaceHtmlSpanOut(replaceHtmlSpanIn(replaceHtmlTypeRadio(replaceHmtlItemB(replaceHmtlFa(replaceInputRadio(itemQst[index].alternativaB))))))))))))))))))),
                                  customTextAlign: (dom.Node node) {
                                    return TextAlign.left;
                                  },
                                ),
                              ),
                              splashColor: Colors.blueAccent,
                              onTap: () async {
                                !questaoRespondida ? setState(() {
                                      if(selectedItemB){
                                        selectedItemB = false;
                                        selectedColorItemB = Theme.of(context).cardColor;
                                        itemIsSelected = false;
                                      }else{
                                        print('Item B Selecionado');
                                        selectedItemB = true;
                                        selectedItem = "2";
                                        selectedColorItemB = Colors.blue;
                                        itemIsSelected = true;
                                        
                                        //REMOVE SELECAO E COR DOS DEMAIS ITENS
                                        selectedItemA = false;
                                        selectedColorItemA = Theme.of(context).cardColor;
                                        selectedItemC = false;
                                        selectedColorItemC = Theme.of(context).cardColor;
                                        selectedItemD = false;
                                        selectedColorItemD = Theme.of(context).cardColor;
                                        selectedItemE = false;
                                        selectedColorItemE = Theme.of(context).cardColor;
                                      }
                                    }) : null;
                              },
                            ),
                          ),

                          itemQst[index].alternativaC != "" ?
                          _isLoading ? _isLoadingItems() : Card(
                            color: selectedColorItemC,
                            elevation: 0,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Html(
                                  data: replaceDivDiv(replaceSpaceFive(replaceSpaceFour(replacePSpan(replaceSpaceThree(replaceQuebra(replaceSpace(replaceHiddenPrintTwo(replaceHiddenPrint(replaceLinkImageSpan(replaceLinkImage(replaceHmtlLabelOut(replaceHmtlLabelIn(replaceHtmlSpanOut(replaceHtmlSpanIn(replaceHtmlTypeRadio(replaceHmtlItemC(replaceHmtlFa(replaceInputRadio(itemQst[index].alternativaC))))))))))))))))))),
                                  customTextAlign: (dom.Node node) {
                                    return TextAlign.left;
                                  },
                                ),
                              ),
                              splashColor: Colors.blueAccent,
                              onTap: () async {
                                !questaoRespondida ? setState(() {
                                   if(selectedItemC){
                                        selectedItemC = false;
                                        selectedColorItemC = Theme.of(context).cardColor;
                                        itemIsSelected = false;
                                      }else{
                                        print('Item C Selecionado');
                                        selectedItemC = true;
                                        selectedItem = "3";
                                        selectedColorItemC = Colors.blue;
                                        itemIsSelected = true;
                                        
                                        //REMOVE SELECAO E COR DOS DEMAIS ITENS
                                        selectedItemB = false;
                                        selectedColorItemB = Theme.of(context).cardColor;
                                        selectedItemA = false;
                                        selectedColorItemA = Theme.of(context).cardColor;
                                        selectedItemD = false;
                                        selectedColorItemD = Theme.of(context).cardColor;
                                        selectedItemE = false;
                                        selectedColorItemE = Theme.of(context).cardColor;
                                      }
                                    }) : null;
                              },
                            ),
                          )
                    :Container(),
                          itemQst[index].alternativaD != "" ?
                         _isLoading ? _isLoadingItems() : Card(
                            color: selectedColorItemD,
                            elevation: 0,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Html(
                                 // defaultTextStyle: TextStyle(fontWeight: FontWeight.w900, color: questaoRespondida ? Colors.white:  Theme.of(context).textTheme.caption.color),
                                  data: replaceDivDiv(replaceSpaceFive(replaceSpaceFour(replacePSpan(replaceSpaceThree(replaceQuebra(replaceSpace(replaceHiddenPrintTwo(replaceHiddenPrint(replaceLinkImageSpan(replaceLinkImage(replaceHmtlLabelOut(replaceHmtlLabelIn(replaceHtmlSpanOut(replaceHtmlSpanIn(replaceHtmlTypeRadio(replaceHmtlItemD(replaceHmtlFa(replaceInputRadio(itemQst[index].alternativaD))))))))))))))))))),
                                  customTextAlign: (dom.Node node) {
                                    return TextAlign.left;
                                  },
                                ),
                              ),
                              splashColor: Colors.blueAccent,
                              onTap: () async {
                                !questaoRespondida ?  setState(() {
                                   if(selectedItemD){
                                        selectedItemD = false;
                                        selectedColorItemD = Theme.of(context).cardColor;
                                        itemIsSelected = false;
                                      }else{
                                        print('Item D Selecionado');
                                        selectedItemD = true;
                                        selectedItem = "4";
                                        selectedColorItemD = Colors.blue;
                                        itemIsSelected = true;
                                        
                                        //REMOVE SELECAO E COR DOS DEMAIS ITENS
                                        selectedItemB = false;
                                        selectedColorItemB = Theme.of(context).cardColor;
                                        selectedItemA = false;
                                        selectedColorItemA = Theme.of(context).cardColor;
                                        selectedItemC = false;
                                        selectedColorItemC = Theme.of(context).cardColor;
                                        selectedItemE = false;
                                        selectedColorItemE = Theme.of(context).cardColor;
                                      }
                                    }) : null;
                              },
                            ),
                          )
                    :Container(),
                          itemQst[index].alternativaE != "" ?
                          _isLoading ? _isLoadingItems() : Card(
                            color: selectedColorItemE,
                            elevation: 0,
                            child: InkWell(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Html(
                                  data: replaceDivDiv(replaceSpaceFive(replaceSpaceFour(replacePSpan(replaceSpaceThree(replaceQuebra(replaceSpace(replaceHiddenPrintTwo(replaceHiddenPrint(replaceLinkImageSpan(replaceLinkImage(replaceHmtlLabelOut(replaceHmtlLabelIn(replaceHtmlSpanOut(replaceHtmlSpanIn(replaceHtmlTypeRadio(replaceHmtlItemE(replaceHmtlFa(replaceInputRadio(itemQst[index].alternativaE))))))))))))))))))),
                                  customTextAlign: (dom.Node node) {
                                    return TextAlign.left;
                                  },
                                ),
                              ),
                              splashColor: Colors.blueAccent,
                              onTap: () async {
                                !questaoRespondida ?   setState(() {
                                      if(selectedItemE){
                                        selectedItemE = false;
                                        selectedColorItemE = Theme.of(context).cardColor;
                                        itemIsSelected = false;
                                      }else{
                                        print('Item E Selecionado');
                                        selectedItemE = true;
                                        selectedItem = "5";
                                        selectedColorItemE = Colors.blue;
                                        itemIsSelected = true;
                                        
                                        //REMOVE SELECAO E COR DOS DEMAIS ITENS
                                        selectedItemB = false;
                                        selectedColorItemB = Theme.of(context).cardColor;
                                        selectedItemC = false;
                                        selectedColorItemC = Theme.of(context).cardColor;
                                        selectedItemD = false;
                                        selectedColorItemD = Theme.of(context).cardColor;
                                        selectedItemA = false;
                                        selectedColorItemA = Theme.of(context).cardColor;
                                      }
                                    }): null;
                              },
                            ),
                          )
                           :Container(),
                          SizedBox(
                            height: 20,
                          ),

                          //_isLoading ? CircularProgressIndicator() : Container(),

                          SizedBox(
                            height: 20,
                          ),
                            !questaoRespondida ?
                            itemIsSelected ? _isLoadingResposta ? CircularProgressIndicator() : RaisedButton(
                              color: Colors.lightGreen,
                              onPressed: () async{
                                stopWatch();
                                _respostaQuestion(itemQst[index].resposta, selectedItem, itemQst[index].id);

                              },
                              child: Text('Responder'),
                            )
                            : nextPage != null ? RaisedButton(
                            onPressed: () {

                              setState(() {
                                //LIMPAR COR ITENS
                                selectedColorItemA = null;
                                selectedColorItemB = null;
                                selectedColorItemC = null;
                                selectedColorItemD = null;
                                selectedColorItemE = null;
                                questaoRespondida = false;
                                selectedItemA = false;
                                selectedItemB = false;
                                selectedItemC = false;
                                selectedItemD = false;
                                selectedItemE = false;
                                itemIsSelected = false;

                              });

                              print(index);
                              _getQuestions();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text('Próxima'),
                            ),
                          ):Container():
                          nextPage != null ? RaisedButton(
                              onPressed: () {
                                stopWatch();
                                setState(() {
                                  //LIMPAR COR ITENS
                                  selectedColorItemA = null;
                                  selectedColorItemB = null;
                                  selectedColorItemC = null;
                                  selectedColorItemD = null;
                                  selectedColorItemE = null;
                                  questaoRespondida = false;
                                  selectedItemA = false;
                                  selectedItemB = false;
                                  selectedItemC = false;
                                  selectedItemD = false;
                                  selectedItemE = false;
                                  itemIsSelected = false;

                                });

                                print(index);
                                _getQuestions();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text('Próxima'),
                              ),
                            ):Container(),

                          SizedBox(
                            height: 60,
                          ),

                        ],
                      ),
                    );
                  }

        );
              }
      ),
        bottomNavigationBar: _isLoading ? BottomAppBar() : BottomAppBar(
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              IconButton(onPressed: () {

              }, icon: Icon(FontAwesomeIcons.comment),),
              IconButton(onPressed: () {
                Navigator.of(context).push(
                    new MaterialPageRoute(
                        builder: (context) =>
                            QuestaoEstatisticaScreen(itemQst[0].id)));
              }, icon: Icon(FontAwesomeIcons.chartPie),),
              IconButton(onPressed: () {}, icon: Icon(FontAwesomeIcons.readme),),

            ],
          ),
        ),
      )
    );
  }



  //CARREGAMENTO CABEÇALHO
  Widget _loadingCabecalho(){
    return Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  child: Card(
                    elevation: 0,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(
                                       bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                       width: 65,
                                        height: 16,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only( bottom: 5.0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: SkeletonAnimation(
                                      child: Container(
                                        height: 15,
                                        width:
                                          MediaQuery.of(context).size.width * 0.5,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.grey[300]),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                       bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.7,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                       bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.7,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }

  Widget _loadingEnunciado(){
      return Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  child:  Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only( bottom: 5.0),
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 5.0),
                                    child: SkeletonAnimation(
                                      child: Container(
                                        height: 15,
                                        width:
                                          MediaQuery.of(context).size.width * 0.8,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10.0),
                                            color: Colors.grey[300]),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                       bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                       bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              );
  }

  Widget _isLoadingItems(){
    return Padding(
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  child: Card(
                    elevation: 0,
                    child: Container(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                
                                Padding(
                                  padding: const EdgeInsets.only(
                                       bottom: 5.0),
                                  child: SkeletonAnimation(
                                    child: Container(
                                      height: 15,
                                      width:
                                          MediaQuery.of(context).size.width * 0.7,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: Colors.grey[300]),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
  }

  _respostaQuestion(respostaQuestao, respostaUser, questaoId) async {

    _isLoadingResposta = true;

      if(respostaQuestao == "1" && respostaQuestao == respostaUser){
        itemResposta = true;
        print("Item A : ${itemResposta}");
        selectedColorItemA = colorAcerto;

      }
      else if(respostaQuestao == "2" && respostaQuestao == respostaUser){
        itemResposta = true;
        print("Item B : ${itemResposta}");
        selectedColorItemB = colorAcerto;

      }
      else if(respostaQuestao == "3" && respostaQuestao == respostaUser){
        itemResposta = true;
        print("Item C : ${itemResposta}");
        selectedColorItemC = colorAcerto;

      }
      else if(respostaQuestao == "4" && respostaQuestao == respostaUser){
        itemResposta = true;
        print("Item D : ${itemResposta}");
        selectedColorItemD = colorAcerto;

      }
      else if(respostaQuestao == "5" && respostaQuestao == respostaUser){
        itemResposta = true;
        print("Item E : ${respostaUser}");
        selectedColorItemE = colorAcerto;

      }else{
        itemResposta = false;
        print("Status ACerto/Erro : ${respostaQuestao}");

        if(respostaUser == "1"){
          selectedColorItemA = colorErro;
        }else if(respostaUser == "2"){
          selectedColorItemB = colorErro;
        }else if(respostaUser == "3"){
          selectedColorItemC = colorErro;
        }else if(respostaUser == "4"){
          selectedColorItemD = colorErro;
        }else{
          selectedColorItemE = colorErro;
        }

        if(respostaQuestao == "1"){
          selectedColorItemA = colorAcerto;
        }else if(respostaQuestao == "2"){
          selectedColorItemB = colorAcerto;
        }else if(respostaQuestao == "3"){
          selectedColorItemC = colorAcerto;
        }else if(respostaQuestao == "4"){
          selectedColorItemD = colorAcerto;
        }else{
          selectedColorItemE = colorAcerto;
        }
      }

      if(itemResposta == true){
        statusResposta = true;
        _snackResposta('Você acertou!', true);
      }else{
        statusResposta = false;
        _snackResposta('Você errou!', false);
      }

      await _sendAnswerAPI(
          questaoId: questaoId,
          respostaUser: selectedItem,
          userUID: UserUid,
          respostaEscolhida: statusResposta,
          tempoGasto: elapsedTime).then((result){

        setState(() {
          questaoRespondida = true;
          _isLoadingResposta = false;
        });

      });

}

  void _snackResposta(String textoResposta, bool Resposta) {
    _key.currentState.showSnackBar(SnackBar(
      backgroundColor: Resposta ? colorAcerto : colorErro,
        content: Text(textoResposta),
        duration: Duration(seconds: 3)));
  }

  void _getQuestions() async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
      });

      themeDefault = await AppSettings().getThemeDefault();

      if (questions == null) {
        nextPage = '${AppSettings.url}/api/questoes/?' +
            "assuntosId=${widget.assuntosId}&" +
            "orgaosId=${widget.orgaosId}&" +
            "bancasId=${widget.bancasId}&" +
            "cargosId=${widget.cargosId}&" +
            "anosId=${widget.anosId}&" +
            "certo_errado=${widget.certo_errado}&" +
            "acertei=${widget.acertei}&" +
            "errei=${widget.errei}&" +
            "resolvi=${widget.resolvi}&" +
            "naoResolvi=${widget.naoResolvi}&" +
            "aleatoria=${widget.aleatoria}&"
                "userUidApp=${UserUid}";
        print(nextPage);
      }

      final response = await dio.get(nextPage);

      if (response.data['next_page_url'] != null) {
        nextPage = response.data['next_page_url'] +
            "&" +
            "assuntosId=${widget.assuntosId}&" +
            "orgaosId=${widget.orgaosId}&" +
            "bancasId=${widget.bancasId}&" +
            "cargosId=${widget.cargosId}&" +
            "anosId=${widget.anosId}&" +
            "certo_errado=${widget.certo_errado}&" +
            "acertei=${widget.acertei}&" +
            "errei=${widget.errei}&" +
            "resolvi=${widget.resolvi}&" +
            "naoResolvi=${widget.naoResolvi}&" +
            "aleatoria=${widget.aleatoria}&"
                "userUidApp=${UserUid}";
        print("NETXPAGE: ${nextPage}");
      } else {
        nextPage = null;
      }

      questions = Questoes.fromJson(response.data);

      print(questions);

      totalPages = response.data['limit'];
      currentPage = response.data['current_page'];
      setState(() {
        itemQst = questions.data;
        _isLoading = false;
        firstLoading = false;

        // questions.addAll(tempList);
      });
      resetWatch();
      startWatch();
      //print("Item: ${itemQst[0].enunciado}");

    }
  }

  Future<void> _sendAnswerAPI( {questaoId, respostaUser, userUID, respostaEscolhida, tempoGasto}) async {

    dadosRespostaUser= {
      'questao_id' : questaoId,
      'resposta_user' : respostaEscolhida,
      'user_uid_app' : userUID,
      'resposta_escolhida' : respostaUser,
      'tempo_gasto' : tempoGasto
    };

    var response = await CallApi().postData(dadosRespostaUser, "questoes/responder");

    print("RETURN FROM API: ${response}");


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

    return "00:$minutesStr:$secondsStr";
  }


  updateTime(Timer timer) {
    if (watch.isRunning) {
      setState(() {
        elapsedTime = transformMilliSeconds(watch.elapsedMilliseconds);
      });
    }
  }

  /// FIM TIMER


  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceLinkImage(String htmlText) {
    RegExp exp = RegExp(r'src="/images/', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, 'src="${AppSettings.url}/images/'
        '');

  }

  String replaceLinkImageSpan(String htmlText) {

    RegExp exp = RegExp(r'<span>\n'
    r'    									   \n'
    r'    									   <p>', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceQuebra(String htmlText) {

    RegExp exp = RegExp(r'\n', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceSpace(String htmlText) {

    RegExp exp = RegExp(r'        ', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceSpaceTwo(String htmlText) {

    RegExp exp = RegExp(r'</span>						 ', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceSpaceThree(String htmlText) {

    RegExp exp = RegExp(r'													', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceSpaceFour(String htmlText) {

    RegExp exp = RegExp(r'							', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceSpaceFive(String htmlText) {

    RegExp exp = RegExp(r'   <p>', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceDivDiv(String htmlText) {

    RegExp exp = RegExp(r'<div<div  ', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '<div  ');
  }



  String replacePSpan(String htmlText) {

    RegExp exp = RegExp(r'</p></span>', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceSpanItem(String htmlText) {

    RegExp exp = RegExp(r'<span>    									   ', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }



  String replaceHiddenPrint(String htmlText) {

    RegExp exp = RegExp(r'                                            							<i class="on fa-li fa fa-circle hidden-print"/>', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceHiddenPrintTwo(String htmlText) {

    RegExp exp = RegExp(r'        							<i class="off fa-li fa fa-circle-thin hidden-print"/>', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceInputRadio(String htmlText){

    RegExp exp = RegExp(r'<input class="rdo"', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '<div ');
  }

  String replaceHmtlLabelIn(String htmlText){
    if(htmlText.contains('<label class="lbl">')){
      RegExp exp = RegExp(r'<label class="lbl">', multiLine: true, caseSensitive: true);

      return htmlText.replaceAll(exp, '');
    }else{
      return htmlText;
    }
  }

  String replaceHmtlLabelOut(String htmlText){
    if(htmlText.contains('</label>')){
      RegExp exp = RegExp(r'</label>', multiLine: true, caseSensitive: true);

      return htmlText.replaceAll(exp, '');
    }else{
      return htmlText;
    }
  }

  String replaceHmtlFa(String htmlText){
    if(htmlText.contains('<i class="fa fa-window-close fa-li descarta-questao"/>')){
      RegExp exp = RegExp(r'<i class="fa fa-window-close fa-li descarta-questao"/>', multiLine: true, caseSensitive: true);

      return htmlText.replaceAll(exp, '<div');
    }else{
      return htmlText;
    }


  }

  String replaceHmtlItemA(String htmlText){
    if(htmlText.contains('<b>a)</b>')){
      RegExp exp = RegExp(r"<b>a\)</b>", multiLine: true, caseSensitive: true);
      //return htmlText.replaceAll(exp, '');
      return htmlText;
    }else{
      return htmlText;
    }
  }

  String replaceHmtlItemB(String htmlText){
    if(htmlText.contains('<b>b)</b>')){
      RegExp exp = RegExp(r"<b>b\)</b>", multiLine: true, caseSensitive: true);
      //return htmlText.replaceAll(exp, '');
      return htmlText;
    }else{
      return htmlText;
    }
  }
  String replaceHmtlItemC(String htmlText){
    if(htmlText.contains('<b>c)</b>')){
      RegExp exp = RegExp(r"<b>c\)</b>", multiLine: true, caseSensitive: true);
      //return htmlText.replaceAll(exp, '');
      return htmlText;
    }else{
      return htmlText;
    }
  }
  String replaceHmtlItemD(String htmlText){
    if(htmlText.contains('<b>d)</b>')){
      RegExp exp = RegExp(r"<b>d\)</b>", multiLine: true, caseSensitive: true);
      //return htmlText.replaceAll(exp, '');
      return htmlText;
    }else{
      return htmlText;
    }
  }
  String replaceHmtlItemE(String htmlText){
    if(htmlText.contains('<b>e)</b>')){
      RegExp exp = RegExp(r"<b>e\)</b>", multiLine: true, caseSensitive: true);
      //return htmlText.replaceAll(exp, '');
      return htmlText;
    }else{
      return htmlText;
    }
  }

  String replaceHtmlSpanIn(String htmlText){

    RegExp exp = RegExp(r'<span>\n'
    r'    									   \n'
    r'    									    ', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '').trimRight();
  }

  String replaceHtmlSpanOut(String htmlText){

    RegExp exp = RegExp(r' \n'
    r'                                        </span>', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }

  String replaceHtmlTypeRadio(String htmlText){

    RegExp exp = RegExp(r'type="radio"', multiLine: true, caseSensitive: true);

    return htmlText.replaceAll(exp, '');
  }


}
