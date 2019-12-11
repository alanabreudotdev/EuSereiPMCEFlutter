import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


enum Type {
  multiple,
  boolean
}

enum Difficulty {
  easy,
  medium,
  hard
}

//QUESTION TABLE/COLUMNS
final String questionTable = "questionTable";
final String idColumn = "idColumn";
final String questionIdColumn = "questionIdColumn";
final String acertouColumn = "acertouColumn"; //0 para errou | 1 para acertou
final String userIdColumn = "userIdColumn";
final String nameCategoryColumn = "nameCategoryColumn";
final String timeColumn = "timeColumn";
final String dataColumn = "dataColumn";


class QuestionHelper {
  static final QuestionHelper _instance = QuestionHelper.internal();

  factory QuestionHelper() => _instance;

  QuestionHelper.internal();

  var tempoGasto;
  var tempoMedioPerQst;
  double percErros ;
  double percAcertos ;

  Database _db;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    }else{
      _db = await initDb();
    }
    return _db;
  }


 Future<Database> initDb() async {
   final databasesPath = await getDatabasesPath();
   final path = join(await databasesPath, "questions.db");

   return  await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
     await db.execute('''
CREATE TABLE $questionTable ($idColumn INTEGER PRIMARY KEY, 
$questionIdColumn TEXT, 
$acertouColumn TEXT, 
$userIdColumn TEXT, 
$nameCategoryColumn TEXT,
$timeColumn TEXT,
$dataColumn TEXT)
''');

   });
 }

  Future<QuestionResposta>saveResposta(QuestionResposta qstRes) async{
      Database dbQuestionResposta = await db;
      qstRes.id = null;


      int total;

      total = await getTotalQstResolvidasByQuestion(int.parse(qstRes.questionId), qstRes.userId);
      print("TOTAL: $total");

      if(total!= null){
        if(total > 0) {
          await deleteQuestion(int.parse(qstRes.questionId));
          qstRes.id = await dbQuestionResposta.insert(questionTable, qstRes.toMap());
        }else{
          qstRes.id = await dbQuestionResposta.insert(questionTable, qstRes.toMap());
        }
      }else{
        qstRes.id = await dbQuestionResposta.insert(questionTable, qstRes.toMap());
      }

      print(qstRes);
      return qstRes;

    }

    /*

    Future<QuestionResposta>saveResposta(QuestionResposta qstRes) async{
      Database dbQuestionResposta = await db;
      qstRes.id = null;

      qstRes.id = await dbQuestionResposta.insert(questionTable, qstRes.toMap());

      return qstRes;
    }
     */

    Future<QuestionResposta> getQuestion(int questionId, String userId) async{
      Database dbQuestionResposta = await db;
      List<Map> maps = await dbQuestionResposta.rawQuery("SELECT MAX($idColumn) ,$questionIdColumn, $idColumn, $acertouColumn, $userIdColumn, $nameCategoryColumn "
          "FROM $questionTable"
          " WHERE $questionIdColumn = '$questionId' AND $userIdColumn = '$userId' GROUP BY $questionIdColumn ORDER BY $idColumn ASC");

      /* List<Map> maps = await dbQuestionResposta.query(questionTable,
      columns: [idColumn, questionIdColumn, acertouColumn, userIdColumn, nameCategoryColumn],
      where: "$questionIdColumn = ? "
          "AND $userIdColumn = ? "
          "ORDER BY $idColumn "
          "DESC LIMIT 1",
        whereArgs: [questionId, userId]

      );*/

      if(maps.length > 0){
        return QuestionResposta.fromMap(maps.last);
      }else{
        return null;
      }
    }

  /***
   * DELETE QUESTION
   * PARAM: QUESTIONID
   */
  Future<QuestionResposta> deleteQuestion(int questionId) async {
      Database dbQuestionResposta = await db;
      await dbQuestionResposta.delete(questionTable, where: "$questionIdColumn = ?", whereArgs: [questionId]);
    }

    Future<QuestionResposta> updateQuestion(QuestionResposta qstResposta) async{
      Database dbQuestionResposta = await db;
      await dbQuestionResposta.update(questionTable,
          qstResposta.toMap(),
          where: "$questionIdColumn = ?",
          whereArgs: [qstResposta.questionId]);
    }

  /***
   * GET ALL QUESTIONS
   */
  Future<List>getAllQuestionsRespondidas() async {
      Database dbQuestionResposta = await db;
      List listMap = await dbQuestionResposta.rawQuery("SELECT * FROM $questionTable");
      List<QuestionResposta> listQuestionResposta = List();
      for(Map m in listMap){
        listQuestionResposta.add(QuestionResposta.fromMap(m));
      }
      return listQuestionResposta;
    }

  ///**
  ///* GET TOTAL QUESTIONS RESOLVIDAS BY YUSER
  ///* PARAM: userId
  ///*
  Future<int>getTotalQuestionsResolvidasByUser(String userId) async {
      Database dbQuestionResposta = await db;
      return Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable WHERE $userIdColumn = '$userId'"));
  }

    ///**
    ///* GET TOTAL QUESTIONS RESOLVIDAS BY QUESTION
   ///* PARAM: questionId
   ///*/
  Future<int>getTotalQstResolvidasByQuestion(int questionId, String userId) async {
    Database dbQuestionResposta = await db;
    return Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $questionIdColumn = '$questionId' "
        "AND $userIdColumn = '$userId'"
        "GROUP BY $questionIdColumn ORDER BY $idColumn DESC"));
  }

  ///CLOSE DB
    Future close() async {
      Database dbQuestionResposta = await db;
      dbQuestionResposta.close();
    }


    ///METODOS PARA PROFILE DO USUARIO
    ///GET TOTAL ACERTOS
    ///
    Future<int>getTotalQstResolvidasByAcertos(String userId) async {
    Database dbQuestionResposta = await db;
    return Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $acertouColumn = '1'"
        " ORDER BY $idColumn DESC"));
    }

  ///METODOS PARA PROFILE DO USUARIO
  ///GET TOTAL ERROS
  ///
  Future<int>getTotalQstResolvidasByErros( String userId) async {
    Database dbQuestionResposta = await db;
    return Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $acertouColumn = '0'"
        " ORDER BY $idColumn DESC"));
  }

  /// METODOS PARA GERAR ESTATISTICAS POR ASSUNTO DO CONCURSO/QUESTOES ///

  ///GET QUESTIONS TOTAL/ACERTOS/ERROS BY CATEGORY NAME
  Future<Map>getQuestionsByCategoryName({String userId, String categoryName}) async {
    Database dbQuestionResposta = await db;
    var Erros =  Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $nameCategoryColumn = '$categoryName'"
        "AND $acertouColumn = '0'"));
    var Acertos = Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $nameCategoryColumn = '$categoryName' "
        "AND $acertouColumn = '1'"));
    var Total = Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $nameCategoryColumn = '$categoryName'"
    ));
    ///GET TOTAL TIME GASTO
    var Time = Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT sum(strftime('%s', $timeColumn) - strftime('%s','00:00:00')) FROM $questionTable WHERE $nameCategoryColumn = '$categoryName'",null
    ));

    if(Total>0){
      double tempoTotal = Time/60;
      double tempoMedio = (Time/Total)/60;
      format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
      tempoGasto = format(Duration( seconds: tempoTotal.toInt()));
      tempoMedioPerQst = format(Duration( seconds: tempoMedio.toInt()));


       percErros = (Erros/Total)*100;
       percAcertos = (Acertos/Total)*100;

    }else{
      tempoGasto = Duration( seconds: 0);
      tempoMedioPerQst = Duration( seconds: 0);

       percErros = 0;
       percAcertos = 0;
    }




    Map<String, dynamic> qstData = Map();
    qstData = {
      'Total' : Total,
      'Acertos': Acertos,
      'Erros': Erros,
      'percAcertos': percAcertos,
      'percErros': percErros,
      'tempoGasto': tempoGasto,
      'tempoMedio': tempoMedioPerQst
    };
    print(qstData);
    return qstData;
  }



  ///GET QUESTIONS TOTAL/ACERTOS/ERROS BY USER ID
  Future<Map>getQuestionsByUser({String userId, String dataAtual}) async {
    Database dbQuestionResposta = await db;
    var Erros =  Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $acertouColumn = '0'"));
    var Acertos = Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $acertouColumn = '1'"));
    var Total = Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
    ));
    var TotalHoje = Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT COUNT(*) FROM $questionTable "
        "WHERE $userIdColumn = '$userId' "
        "AND $dataColumn = '$dataAtual'"
    ));
    ///GET TOTAL TIME GASTO
    var Time = Sqflite.firstIntValue(await dbQuestionResposta.rawQuery("SELECT sum(strftime('%s', $timeColumn) - strftime('%s','00:00:00')) FROM $questionTable WHERE $userIdColumn = '$userId'",null
    ));

    if(Total>0){
      double tempoTotal = Time/60;
      double tempoMedio = (Time/Total)/60;
      format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
      tempoGasto = format(Duration( seconds: tempoTotal.toInt()));
      tempoMedioPerQst = format(Duration( seconds: tempoMedio.toInt()));


      percErros = (Erros/Total)*100;
      percAcertos = (Acertos/Total)*100;

    }else{
      tempoGasto = Duration( seconds: 0);
      tempoMedioPerQst = Duration( seconds: 0);

      percErros = 0;
      percAcertos = 0;
    }




    Map<String, dynamic> qstData = Map();
    qstData = {
      'TotalHoje' : TotalHoje,
      'Total' : Total,
      'Acertos': Acertos,
      'Erros': Erros,
      'percAcertos': percAcertos,
      'percErros': percErros,
      'tempoGasto': tempoGasto,
      'tempoMedio': tempoMedioPerQst
    };
    print(qstData);
    return qstData;
  }

  /***
   * DELETE QUESTION
   * PARAM: categoryName
   */
  Future<QuestionResposta> deleteQuestionByCategoryName( String categoryName, String userID) async {
    Database dbQuestionResposta = await db;
    await dbQuestionResposta.delete(questionTable, where: "$nameCategoryColumn = ? AND $userIdColumn = ?", whereArgs: [categoryName, userID]);
  }
