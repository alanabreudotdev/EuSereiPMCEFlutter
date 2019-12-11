import 'package:flutter/material.dart';
import '../../utils/appsettings.dart';
import 'concuros_categorias_screen.dart';
import '../../utils/cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widget/drawer.dart';
import '../login_screen.dart';
import 'package:scoped_model/scoped_model.dart';
import '../../model/user_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../widget/separator.dart';
import 'package:animated_card/animated_card.dart';
import 'dart:convert';

class ConcursosCategory extends StatefulWidget {
  @override
  _ConcursosCategoryState createState() => _ConcursosCategoryState();
}

class _ConcursosCategoryState extends State<ConcursosCategory> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey();
 // List _categories;
  List _categories;
  bool _isLoading = false;
  bool themeDefault;

  var dio = Dio();

  @override
  void initState() {
    setState(() {
      _isLoading = true;
      print('carregando');
    });
    // TODO: implement initState
    super.initState();
    _getDados();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffold,
      drawer: DrawerPage(),
      body: _isLoading
          ? Center(
              child: SizedBox(
              width: 100,
              height: 100,
              child: AppSettings().buildProgressIndicator(isLoading: _isLoading),
            ))
          : ScopedModelDescendant<UserModel>(builder: (context, child, model) {
              return Column(

                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical:8.0),
                    child: AppSettings().appBar(
                        context: context,
                        title: 'CONCURSOS',
                        hasMenu: true,
                        scaffoldkey: _scaffold.currentState,
                        icon: FontAwesomeIcons.bookReader,),

                  ),
                  Expanded(
                    child: ListView.builder(

                      itemCount: _categories.length,
                      itemBuilder: (context, index) {

                        return  _categories[index]['paid'] == 1
                            ? GestureDetector(
                            onTap: () => Navigator.of(context).push(
                              !model.isLoggedIn() ?
                              new PageRouteBuilder(
                                pageBuilder: (_, __, ___) => LoginScreen(),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                new FadeTransition(opacity: animation, child: child),
                              )
                                  :
                              new PageRouteBuilder(
                                pageBuilder: (_, __, ___) => ConcursosCategoriasScreen(
                                    _categories[index]['id']
                                        .toString(),
                                    _categories[index]
                                    ['title']
                                        .toString(),
                                  _categories[index]
                                  ['cargo']
                                      .toString(),
                                    "${AppSettings
                                        .url}media/various/${_categories[index]['thumbnail']}",
                                ),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) =>
                                new FadeTransition(opacity: animation, child: child),
                              ) ,
                            ),

                            child: AnimatedCard(
                                direction: AnimatedCardDirection.bottom, //Initial animation direction
                                initDelay: Duration(milliseconds: 0), //Delay to initial animation
                                duration: Duration(seconds: 1), //Initial animation duration
                                child:_cardCustom(
                          context: context,
                          image:"${AppSettings
                              .url}media/various/${_categories[index]['thumbnail']}",
                          title:  _categories[index]
                          ['title']
                              .toString(),
                          subtitle: _categories[index]['description'].toString(),
                          questoes: _categories[index]['question_count'].toString(),
                          cargo: _categories[index]['cargo'].toString(),
                          remuneracao: _categories[index]['remuneracao'].toString(),
                        )
                        ),) : Container();
                      },
                    ),
                  )
                ],
              );
            }),
    );
  }

  _cardCustom({BuildContext context, String image, String title, String subtitle,String cargo,String remuneracao, String questoes}) {
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
                margin: new EdgeInsets.fromLTRB(60.0, 16.0, 16.0, 16.0),
                constraints: new BoxConstraints.expand(),
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(height: 3.0),
                    new Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          //color: Colors.black,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w600),
                    ),
                    new Container(height: 2.0),
                    new Separator(),
                    new Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        //color: Colors.black45,
                          fontSize: 12.0,
                          fontWeight: FontWeight.w500),
                    ),
                    new Text(
                      "Cargo: $cargo",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        //color: Colors.black45,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w300),
                    ),
                    new Text(
                      "Remuneração: $remuneracao",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        //color: Colors.black45,
                          fontSize: 10.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
              ),
              height: 124.0,
              margin: new EdgeInsets.only(left: 46.0),
              decoration: new BoxDecoration(
                color: themeDefault ? Colors.black12:Colors.grey[200],
                shape: BoxShape.rectangle,
                borderRadius: new BorderRadius.circular(8.0),
                boxShadow: <BoxShadow>[
                  new BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.0),
                  ),
                ],
              ),
            ),


            Container(
              margin: new EdgeInsets.symmetric(vertical: 16.0),
              alignment: FractionalOffset.centerLeft,
              child: Hero(
                tag: title,
                child: ClipRRect(
                  child: CachedNetworkImage(
    placeholder: (context, url) => Container(
    child: CircularProgressIndicator(
    strokeWidth: 2.0,
    valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
    ),
    width: 45.0,
    height: 45.0,
    padding: EdgeInsets.all(0.0),
    ),
    imageUrl:  image,
    width: 92.0,
    height: 92.0,
    fit: BoxFit.contain,
    ),

                  borderRadius: BorderRadius.circular(10.0),
                ),
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
      await CallApi().getData('categories/4/premium').then((result) {
        print(result);
        setState(() {
          _categories = result;
          _isLoading = false;
        });
      });
    } catch (e) {
      AppdoAntigao().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'Aviso',
          message:
              'Erro ao carregar, verifique sua conexão com a internet e tente novamente!',
          buttonLabel: 'Fechar');
    }
  }

*/

  Map headers = <String, String>{
    'Content-type': 'application/json',
    'Accept': 'application/json',
  };
  _getDados() async {
    Future.delayed(Duration(seconds: 1)).then((_) async{
      themeDefault = await AppSettings().getThemeDefault();
      setState(() {
        _isLoading = true;
      });
      try {
        dio.options.baseUrl = "${AppSettings.url}api/";
        dio.options.headers = headers;
        dio.interceptors
          ..add(CacheInterceptor())
          ..add(LogInterceptor(requestHeader: false, responseHeader: false));

        await dio.get("editais",
            options: Options(extra: {'refresh': true})).then((result){
          print(result.data['edital']);
          if(result.data['success']){
            setState(() {
              _categories = result.data['edital'];
              _isLoading = false;
            });
          }else{
            AppSettings().showDialogSingleButtonWithRedirect(
                context: context,
                title: 'Aviso',
                message: result.data['message'],
                buttonLabel: 'Fechar');
            setState(() {
              _isLoading = true;
            });
          }
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
    });

  }
}
