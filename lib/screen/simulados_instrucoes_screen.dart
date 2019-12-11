
import 'package:flutter/material.dart';
import 'simulados_questions_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../utils/appsettings.dart';

class SimuladoInstrucoes extends StatefulWidget {

  final simuladoId;
  final simuladoTitle;

  SimuladoInstrucoes(this.simuladoId, this.simuladoTitle);


  @override
  _SimuladoInstrucoesState createState() => _SimuladoInstrucoesState();
}

class _SimuladoInstrucoesState extends State<SimuladoInstrucoes> {

  SharedPreferences prefs;
  var userDados;
  bool _isLoading = false;


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
    return Scaffold(
      body: _isLoading ? Center(child: CircularProgressIndicator(),):Stack(
        children: <Widget>[
          Container(
              alignment: Alignment.center,
              child: Image.asset('assets/images/fundo_simulado.jpg')
          ),
          Column(
            children: <Widget>[
              SizedBox(height: 5.0),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                      boxShadow: [
                        BoxShadow(color: Colors.black38, offset: Offset(5.0, 5.0), blurRadius: 5.0)
                      ]
                  ),
                  margin: EdgeInsets.all(30.0),
                  child: Column(
                    children: <Widget>[
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Container(
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage("assets/images/moral_caricatura.png"),

                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  topRight: Radius.circular(10.0),
                                )
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5.0),
                      Text(widget.simuladoTitle.toString(), style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 20.0,
                        fontWeight: FontWeight.w500

                      ),),
                      SizedBox(height: 5.0),
                      Text("Instruções", style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 15.0,

                      ),),
                      SizedBox(height: 5.0),
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text("1. Resolva o simulado sem consultas. \n\n 2. O ranking só será contabilizado na primeira vez que você resolver o simulado. Nas demais vezes não contabilizará no ranking. \n\n 3. Se você sair antes de finalizar, as questões já resolvidas não serão salvas. \n\n 4. Pontuação: para cada resposta correta será de 1,0 ponto e para cada resposta errada será subtraído 0,5. \n\n Bom Simulado!", textAlign: TextAlign.justify, style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 12.0
                        ),softWrap: true),
                      ),
                      SizedBox(height: 10.0),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 80.0),
                width: double.infinity,
                child: RaisedButton(
                  padding: const EdgeInsets.all(16.0),
                  textColor: Colors.white,
                  color: Colors.lightGreen,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0)
                  ),
                  onPressed: (){
                    Navigator.of(context).push(
                        new MaterialPageRoute(
                            builder: (context)
                            // => SimuladosQuestionScreen(_categories[index]['id'].toString(), _categories[index]['title'].toString(),0)))
                            =>
                                SimuladosQuestionScreen(
                                    widget.simuladoId.toString(),
                                    widget.simuladoTitle.toString())
                        )
                    );
                  },
                  child: Text("Começar", style: TextStyle(
                      fontWeight: FontWeight.w300,
                      fontSize: 18.0
                  ),),
                ),
              ),
              SizedBox(height: 40.0),
            ],
          ),

        ],
      ),
    );
  }

_getUserPrefs() async{
  prefs = await SharedPreferences.getInstance();
  setState(() {
    userDados = jsonDecode(prefs.getString('userDados'));
    print("USERDADOS:$userDados");

    if(userDados['name']==null || userDados['name'] == "null" || userDados['photoUrl']==null || userDados['photoUrl'] == "null"){
      AppSettings().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'Aviso',
          message: 'Para resolver o simulado você precisa atualizar o seu perfil. \nAcesse Perfil, depois clique no lapis ao lado do nome.',
          buttonLabel: 'Voltar');
    }else{
      setState(() {
        _isLoading = false;
      });
    }



  });
}
}