///
///
/// FIM METODOS PARA GERAR ESTATISTICAS POR ASSUNTO DO CONCURSO/QUESTOES ///
///

  /***
   * GET ALL QUESTIONS
   */

  /* GET questionIds user acertou to filter */
  Future getAcertosQuestionsIds(String categoryName, String tipo ) async {
    Database dbQuestionResposta = await db;
    List<Map> maps;
    if(tipo =="1"){
      maps = await dbQuestionResposta.rawQuery("SELECT DISTINCT($questionIdColumn) FROM $questionTable"
          " WHERE $acertouColumn = '1' AND $nameCategoryColumn = '$categoryName'  ORDER BY $idColumn DESC");
      /*
      maps = await dbQuestionResposta.query(questionTable,
          columns: [questionIdColumn],
          where: '$acertouColumn = ? AND $nameCategoryColumn = ? GROUP BY $questionIdColumn ORDER BY $idColumn DESC',
          whereArgs: ['1', categoryName]);
          */
    }else{
      maps = await dbQuestionResposta.rawQuery("SELECT DISTINCT($questionIdColumn) FROM $questionTable"
          " WHERE $acertouColumn = '0' AND $nameCategoryColumn = '$categoryName' "
          " ORDER BY $idColumn DESC");
      /*
      maps = await dbQuestionResposta.query(questionTable,
          columns: [questionIdColumn],
          where: '$acertouColumn = ? AND $nameCategoryColumn = ? GROUP BY $questionIdColumn ORDER BY $idColumn DESC',
          whereArgs: ['0', categoryName]);
          */
    }

    if (maps.length > 0) {
      List listQstIds = List();
      for(Map m in maps){
        listQstIds.add(m['questionIdColumn']);
      }
      return listQstIds;
    }
    return null;
  }


  }


