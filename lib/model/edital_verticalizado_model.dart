import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';


//EDITAL VERTICALIZADO TABLE/COLUMNS
final String editalTable = "editalVertTable";
final String idColumn = "idColumn";
final String disciplinaIdColumn = "disciplinaIdColumn";
final String assuntoIdColumn = "assuntoIdColumn"; //0 para errou | 1 para acertou
final String userIdColumn = "userIdColumn";
final String nameColumn = "nameColumn"; //TIPO: Resumo, Leitura, Videoaula, Revisao, Questoes
final String valorColumn = "valorColumn"; // tipo INT 1 para concluido / 0 para nao concluido
final String dataColumn = "dataColumn";

class EditalVerticalizadoHelper {

static final EditalVerticalizadoHelper _instance = EditalVerticalizadoHelper.internal();

factory EditalVerticalizadoHelper() => _instance;

EditalVerticalizadoHelper.internal();

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
  final path = join(await databasesPath, "editalverticalizado.db");

  return  await openDatabase(path, version: 1, onCreate: (Database db, int version) async {
    await db.execute('''
CREATE TABLE $editalTable ($idColumn INTEGER PRIMARY KEY AUTOINCREMENT, 
$disciplinaIdColumn TEXT, 
$assuntoIdColumn TEXT, 
$userIdColumn TEXT, 
$nameColumn TEXT,
$valorColumn TEXT,
$dataColumn TEXT)
''');
  });
}

Future<EditalVerticalizado>saveStatus(EditalVerticalizado editalVert) async{
  Database dbEdital = await db;
  editalVert.id = null;

  int total;

  total = await getTotalQstResolvidasByAssunto(int.parse(editalVert.assuntoId), editalVert.userId, editalVert.name);
  print("TOTAL: $total");

  if(total!= null){
    if(total > 0) {
      await deleteAssunto(int.parse(editalVert.assuntoId), editalVert.userId, editalVert.name);
      editalVert.id = await dbEdital.insert(editalTable, editalVert.toMap());
    }else{
      editalVert.id = await dbEdital.insert(editalTable, editalVert.toMap());
    }
  }else{
    editalVert.id = await dbEdital.insert(editalTable, editalVert.toMap());
  }

  print(editalVert);

  editalVert.id = await dbEdital.insert(editalTable, editalVert.toMap());

  return editalVert;
}

/***
 * DELETE QUESTION
 * PARAM: ASSUNTOID
 */
Future<EditalVerticalizado> deleteAssunto(int assuntoId, String userId, String name) async {
  Database dbEdital = await db;
  await dbEdital.delete(editalTable, where: "$assuntoIdColumn = ? AND $userIdColumn = ? AND $nameColumn = ?", whereArgs: [assuntoId, userId, name]);
}

///**
///* GET TOTAL QUESTIONS RESOLVIDAS BY QUESTION
///* PARAM: questionId
///*/
Future<int>getTotalQstResolvidasByAssunto(int assuntoId, String userId, String name) async {
  Database dbEdital = await db;
  return Sqflite.firstIntValue(await dbEdital.rawQuery("SELECT COUNT(*) FROM $editalTable "
      "WHERE $assuntoIdColumn = '$assuntoId' "
      "AND $userIdColumn = '$userId'"
      "AND $nameColumn = '$name'"
      "GROUP BY $assuntoIdColumn ORDER BY $idColumn DESC"));
}

///**
///* VERIFICA SE JA ESTA MARCADO O NAME COM O VALOR PASSADO
///* PARAM: assuntoId, UserID, name
///*/
Future<Map>getValorByAssunto({int assuntoId, String userId}) async {
  Database dbEdital = await db;
   var leitura = Sqflite.firstIntValue(await dbEdital.rawQuery("SELECT COUNT(*) FROM $editalTable "
      "WHERE $assuntoIdColumn = '$assuntoId' "
      "AND $userIdColumn = '$userId'"
      "AND $nameColumn = 'Leitura'"));

  var resumo = Sqflite.firstIntValue(await dbEdital.rawQuery("SELECT COUNT(*) FROM $editalTable "
      "WHERE $assuntoIdColumn = '$assuntoId' "
      "AND $userIdColumn = '$userId'"
      "AND $nameColumn = 'Resumo'"));

  var videoaula = Sqflite.firstIntValue(await dbEdital.rawQuery("SELECT COUNT(*) FROM $editalTable "
      "WHERE $assuntoIdColumn = '$assuntoId' "
      "AND $userIdColumn = '$userId'"
      "AND $nameColumn = 'Videoaula'"));

  var revisao = Sqflite.firstIntValue(await dbEdital.rawQuery("SELECT COUNT(*) FROM $editalTable "
      "WHERE $assuntoIdColumn = '$assuntoId' "
      "AND $userIdColumn = '$userId'"
      "AND $nameColumn = 'Revisao'"));

  var questoes = Sqflite.firstIntValue(await dbEdital.rawQuery("SELECT COUNT(*) FROM $editalTable "
      "WHERE $assuntoIdColumn = '$assuntoId' "
      "AND $userIdColumn = '$userId'"
      "AND $nameColumn = 'Questoes'"));

  var dados = {
    'Leitura' : leitura,
    'Resumo' : resumo,
    'Videoaula' : videoaula,
    'Revisao' : revisao,
    'Questoes' : questoes,
  };
  return dados;
}

Future<EditalVerticalizado> getDataByAssunto({int assuntoId, String userId, String name}) async{
  Database dbEdital = await db;
  List<Map> maps = await dbEdital.rawQuery("SELECT MAX($idColumn) ,$dataColumn "
      "FROM $editalTable"
      " WHERE $assuntoIdColumn = '$assuntoId' "
      " AND $userIdColumn = '$userId'"
      " AND $nameColumn = '$name'"
      " GROUP BY $nameColumn ORDER BY $nameColumn ASC");

  /* List<Map> maps = await dbQuestionResposta.query(questionTable,
      columns: [idColumn, questionIdColumn, acertouColumn, userIdColumn, nameCategoryColumn],
      where: "$questionIdColumn = ? "
          "AND $userIdColumn = ? "
          "ORDER BY $idColumn "
          "DESC LIMIT 1",
        whereArgs: [questionId, userId]

      );*/

  if(maps.length > 0){
    return EditalVerticalizado.fromMap(maps.last);
  }else{
    return null;
  }
}

///CLOSE DB
Future close() async {
  Database dbQuestionResposta = await db;
  dbQuestionResposta.close();
}

}

class EditalVerticalizado {
  int id;
  String disciplinaId;
  String assuntoId;
  String userId;
  String name;
  String valor;
  String data;

  EditalVerticalizado();

  EditalVerticalizado.fromMap(Map map){
    id = map[idColumn];
    disciplinaId = map[disciplinaIdColumn];
    assuntoId = map[assuntoIdColumn];
    userId = map[userIdColumn];
    name = map[nameColumn];
    valor = map[valorColumn];
    data = map[dataColumn];
  }

  Map toMap(){
    Map<String, dynamic>map = {
      disciplinaIdColumn : disciplinaId,
      assuntoIdColumn : assuntoId,
      userIdColumn : userId,
      nameColumn : name,
      valorColumn : valor,
      dataColumn : data
    };
    if(id != null){
      map[idColumn] = id;
    }
    return map;
  }

  @override
  String toString() {
    return "Status(id: $id, disciplinaIdColumn: $disciplinaId, assuntoId: $assuntoId,  userId: $userId, nameCategory: $name , data: $data)";
  }


}