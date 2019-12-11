import 'package:flutter/material.dart';
import '../model/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'simulado_gabarito_screen.dart';
import '../utils/appsettings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../utils/api.dart';
import 'home_screen.dart';
import 'simulados_ranking_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_card/animated_card.dart';


class SimuladoResultadoScreen extends StatefulWidget {
  @override

  final simuladoCategoryId;
  final simuladoName;
  SimuladoResultadoScreen(this.simuladoCategoryId, this.simuladoName);

  _SimuladoResultadoScreenState createState() => _SimuladoResultadoScreenState();
}

class _SimuladoResultadoScreenState extends State<SimuladoResultadoScreen> {
  GlobalKey<ScaffoldState> _scaffold = GlobalKey();

  var userDados;
  var resultado;
  var pontuacao;
  bool _isLoading = false;

  SimuladoResposta simRsp = SimuladoResposta();
  SimuladoHelper helper = SimuladoHelper();

  SharedPreferences prefs;

  @override
  void initState() {
    setState(() {
      _isLoading = true;
    });
    // TODO: implement initState
    super.initState();
    _getUserPrefs();
  }

  @override
  Widget build(BuildContext context){
    int correct = 0;
    //this.answers.forEach((index,value){
    //if(this.questions[index].correctAnswer == value)
    // correct++;
    //});
    final TextStyle titleStyle = TextStyle(
        fontSize: 16.0,
        fontWeight: FontWeight.w500
    );
    final TextStyle trailingStyle = TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.bold
    );

    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        body: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Colors.grey[400],Colors.grey[700]
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
              )
          ),
          child: _isLoading ? Center(child: CircularProgressIndicator(),)
              :SingleChildScrollView(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[

                AppSettings().appBar(
                    context: context,
                    title: widget.simuladoName,
                    hasMenu: false,
                    hasBack: false,
                    scaffoldkey: _scaffold.currentState,
                    icon: FontAwesomeIcons.star),

            AnimatedCard(
              direction: AnimatedCardDirection.top,
              curve: Curves.bounceOut,//Initial animation direction
              initDelay: Duration(milliseconds: 500), //Delay to initial animation
              duration: Duration(milliseconds:1100), //Initial animation duration
              child: AppSettings().buildTile(
                  Padding
                    (
                    padding: const EdgeInsets.all(24.0),
                    child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>
                        [
                          Column
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Text('Pontuação', style: TextStyle(color: Colors.blue)),
                              Text(pontuacao.toString(), style: TextStyle( fontWeight: FontWeight.w700, fontSize: 34.0))
                            ],
                          ),
                          Material
                            (
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(24.0),
                              child: Center
                                (
                                  child: Padding
                                    (
                                    padding: const EdgeInsets.only(bottom:16.0, top: 15, left: 15, right: 15),
                                    child: Icon(Icons.timeline, color: Colors.white, size: 30.0),
                                  )
                              )
                          )
                        ]
                    ),
                  ),
                ),
            ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    AnimatedCard(
                      direction: AnimatedCardDirection.left,
                      curve: Curves.bounceOut,//Initial animation direction
                      initDelay: Duration(milliseconds: 500), //Delay to initial animation
                      duration: Duration(milliseconds:1200), //Initial animation duration
                      child: AppSettings().buildTile(
                      Padding
                        (
                        padding: const EdgeInsets.all(24.0),
                        child: Column
                          (
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Material
                                (
                                  color: Colors.amber,
                                  shape: CircleBorder(),
                                  child: Padding
                                    (
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(Icons.edit, color: Colors.white, size: 30.0),
                                  )
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10.0)),
                              Text('${resultado['Total']}', style: TextStyle( fontWeight: FontWeight.w700, fontSize: 24.0)),
                              Text('Questões'),
                            ]
                        ),
                      ),
                    ),
                ),
                    AnimatedCard(
                      direction: AnimatedCardDirection.left,
                      curve: Curves.bounceOut,//Initial animation direction
                      initDelay: Duration(milliseconds: 500), //Delay to initial animation
                      duration: Duration(milliseconds:1300 ), //Initial animation duration
                      child: AppSettings().buildTile(
                      Padding
                        (
                        padding: const EdgeInsets.all(24.0),
                        child: Column
                          (
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Material
                                (
                                  color: Colors.green,
                                  shape: CircleBorder(),
                                  child: Padding
                                    (
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(Icons.check, color: Colors.white, size: 30.0),
                                  )
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10.0)),
                              Text("${resultado['Acertos']}", style: TextStyle( fontWeight: FontWeight.w700, fontSize: 24.0)),
                              Text('Acertos '),
                            ]
                        ),
                      ),
                    ),
                    ),
                    AnimatedCard(
                      direction: AnimatedCardDirection.right,
                      curve: Curves.bounceOut,//Initial animation direction
                      initDelay: Duration(milliseconds: 500), //Delay to initial animation
                      duration: Duration(milliseconds:1400), //Initial animation duration
                      child: AppSettings().buildTile(
                      Padding
                        (
                        padding: const EdgeInsets.all(24.0),
                        child: Column
                          (
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Material
                                (
                                  color: Colors.red,
                                  shape: CircleBorder(),
                                  child: Padding
                                    (
                                    padding: EdgeInsets.all(10.0),
                                    child: Icon(Icons.close, color: Colors.white, size: 30.0),
                                  )
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10.0)),
                              Text("${resultado['Erros']}", style: TextStyle( fontWeight: FontWeight.w700, fontSize: 24.0)),
                              Text('Erros'),
                            ]
                        ),
                      ),
                    )
                    )
                  ],
                ),
                SizedBox(height: 10,),
            AnimatedCard(
              direction: AnimatedCardDirection.right,
              curve: Curves.bounceOut,//Initial animation direction
              initDelay: Duration(milliseconds: 500), //Delay to initial animation
              duration: Duration(milliseconds:1500), //Initial animation duration
              child: AppSettings().buildTile(
                  Padding
                    (
                    padding: const EdgeInsets.all(24.0),
                    child: Row
                      (
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>
                        [
                          Column
                            (
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Text('Acertos', style: TextStyle(color: Colors.green)),
                              Text("${resultado['percAcertos'].toStringAsFixed(0)}%", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 34.0))
                            ],
                          ),
                          Material
                            (
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(24.0),
                              child: Center
                                (
                                  child: Padding
                                    (
                                    padding: const EdgeInsets.only(bottom:16.0, top: 15, left: 15, right: 15),
                                    child: Icon(FontAwesomeIcons.percent, color: Colors.white, size: 30.0),
                                  )
                              )
                          )
                        ]
                    ),
                  ),
                ),
            ),
                SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    AnimatedCard(
                      direction: AnimatedCardDirection.left,
                      curve: Curves.bounceOut,//Initial animation direction
                      initDelay: Duration(milliseconds: 500), //Delay to initial animation
                      duration: Duration(milliseconds:1500), //Initial animation duration
                      child: AppSettings().buildTile(
                      Padding
                        (
                        padding: const EdgeInsets.all(24.0),
                        child: Column
                          (
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Material
                                (
                                  color: Colors.deepPurple,
                                  shape: CircleBorder(),
                                  child: Padding
                                    (
                                    padding: const EdgeInsets.only(bottom:19.0, top: 15, left: 15, right: 15),
                                    child: Icon(FontAwesomeIcons.stopwatch, color: Colors.white, size: 30.0),
                                  )
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10.0)),
                              Text('${resultado['tempoGasto'].toString()}', style: TextStyle( fontWeight: FontWeight.w700, fontSize: 20.0)),
                              Text('Tempo total'),
                            ]
                        ),
                      ),
                    ),
                ),
                    Expanded(child: SizedBox()),
                    AnimatedCard(
                      direction: AnimatedCardDirection.right,
                      curve: Curves.bounceOut,//Initial animation direction
                      initDelay: Duration(milliseconds: 500), //Delay to initial animation
                      duration: Duration(milliseconds:1600), //Initial animation duration
                      child: AppSettings().buildTile(
                      Padding
                        (
                        padding: const EdgeInsets.all(24.0),
                        child: Column
                          (
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>
                            [
                              Material
                                (
                                  color: Colors.red,
                                  shape: CircleBorder(),
                                  child: Padding
                                    (
                                    padding: const EdgeInsets.only(bottom:19.0, top: 15, left: 15, right: 15),
                                    child: Icon(FontAwesomeIcons.clock, color: Colors.white, size: 30.0),
                                  )
                              ),
                              Padding(padding: EdgeInsets.only(bottom: 10.0)),
                              Text('${resultado['tempoMedio'].toString()}', style: TextStyle( fontWeight: FontWeight.w700, fontSize: 20.0)),
                              Text('Média/questão'),
                            ]
                        ),
                      ),
                    ),
                    )
                  ],
                ),



                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    RaisedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      //color: Colors.redAccent.withOpacity(0.8),
                      //textColor: Colors.white,
                      child: Text("Inicio"),
                      onPressed: () => Navigator.of(context).push(new MaterialPageRoute(
                          builder: (context) => HomeScreen())),
                    ),
                    RaisedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      //color: Colors.cyan[800],
                      //textColor: Colors.white,
                      child: Text("Gabarito"),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SimuladoGabaritoScreen(widget.simuladoCategoryId)
                        ));
                      },
                    ),
                    RaisedButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                     // color: Colors.amber.withOpacity(0.8),
                     // textColor: Colors.white,
                      child: Text("Ranking"),
                      onPressed: (){
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => SimuladosRankingScreen(widget.simuladoName, widget.simuladoCategoryId)
                        ));
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _getUserPrefs() async{
    prefs = await SharedPreferences.getInstance();
    setState(()  {
      userDados = jsonDecode(prefs.getString('userDados'));
      setState(() {
        userDados != null ? _getDadosSimulado(userDados['UID'], widget.simuladoCategoryId): null;
      });

    });
  }

  _getDadosSimulado(userId, SimuladoId) async {
    helper.getQuestionsBySimulado(userId: userId, simuladoId: SimuladoId).then((result){
      setState(() {
        resultado = result;
        pontuacao = resultado['Acertos']-(resultado['Erros']/2);
        print(pontuacao);
        if(resultado['Total'] == null){
          AppSettings().showDialogSingleButtonWithRedirect(
              context: context,
              title: 'Ops!',
              message: "Você ainda não resolveu esse simulado. Resolva para ter acesso as estatísticas.",
              buttonLabel: 'Sair');
        }else{

          _updateRanking();
          _isLoading = false;
        }



      });

    });
  }

  _updateRanking() async {
    var userRanking = {
      'simulado_id' : resultado['simuladoId'],
      'user_id'     : userDados['UID'],
      'name'        : (userDados['name'] == null || userDados['name'] == 'null' || userDados['name'] == 'NULL') ? 'Usuário' : userDados['name'],
      'photo_url'   : (userDados['photoUrl'] == null || userDados['photoUrl'] == "null" || userDados['photoUrl'] == "NULL") ? 'http://www.appdoantigao.com.br/uploads/user_default.png' : userDados['photoUrl'],
      'acertos'     : resultado['Acertos'],
      'erros'       : resultado['Erros'],
      'pontuacao'   : resultado['Acertos']-(resultado['Erros']/2)
    };

    var response =   await CallApi().postData(userRanking, 'ranking/save');


    print("RESPONSE: ${response['success']}");
  }
}