/******* INICIO SIMULADO *************/

//SIMULADO TABLE/COLUNS
final String simuladoTable = 'simuladoTable';
final String positionSimuladoColumn = 'positionSimuladoColumn'; //salva o numero da questao para deixar na ordem
final String idSimuladoColumn = "idSimuladoColumn";
final String titleSimuladoColumn = 'titleSimuladoColumn';
final String questionSimuladoIdColumn = "questionSimuladoIdColumn";
final String respostaSimuladoIdColumn = "respostaSimuladoIdColumn";
final String respostaEscolhidaColumn = "respostaEscolhidaColumn";
final String explanationSimuladoColumn = 'explanationSimuladoColumn';
final String acertouSimuladoColumn = "acertouSimuladoColumn"; //0 para errou | 1 para acertou
final String userIdSimuladoColumn = "userIdSimuladoColumn";
final String idCategorySimuladoColumn = "idCategorySimuladoColumn";
final String timeSimuladoColumn = "timeSimuladoColumn";
final String totalQuestionsSimuladoColumn = "totalQuestionsSimuladoColumn"; //total de questões presente no simulado

class SimuladoHelper {
  static final SimuladoHelper _instance = SimuladoHelper.internal();

  factory SimuladoHelper() => _instance;

  SimuladoHelper.internal();

  Database _db;

  var tempoGasto;
  var tempoMedioPerQst;
  double percErros ;
  double percAcertos ;

