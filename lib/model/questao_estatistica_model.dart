class QuestaoEstatistica {
  String id;
  int totalA;
  int totalB;
  int totalC;
  int totalD;
  int totalE;
  int totalAcertos;
  int totalErros;
  int tipoQuestao;

  QuestaoEstatistica(
      {this.id,
        this.totalA,
        this.totalB,
        this.totalC,
        this.totalD,
        this.totalE,
        this.totalAcertos,
        this.totalErros,
        this.tipoQuestao});

  QuestaoEstatistica.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    totalA = json['totalA'];
    totalB = json['totalB'];
    totalC = json['totalC'];
    totalD = json['totalD'];
    totalE = json['totalE'];
    totalAcertos = json['totalAcertos'];
    totalErros = json['totalErros'];
    tipoQuestao = json['tipoQuestao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['totalA'] = this.totalA;
    data['totalB'] = this.totalB;
    data['totalC'] = this.totalC;
    data['totalD'] = this.totalD;
    data['totalE'] = this.totalE;
    data['totalAcertos'] = this.totalAcertos;
    data['totalErros'] = this.totalErros;
    data['tipoQuestao'] = this.tipoQuestao;
    return data;
  }
}