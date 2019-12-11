import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../utils/appsettings.dart';
import 'questoes_screen.dart';
import '../../utils/cache_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:expandable/expandable.dart';
import '../../utils/api.dart';

class QuestionsFiltrosScreen extends StatefulWidget {
  @override
  _QuestionsFiltrosScreenState createState() => _QuestionsFiltrosScreenState();
}

class _QuestionsFiltrosScreenState extends State<QuestionsFiltrosScreen> {
  GlobalKey<ScaffoldState> _scaffold = new GlobalKey();
  List<PopularFilterListData> filtrosListData =
      PopularFilterListData.filtrosList;

  var controller = ExpandableController(initialExpanded: false);

  List _categories;
  List _bancas;
  List _orgaos;
  List _cargos;
  List _anos;
  List _disciplinas;

  bool _isLoading = false;
  bool _isLoadingAssunto = false;
  bool _isLoadingTotalQuestoes = false;
  bool themeDefault;

  List _myAssuntos;
  List _myBancas;
  List _myOrgaos;
  List _myCargos;
  List _myAnos;


  final formKey = new GlobalKey<FormState>();

  var dio = Dio();

  var acertei = 0;
  var errei = 0;
  var resolvi = 0;
  var naoResolvi = 0;
  var todas = 0;
  var aleatoria = 0;
  var certoErrado = 0;
  var dadosFiltro;
  var totalQuestoes = 603652;

  var filtrarIds;

  List initialAssuntoData = [
    {'nome': 'Nenhum disciplina foi selecionada.', 'id': '4'}
  ];