  Future<Database> get db async {
    if(_db != null){
      return _db;
    }else{
      _db = await initDb();
    }
    return _db;
  }


  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
    final path = join(await databasesPath, "simulados.db");

    return  await openDatabase(path, version: 1, onCreate: (Database db, int version) async {

      await db.execute('''
              CREATE TABLE $simuladoTable ($idSimuladoColumn INTEGER PRIMARY KEY, 
              $titleSimuladoColumn TEXT,
              $positionSimuladoColumn TEXT,
              $questionSimuladoIdColumn TEXT,
              $respostaSimuladoIdColumn TEXT, 
              $respostaEscolhidaColumn TEXT,
              $explanationSimuladoColumn TEXT,
              $acertouSimuladoColumn TEXT, 
              $userIdSimuladoColumn TEXT, 
              $idCategorySimuladoColumn TEXT,
              $timeSimuladoColumn TEXT,
              $totalQuestionsSimuladoColumn TEXT)
              
''');

    });
  }


  Future<SimuladoResposta>saveRespostaSimulado(SimuladoResposta smlRes) async{
    Database dbSimuladoResposta = await db;
    smlRes.idSimulado = null;
    int total;

    total = await getTotalQuestionSimulado(int.parse(smlRes.questionSimuladoId), smlRes.userIdSimulado);
    print("TOTAL: $total");

    if(total!= null){
      if(total > 0) {
        await deleteQuestion(int.parse(smlRes.questionSimuladoId));
        smlRes.idSimulado = await dbSimuladoResposta.insert(simuladoTable, smlRes.toMap());
      }else{
        smlRes.idSimulado = await dbSimuladoResposta.insert(simuladoTable, smlRes.toMap());
      }
    }else{
      smlRes.idSimulado = await dbSimuladoResposta.insert(simuladoTable, smlRes.toMap());
    }

    print(smlRes);
    return smlRes;
  }

  /***
   * DELETE QUESTION
   * PARAM: QUESTIONID
   */
  Future<SimuladoResposta> deleteQuestion(int questionId) async {

    print("APAGANDO A QUESTAO: $questionId");
    Database dbSimuladoResposta = await db;
    await dbSimuladoResposta.delete(simuladoTable, where: "$questionSimuladoIdColumn = ?", whereArgs: [questionId]);
  }

  ///**
  ///* GET TOTAL QUESTIONS RESOLVIDAS BY QUESTION
  ///* PARAM: questionId
  ///*/
  Future<int>getTotalQuestionSimulado(int questionSimuladoID, String userSimuladoId) async {
    Database dbSimuladoResposta = await db;
    return Sqflite.firstIntValue(await dbSimuladoResposta.rawQuery("SELECT COUNT(*) FROM $simuladoTable "
        "WHERE $questionSimuladoIdColumn = '$questionSimuladoID' "
        "AND $userIdSimuladoColumn = '$userSimuladoId'"
        "GROUP BY $questionSimuladoIdColumn ORDER BY $idSimuladoColumn DESC"));
  }

  /***
   * DELETE QUESTION
   * PARAM: simuladoID
   */
  Future<SimuladoResposta> deleteQuestionsBySimulado( String simuladoCategoryId, String userSimuladoID) async {
    Database dbSimuladoResposta = await db;
    await dbSimuladoResposta.delete(simuladoTable, where: "$idCategorySimuladoColumn = ? AND $userIdSimuladoColumn = ?", whereArgs: [simuladoCategoryId, userSimuladoID]);
  }

  /****
   * GET RESPOSTA USER OF ANSWER QUESTION
   * param: simuladoCategoryId and userIdSimulado
   */
  Future<SimuladoResposta> getQuestionRespondidaById(String simuladoCategoryId, String userIdSimulado, String questionIdSimulado) async {
    Database dbSimuladoResposta = await db;
     List<Map> maps =  await dbSimuladoResposta.rawQuery("SELECT * FROM $simuladoTable "
        "WHERE $idCategorySimuladoColumn = '$simuladoCategoryId' "
         "AND $userIdSimuladoColumn = '$userIdSimulado' "
         "AND $questionSimuladoIdColumn = '$questionIdSimulado'"
         "ORDER BY $questionSimuladoIdColumn DESC");
    //print(maps);
    if(maps.length > 0){
      return SimuladoResposta.fromMap(maps.last);
    }else{
      return null;
    }
  }

  /****
   * GET all QUESTIONS ANSWER BY USER TO GABARITO
   * param: simuladoCategoryId and userIdSimulado
   */
  Future<List> getQuestionRespondidaBySimulado(String simuladoCategoryId, String userIdSimulado) async {
    Database dbSimuladoResposta = await db;
    List<Map> maps =  await dbSimuladoResposta.rawQuery("SELECT * FROM $simuladoTable "
        "WHERE $idCategorySimuladoColumn = '$simuladoCategoryId' "
        "AND $userIdSimuladoColumn = '$userIdSimulado' "
        "ORDER BY $positionSimuladoColumn ASC");
    //print(maps);
    List<SimuladoResposta> listSimuladoResposta = List();
    for(Map m in maps){
      listSimuladoResposta.add(SimuladoResposta.fromMap(m));
    }
    //print(listSimuladoResposta[0].idSimulado);
    return listSimuladoResposta;
  }


  ///**
  ///* GET TOTAL QUESTIONS RESOLVIDAS POR SIMULADO
  ///* PARAM: userId, simuladoId
  ///*
  Future<int>getTotalQuestionsResolvidas(String userId, String simuladoIdCategory) async {
    Database dbSimuladoResposta = await db;
    return Sqflite.firstIntValue(await dbSimuladoResposta.rawQuery("SELECT COUNT(*) FROM $simuladoTable "
        "WHERE $userIdSimuladoColumn = '$userId' "
        "AND $idCategorySimuladoColumn = '$simuladoIdCategory'"));
  }


  ///GET QUESTIONS TOTAL/ACERTOS/ERROS BY CATEGORY NAME
  Future<Map>getQuestionsBySimulado({String userId, String simuladoId}) async {
    Database dbSimuladoResposta = await db;
    var Erros =  Sqflite.firstIntValue(await dbSimuladoResposta.rawQuery("SELECT COUNT(*) FROM $simuladoTable "
        "WHERE $userIdSimuladoColumn = '$userId' "
        "AND $idCategorySimuladoColumn = '$simuladoId'"
        "AND $acertouSimuladoColumn = '0'"));
    var Acertos = Sqflite.firstIntValue(await dbSimuladoResposta.rawQuery("SELECT COUNT(*) FROM $simuladoTable "
        "WHERE $userIdSimuladoColumn = '$userId' "
        "AND $idCategorySimuladoColumn = '$simuladoId' "
        "AND $acertouSimuladoColumn = '1'"));
    var Total = Sqflite.firstIntValue(await dbSimuladoResposta.rawQuery("SELECT $totalQuestionsSimuladoColumn FROM $simuladoTable "
        "WHERE $userIdSimuladoColumn = '$userId' "
        "AND $idCategorySimuladoColumn = '$simuladoId'"
    ));

    var TotalRespondidas = Sqflite.firstIntValue(await dbSimuladoResposta.rawQuery("SELECT COUNT(*) FROM $simuladoTable "
        "WHERE $userIdSimuladoColumn = '$userId' "
        "AND $idCategorySimuladoColumn = '$simuladoId'"
    ));
    ///GET TOTAL TIME GASTO
    var Time = Sqflite.firstIntValue(await dbSimuladoResposta.rawQuery("SELECT sum(strftime('%s', $timeSimuladoColumn) - strftime('%s','00:00:00')) FROM $simuladoTable WHERE $idCategorySimuladoColumn = '$simuladoId'",null
    ));

    if(TotalRespondidas>0){
      double tempoTotal = Time/60;
      double tempoMedio = (Time/TotalRespondidas)/60;
      format(Duration d) => d.toString().split('.').first.padLeft(8, "0");
      tempoGasto = format(Duration( seconds: tempoTotal.toInt()));
      tempoMedioPerQst = format(Duration( seconds: tempoMedio.toInt()));


      percErros = (Erros/TotalRespondidas)*100;
      percAcertos = (Acertos/TotalRespondidas)*100;

    }else{
      tempoGasto = Duration( seconds: 0);
      tempoMedioPerQst = Duration( seconds: 0);

      percErros = 0;
      percAcertos = 0;
    }




    Map<String, dynamic> qstData = Map();
    qstData = {
      'Total' : Total,
      'TotalRespondidas' : TotalRespondidas,
      'Acertos': Acertos,
      'Erros': Erros,
      'percAcertos': percAcertos,
      'percErros': percErros,
      'tempoGasto': tempoGasto,
      'tempoMedio': tempoMedioPerQst,
      'simuladoId' : '$simuladoId'
    };
    print(qstData);
    return qstData;
  }




}



