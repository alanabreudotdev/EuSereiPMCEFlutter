
import 'package:scoped_model/scoped_model.dart';



class QuestoesModel extends Model {

  Future<Questoes> getQuestoes(Map<dynamic, dynamic> Data){

    print(Data);

    notifyListeners();
  }

}



class Questoes {
  int limit;
  int currentPage;
  String nextPageUrl;
  int from;
  int to;
  List<Data> data;

  Questoes(
      {this.limit,
        this.currentPage,
        this.nextPageUrl,
        this.from,
        this.to,
        this.data});

  Questoes.fromJson(Map<String, dynamic> json) {
    limit = json['limit'];
    currentPage = json['current_page'];
    nextPageUrl = json['next_page_url'];
    from = json['from'];
    to = json['to'];
    if (json['data'] != null) {
      data = new List<Data>();
      json['data'].forEach((v) {
        data.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['limit'] = this.limit;
    data['current_page'] = this.currentPage;
    data['next_page_url'] = this.nextPageUrl;
    data['from'] = this.from;
    data['to'] = this.to;
    if (this.data != null) {
      data['data'] = this.data.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  Null desatualizada;
  Null anulada;
  int id;
  int origemId;
  String enunciado;
  String alternativaA;
  String alternativaB;
  String alternativaC;
  String alternativaD;
  String alternativaE;
  String resposta;
  int bancaId;
  int anoId;
  int disciplinaId;
  int assuntoId;
  int orgaoId;
  Null cargoId;
  int provaId;
  String createdAt;
  String updatedAt;
  Disciplina disciplina;
  Disciplina orgao;
  Ano ano;
  Disciplina assunto;
  Disciplina prova;
  RespostaUser respostaUser;

  Data(
      {this.desatualizada,
        this.anulada,
        this.id,
        this.origemId,
        this.enunciado,
        this.alternativaA,
        this.alternativaB,
        this.alternativaC,
        this.alternativaD,
        this.alternativaE,
        this.resposta,
        this.bancaId,
        this.anoId,
        this.disciplinaId,
        this.assuntoId,
        this.orgaoId,
        this.cargoId,
        this.provaId,
        this.createdAt,
        this.updatedAt,
        this.disciplina,
        this.orgao,
        this.ano,
        this.assunto,
        this.prova,
        this.respostaUser});

  Data.fromJson(Map<String, dynamic> json) {
    desatualizada = json['desatualizada'];
    anulada = json['anulada'];
    id = json['id'];
    origemId = json['origem_id'];
    enunciado = json['enunciado'];
    alternativaA = json['alternativaA'];
    alternativaB = json['alternativaB'];
    alternativaC = json['alternativaC'];
    alternativaD = json['alternativaD'];
    alternativaE = json['alternativaE'];
    resposta = json['resposta'];
    bancaId = json['banca_id'];
    anoId = json['ano_id'];
    disciplinaId = json['disciplina_id'];
    assuntoId = json['assunto_id'];
    orgaoId = json['orgao_id'];
    cargoId = json['cargo_id'];
    provaId = json['prova_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    disciplina = json['disciplina'] != null
        ? new Disciplina.fromJson(json['disciplina'])
        : null;
    orgao =
    json['orgao'] != null ? new Disciplina.fromJson(json['orgao']) : null;
    ano = json['ano'] != null ? new Ano.fromJson(json['ano']) : null;
    assunto = json['assunto'] != null
        ? new Disciplina.fromJson(json['assunto'])
        : null;
    prova =
    json['prova'] != null ? new Disciplina.fromJson(json['prova']) : null;
    respostaUser = json['resposta_user'] != null
        ? new RespostaUser.fromJson(json['resposta_user'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['desatualizada'] = this.desatualizada;
    data['anulada'] = this.anulada;
    data['id'] = this.id;
    data['origem_id'] = this.origemId;
    data['enunciado'] = this.enunciado;
    data['alternativaA'] = this.alternativaA;
    data['alternativaB'] = this.alternativaB;
    data['alternativaC'] = this.alternativaC;
    data['alternativaD'] = this.alternativaD;
    data['alternativaE'] = this.alternativaE;
    data['resposta'] = this.resposta;
    data['banca_id'] = this.bancaId;
    data['ano_id'] = this.anoId;
    data['disciplina_id'] = this.disciplinaId;
    data['assunto_id'] = this.assuntoId;
    data['orgao_id'] = this.orgaoId;
    data['cargo_id'] = this.cargoId;
    data['prova_id'] = this.provaId;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.disciplina != null) {
      data['disciplina'] = this.disciplina.toJson();
    }
    if (this.orgao != null) {
      data['orgao'] = this.orgao.toJson();
    }
    if (this.ano != null) {
      data['ano'] = this.ano.toJson();
    }
    if (this.assunto != null) {
      data['assunto'] = this.assunto.toJson();
    }
    if (this.prova != null) {
      data['prova'] = this.prova.toJson();
    }
    if (this.respostaUser != null) {
      data['resposta_user'] = this.respostaUser.toJson();
    }
    return data;
  }
}

class Disciplina {
  int id;
  String nome;

  Disciplina({this.id, this.nome});

  Disciplina.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['nome'] = this.nome;
    return data;
  }
}

class Ano {
  int id;
  String ano;

  Ano({this.id, this.ano});

  Ano.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    ano = json['ano'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['ano'] = this.ano;
    return data;
  }
}

class RespostaUser {
  String userUidApp;
  int respostaUser;
  int questaoId;

  RespostaUser({this.userUidApp, this.respostaUser, this.questaoId});

  RespostaUser.fromJson(Map<String, dynamic> json) {
    userUidApp = json['user_uid_app'];
    respostaUser = json['resposta_user'];
    questaoId = json['questao_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['user_uid_app'] = this.userUidApp;
    data['resposta_user'] = this.respostaUser;
    data['questao_id'] = this.questaoId;
    return data;
  }
}
