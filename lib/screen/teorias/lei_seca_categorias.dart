import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:animated_card/animated_card.dart';

import '../lei_seca_screen.dart';

class LeiSecaCategorias extends StatefulWidget {


  @override
  _LeiSecaCategoriasState createState() => _LeiSecaCategoriasState();
}

class _LeiSecaCategoriasState extends State<LeiSecaCategorias> {

  GlobalKey<ScaffoldState> _scaffold = new GlobalKey();

  List _categories;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea(
      child: Scaffold(
          key: _scaffold,
          body: _isLoading
              ? Center(
            child: SizedBox(
                width: 100,
                height: 100,
                child: AppSettings().buildProgressIndicator(isLoading: _isLoading)))
              : ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[

                     _teoriaPM()

                  ],
                )

          /*SingleChildScrollView(
          child: Container(
            child: Column(
              children: <Widget>[
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => LeiSecaScreen('Código Disciplinar','CODIGO_compact.pdf')));
                  },
                  child: Card(
                    margin: EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        trailing: Icon(Icons.arrow_forward_ios),
                        title: Text("CÓDIGO DISCIPLINAR  - PM/BMCE".toUpperCase(), style: TextStyle(fontSize: 13),),
                        subtitle: Text("LEI Nº 13.407, DE 21.11.03(DOE 02.12.03)" , style: TextStyle(fontSize: 10),),
                      ),
                    ),

                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => LeiSecaScreen('ESTATUTO DOS MILITARES ESTADUAIS', 'ESTATUTO_compact.pdf')));
                  },
                  child: Card(
                    margin: EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        trailing: Icon(Icons.arrow_forward_ios),
                        title: Text("ESTATUTO DOS MILITARES ESTADUAIS DO CEARÁ  - PM/BMCE", style: TextStyle(fontSize: 13),),
                        subtitle: Text("LEI Nº 13.729, DE 11 DE JANEIRO DE 2006.", style: TextStyle(fontSize: 10),),
                      ),
                    ),

                  ),
                ),
                InkWell(
                  onTap: (){
                    Navigator.of(context).push(new MaterialPageRoute(
                        builder: (context) => LeiSecaScreen('LEI DA CONTROLADORIA', 'CGD_compact.pdf')));
                  },
                  child: Card(
                    margin: EdgeInsets.only(top: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: ListTile(
                        trailing: Icon(Icons.arrow_forward_ios),
                        title: Text("LEI DA CONTROLADORIA  - PM/BMCE", style: TextStyle(fontSize: 13),),
                        subtitle: Text("LEI COMPLEMENTAR No 98", style: TextStyle(fontSize: 10),),
                      ),
                    ),

                  ),
                ),

              ],
            ),
          ),
        )*/
          ),
    );
  }

  _teoriaPM(){
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          AppSettings().appBar(
              context: context,
              title: 'TEORIA',
              hasMenu: true,
              hasBack: false,
              scaffoldkey: _scaffold.currentState,
              icon: FontAwesomeIcons.bookReader),


          _cardItens(context,'CÓDIGO DISCIPLINAR','LEI Nº 13.407, DE 21.11.03(DOE 02.12.03)','CODIGO_compact.pdf' ),
          _cardItens(context,'ESTATUTO DOS MILITARES ESTADUAIS','LEI Nº 13.729, DE 11 DE JANEIRO DE 2006.','ESTATUTO_compact.pdf' ),
          _cardItens(context,'LEI DA CONTROLADORIA','LEI COMPLEMENTAR No 98','CGD_compact.pdf' ),
          _cardItens(context,'CF88 / Art. 5º','DOS DIREITOS E DEVERES INDIVIDUAIS E COLETIVOS','CF88Art5_compact.pdf' ),
          _cardItens(context,'CF88 / Art. 144º','DA SEGURANÇA PÚBLICA','CF88Art144_compact.pdf' ),

        ],
      )
    );
  }

  _teoriaPC(){
    return Padding(
        padding: const EdgeInsets.all(0.0),
        child: Column(
          children: <Widget>[
            AppSettings().appBar(
                context: context,
                title: 'TEORIA',
                hasMenu: true,
                hasBack: false,
                scaffoldkey: _scaffold.currentState,
                icon: FontAwesomeIcons.bookReader),


            _cardItens(context,'ESTATUTO DA POLÍCIA CIVIL','Lei nº 12.124/93','PCEPCLei12.124_93App.pdf' ),
            _cardItens(context,'LEI No 15.990/16','','PCLEIN15.990App_compact.pdf' ),
            _cardItens(context,'LEI No 16.004/16','GRATIFICAÇÃO DE REFORÇO OPERACIONAL','PCLEI16004App_compact.pdf' ),


          ],
        )
    );
  }

  _cardItens(BuildContext context, String titleLei, String subtitleLei, String nameFileLei){
    return AnimatedCard(
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
                            child: Text(titleLei
                                .toString(),
                              overflow: TextOverflow.fade,
                              softWrap: true,
                              style: TextStyle(fontWeight: FontWeight.w700,),
                            ),),
                          SizedBox(
                            child: Text(subtitleLei,
                                style: TextStyle(
                                  //color: Colors.black,

                                    fontSize: 10.0)),
                            width: 200,
                          )
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

                     Navigator.of(context).push(
                    new PageRouteBuilder(
                      pageBuilder: (_, __, ___) => LeiSecaScreen(
                          titleLei, nameFileLei),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                      new FadeTransition(opacity: animation, child: child),
                    ));

              }
          ),
        )
    );
  }

}