class SimuladoResposta {
  int idSimulado;
  String position;
  String titleSimulado;
  String questionSimuladoId;
  String respostaSimuladoId;
  String respostaEscolhida;
  String explanationSimulado;
  String acertouSimulado;
  String userIdSimulado;
  String idCategorySimulado;
  String timeSimulado;
  String totalQuestions;

  SimuladoResposta();

  SimuladoResposta.fromMap(Map map){
    idSimulado = map[idSimuladoColumn];
    position = map[positionSimuladoColumn];
    titleSimulado = map[titleSimuladoColumn];
    questionSimuladoId = map[questionSimuladoIdColumn];
    respostaSimuladoId = map[respostaSimuladoIdColumn];
    respostaEscolhida = map[respostaEscolhidaColumn];
    explanationSimulado = map[explanationSimuladoColumn];
    acertouSimulado = map[acertouSimuladoColumn];
    userIdSimulado = map[userIdSimuladoColumn];
    idCategorySimulado = map[idCategorySimuladoColumn];
    timeSimulado = map[timeSimuladoColumn];
    totalQuestions = map[totalQuestionsSimuladoColumn];

  }

  Map toMap(){
    Map<String, dynamic>map = {
      positionSimuladoColumn : position,
      titleSimuladoColumn : titleSimulado,
      questionSimuladoIdColumn : questionSimuladoId,
      respostaSimuladoIdColumn : respostaSimuladoId,
      respostaEscolhidaColumn : respostaEscolhida,
      explanationSimuladoColumn : explanationSimulado,
      acertouSimuladoColumn : acertouSimulado,
      userIdSimuladoColumn : userIdSimulado,
      idCategorySimuladoColumn : idCategorySimulado,
      timeSimuladoColumn : timeSimulado,
      totalQuestionsSimuladoColumn : totalQuestions
    };
    if(idSimulado != null){
      map[idSimuladoColumn] = idSimulado;
    }
    return map;
  }