  @override
  void initState() {
    _myAssuntos = [];

    // TODO: implement initState
    super.initState();
    _getDadosJson();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  _saveForm() {
    var form = formKey.currentState;
    if (form.validate()) {
      form.save();
      Navigator.of(context).push(new PageRouteBuilder(
        pageBuilder: (_, __, ___) => QuestionScreen(
            _myAssuntos,
            _myOrgaos,
            _myBancas,
            _myCargos,
            _myAnos,
            certoErrado,
            acertei,
            errei,
            resolvi,
            naoResolvi,
            aleatoria
            ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            new FadeTransition(opacity: animation, child: child),
      ));

    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffold,
        body: _isLoading
            ? Center(
                child:
                    AppSettings().buildProgressIndicator(isLoading: _isLoading))
            : Column(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: AppSettings().appBar(
                            context: context,
                            title: 'Questões',
                            hasMenu: true,
                            hasBack: false,
                            scaffoldkey: _scaffold.currentState,
                            icon: FontAwesomeIcons.edit),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                    AppSettings().buildTile(
                                      Column(children: <Widget>[
                                        _isLoadingTotalQuestoes ?
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: <Widget>[
                                            CircularProgressIndicator(),
                                            SizedBox(height: 10,),
                                            Text("filtrando...")
                                          ],
                                        ):
                                        Text("Total de questões encontradas: $totalQuestoes", style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12),),
                                        /*
                                     * DISCIPLINAS
                                     *
                                     * */
                                        Container(
                                          padding: EdgeInsets.all(16),
                                          child: MultiSelect(
                                              hintText: 'Toque para selecionar',
                                              autovalidate: false,
                                              titleText: 'DISCIPLINA',
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Selecione uma ou mais opções';
                                                }
                                              },
                                              errorText:
                                              'Selecione uma ou mais opções',
                                              dataSource: _disciplinas,
                                              textField: 'nome',
                                              valueField: 'id',
                                              filterable: true,
                                              required: true,
                                              value: null,
                                              change: (value) async {
                                                _getAssuntos(value);
                                                print(value);
                                              },
                                              onSaved: (value) {
                                                if (value == null) return;
                                              }),
                                        ),

                                        /*
                                    ASSUNTOS
                                     */
                                        _isLoadingAssunto
                                            ?
                                        Column(
                                          children: <Widget>[
                                            Center(child: CircularProgressIndicator()),
                                            SizedBox(height: 10,),
                                            Text('carregando assuntos'),
                                            SizedBox(height: 10,)
                                          ],
                                        )
                                            : Container(
                                          padding: EdgeInsets.all(16),
                                          child: MultiSelect(
                                              hintText: 'Toque para selecionar',
                                              autovalidate: false,
                                              titleText: 'ASSUNTOS',
                                              validator: (value) {
                                                if (value == null) {
                                                  return 'Selecione uma ou mais opções';
                                                }
                                              },

                                              errorText:
                                              'Selecione uma ou mais opções',
                                              dataSource: _categories == null
                                                  ? initialAssuntoData
                                                  : _categories,
                                              textField: 'nome',
                                              valueField: 'id',
                                              filterable: true,
                                              required: true,
                                              value: _myAssuntos,
                                              change: (value) async {
                                                setState(() {
                                                  _myAssuntos = value;

                                                });
                                                _getTotalQuestions();
                                                print(value);
                                              },
                                              onSaved: (value) {
                                                if (value == null) return;
                                                setState(() {
                                                  _myAssuntos = value;
                                                });
                                              }),
                                        ),
                                      ],)
                                    ),

                                  SizedBox(height: 10,),
                                  Padding(
                                    padding: EdgeInsets.all(0),
                                    child: AppSettings().buildTile(
                                      ExpandablePanel(
                                        controller: controller,
                                        tapBodyToCollapse: true,
                                        header: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            'mais filtros'.toUpperCase(),
                                          ),
                                        ),
                                        collapsed: Container(),
                                        expanded: Column(
                                          children: <Widget>[
                                            /*
                                    BANCAS
                                     */
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              child: MultiSelect(
                                                  hintText:
                                                      'Toque para selecionar',
                                                  autovalidate: false,
                                                  titleText: 'BANCA',

                                                  errorText:
                                                      'Selecione uma ou mais opções',
                                                  dataSource: _bancas == null
                                                      ? initialAssuntoData
                                                      : _bancas,
                                                  textField: 'nome',
                                                  valueField: 'id',
                                                  filterable: true,
                                                  required: false,
                                                  value: _myBancas,
                                                  change: (value) async {
                                                    setState(() {
                                                      _myBancas = value;

                                                    });
                                                    _getTotalQuestions();
                                                    print(value);
                                                  },
                                                  onSaved: (value) {
                                                    if (value == null) return;
                                                    setState(() {
                                                      _myBancas = value;
                                                    });
                                                  }),
                                            ),

                                            /*
                                            ORGAOS
                                            */
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              child: MultiSelect(
                                                  hintText:
                                                      'Toque para selecionar',
                                                  autovalidate: false,
                                                  titleText: 'ORGÃO',

                                                  errorText:
                                                      'Selecione uma ou mais opções',
                                                  dataSource: _orgaos == null
                                                      ? initialAssuntoData
                                                      : _orgaos,
                                                  textField: 'nome',
                                                  valueField: 'id',
                                                  filterable: true,
                                                  required: false,
                                                  value: _myOrgaos,
                                                  change: (value) async {
                                                    setState(() {
                                                      _myOrgaos = value;

                                                    });
                                                    _getTotalQuestions();
                                                    print(value);
                                                  },
                                                  onSaved: (value) {
                                                    if (value == null) return;
                                                    setState(() {
                                                      _myOrgaos = value;
                                                    });
                                                  }),
                                            ),

                                            /*
                                            CARGOS
                                            */
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              child: MultiSelect(
                                                  hintText:
                                                  'Toque para selecionar',
                                                  autovalidate: false,
                                                  titleText: 'CARGOS',

                                                  errorText:
                                                  'Selecione uma ou mais opções',
                                                  dataSource: _cargos == null
                                                      ? initialAssuntoData
                                                      : _cargos,
                                                  textField: 'nome',
                                                  valueField: 'id',
                                                  filterable: true,
                                                  required: false,
                                                  value: _myCargos,
                                                  change: (value) async {
                                                    setState(() {
                                                      _myCargos = value;

                                                    });
                                                    _getTotalQuestions();
                                                    print(value);
                                                  },
                                                  onSaved: (value) {
                                                    if (value == null) return;
                                                    setState(() {
                                                      _myCargos = value;
                                                    });
                                                  }),
                                            ),

                                            /*
                                            ANO
                                            */
                                            Container(
                                              padding: EdgeInsets.all(16),
                                              child: MultiSelect(
                                                  hintText:
                                                  'Toque para selecionar',
                                                  autovalidate: false,
                                                  titleText: 'ANO',

                                                  errorText:
                                                  'Selecione uma ou mais opções',
                                                  dataSource: _anos == null
                                                      ? initialAssuntoData
                                                      : _anos,
                                                  textField: 'ano',
                                                  valueField: 'id',
                                                  filterable: true,
                                                  required: false,
                                                  value: _myAnos,
                                                  change: (value) async {
                                                    setState(() {
                                                      _myAnos = value;

                                                    });
                                                    _getTotalQuestions();
                                                    print(value);
                                                  },
                                                  onSaved: (value) {
                                                    if (value == null) return;
                                                    setState(() {
                                                      _myAnos = value;
                                                    });
                                                  }),
                                            ),
                                            Divider(),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 16, left: 16),
                                              child: Column(
                                                children:
                                                    getAccomodationListUI(),
                                              ),
                                            ),
                                          ],
                                        ),
                                        tapHeaderToExpand: true,
                                        hasIcon: true,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          RaisedButton(
                            onPressed: _saveForm,
                            child: Text('Filtrar'),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  List<Widget> getAccomodationListUI() {
    List<Widget> noList = List<Widget>();
    for (var i = 0; i < filtrosListData.length; i++) {
      final date = filtrosListData[i];
      noList.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
            onTap: () {
              setState(() {
                checkAppPosition(i);
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      date.titleTxt,
                    ),
                  ),
                  CupertinoSwitch(
                    activeColor: date.isSelected
                        ? Colors.green
                        : Colors.grey.withOpacity(0.6),
                    onChanged: (value) {
                      setState(() {
                        checkAppPosition(i);
                        print(value);
                      });
                    },
                    value: date.isSelected,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return noList;
  }


  void checkAppPosition(int index) {
    filtrosListData[index].isSelected = !filtrosListData[index].isSelected;

    var count = 0;
    for (var i = 0; i < filtrosListData.length; i++) {
      var data = filtrosListData[i];
      if (data.isSelected) {
        count += 1;


        if (data.titleTxt == 'Apenas as que acertei') {
          setState(() {
            acertei = 1;

          });
        }
        if (data.titleTxt == 'Apenas as que errei') {
          errei = 1;
        }
        if (data.titleTxt == 'Apenas as que eu resolvi') {
          resolvi = 1;
        }
        if (data.titleTxt == 'Apenas as que eu não resolvi') {
          naoResolvi = 1;
        }
        if (data.titleTxt == 'Aleatórias') {
          aleatoria = 1;
        }
        if (data.titleTxt == 'Apenas as Certo/Errado') {

          setState(() {
            certoErrado = 1;
          });

        }

      } else {


        if (data.titleTxt == 'Apenas as que acertei') {
          acertei = 0;
        }
        if (data.titleTxt == 'Apenas as que errei') {
          errei = 0;
        }
        if (data.titleTxt == 'Apenas as que eu resolvi') {
          resolvi = 0;
        }
        if (data.titleTxt == 'Apenas as que eu não resolvi') {
          naoResolvi = 0;
        }
        if (data.titleTxt == 'Aleatórias') {
          aleatoria = 0;
        }
        if (data.titleTxt == 'Apenas as Certo/Errado') {
          certoErrado = 0;
        }
      }
    }

    _getTotalQuestions();
  }

  _getDadosJson() async {
    setState(() {
      _isLoading = true;
    });

    //return bancas
    String dataDisciplinas = await DefaultAssetBundle.of(context)
        .loadString("assets/json/disciplinas.json");
    _disciplinas = json.decode(dataDisciplinas);
    //return bancas

    String dataBancas = await DefaultAssetBundle.of(context)
        .loadString("assets/json/bancas.json");
    _bancas = json.decode(dataBancas);

    //return orgaos
    String dataOrgaos = await DefaultAssetBundle.of(context)
        .loadString("assets/json/orgaos.json");
    _orgaos = json.decode(dataOrgaos);

    //return orgaos
    String dataCargos = await DefaultAssetBundle.of(context)
        .loadString("assets/json/cargos.json");
    _cargos = json.decode(dataCargos);

    //return orgaos
    String dataAnos = await DefaultAssetBundle.of(context)
        .loadString("assets/json/anos.json");
    _anos = json.decode(dataAnos);

    setState(() {
      _isLoading = false;
    });
  }

  _getAssuntos(List value) async {

    setState(() {
      _isLoadingAssunto = true;
    });
    themeDefault = await AppSettings().getThemeDefault();

    try {
      dio.options.baseUrl = "${AppSettings.url}api/";
      dio.options.connectTimeout = 10000; //5s
      dio.options.receiveTimeout = 10000;
      dio.interceptors
        ..add(CacheInterceptor())
        ..add(LogInterceptor(requestHeader: false, responseHeader: false));

      var response = await dio.get(
          "questoes/disciplina/$value/assuntos",
          options: Options(extra: {'refresh': true}));
      setState(() {
        _categories = response.data;
        _isLoadingAssunto = false;
      });
    } catch (e) {
      AppSettings().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'Aviso',
          message: 'Erro ao carregar, tente novamentee!',
          buttonLabel: 'Fechar');
    }
  }

  _getTotalQuestions() async {
    try {
      setState(() {
        _isLoadingTotalQuestoes = true;
      });
      var data;
      setState(() {
        data = {
          "assuntosId": _myAssuntos,
          "orgaosId": _myOrgaos ,
          "bancasId": _myBancas,
          "cargosId": _myCargos,
          "anosId": _myAnos,
          "certo_errado": certoErrado,
          "acertei": acertei,
          "errei": errei,
          "resolvi": resolvi,
          "naoResolvi": naoResolvi,
          "aleatoria": aleatoria,
        };
      });
      var respo = await CallApi().getData('questoes/count?'
          "assuntosId=${_myAssuntos}&"
          "orgaosId=${_myOrgaos}&"
          "bancasId=${_myBancas}&"
          "cargosId=${_myCargos}&"
          "anosId=${_myAnos}&"
          "certo_errado=${certoErrado}&"
          "acertei=${acertei}&"
          "errei=${errei}&"
          "resolvi=${resolvi}&"
          "naoResolvi=${naoResolvi}&"
          "aleatoria=${aleatoria}");

      print('aqui count');
      setState(() {
        totalQuestoes = respo;
        _isLoadingTotalQuestoes = false;
      });

    } catch (e) {
      AppSettings().showDialogSingleButtonWithRedirect(
          context: context,
          title: 'Aviso',
          message: 'Não foi possível carregar, tente novamente!',
          buttonLabel: 'Fechar');
      setState(() {
        _isLoading = true;
      });
    }
  }
}



class PopularFilterListData {
  String titleTxt;
  bool isSelected;

  PopularFilterListData({
    this.titleTxt = '',
    this.isSelected = false,
  });

  static List<PopularFilterListData> filtrosList = [

    PopularFilterListData(
      titleTxt: 'Apenas as que acertei',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Apenas as que errei',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Apenas as que eu resolvi',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Apenas as que eu não resolvi',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Aleatórias',
      isSelected: false,
    ),
    PopularFilterListData(
      titleTxt: 'Apenas as Certo/Errado',
      isSelected: false,
    ),
  ];
}