  @override
  String toString() {
    return "SimuladoResposta(id: $idSimulado, position: $position ,questionId: $questionSimuladoId, respostaCerta: $respostaSimuladoId, respostaEscolhida: $respostaEscolhida, acertou: $acertouSimulado,  userId: $userIdSimulado, simuladoIdCategory: $idCategorySimulado , time: $timeSimulado, totalQuestions: $totalQuestions, title: $titleSimulado, explanation: $explanationSimulado)";
  }
}


/******* FIM SIMULADO **********/



class QuestionResposta {
  int id;
  String questionId;
  String acertou;
  String userId;
  String nameCategory;
  String time;
  String dataResolvida;


  QuestionResposta();

  QuestionResposta.fromMap(Map map){
    id = map[idColumn];
    questionId = map[questionIdColumn];
    acertou = map[acertouColumn];
    userId = map[userIdColumn];
    nameCategory = map[nameCategoryColumn];
    time = map[timeColumn];
    dataResolvida = map[dataColumn];
  }

  Map toMap(){
    Map<String, dynamic>map = {
      questionIdColumn : questionId,
      acertouColumn : acertou,
      userIdColumn : userId,
      nameCategoryColumn : nameCategory,
      timeColumn : time,
      dataColumn : dataResolvida
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "QuestionResposta(id: $id, questionId: $questionId, acertou: $acertou,  userId: $userId, nameCategory: $nameCategory , time: $time, data: $dataResolvida)";
  }


}


class Question {
  final id;
  final title;
  final question_type;
  final number_of_answer;
  final choice_a;
  final choice_b;
  final choice_c;
  final choice_d;
  final choice_e;
  final answer;
  final explanation;
  final dataResolvida;
  final status;


  Question(this.id, this.title, this.question_type, this.number_of_answer,
      this.choice_a, this.choice_b, this.choice_c, this.choice_d, this.choice_e,
      this.answer, this.explanation, this.dataResolvida, this.status);

  Question.fromMap(Map<String, dynamic> data):
        id = data["id"],
        title = data["title"],
        question_type = data["question_type"],
        number_of_answer = data["number_of_answer"],
        choice_a = data["choice_a"],
        choice_b = data["choice_b"],
        choice_c = data["choice_c"],
        choice_d = data["choice_d"],
        choice_e = data["choice_e"],
        answer = data["answer"],
        explanation = data["explanation"],
        dataResolvida = data['dataResolvida'],
        status = data["status"];

  static List<Question> fromData(List<Map<String,dynamic>> data){
    return data.map((question) => Question.fromMap(question)).toList();
  }

}