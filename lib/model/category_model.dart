

class CategoryQuestion {

  final id;
  final title;
  final parent_id;
  final description;
  final thumbnail;
  final position;
  final paid;
  final status;
  final question_count;
  final children_count;

  CategoryQuestion(this.id, this.title, this.parent_id, this.description,
      this.thumbnail, this.position, this.paid, this.status,
      this.question_count, this.children_count);

  CategoryQuestion.fromJson(Map<String, dynamic> json)
    : id = json['id'].toString(),
    title = json['title'],
    parent_id = json['parent_id'],
    description = json['description'],
    thumbnail = json['thumbnail'],
    position = json['position'],
    paid = json['paid'],
    status = json['status'],
    question_count = json['question_count'],
    children_count = json['children_count'];

  Map<String, dynamic> toJson()
 => {
    'id': id,
    'title': title,
    'parent_id': parent_id,
    'description': description,
    'thumbnail': thumbnail,
    'position': position,
    'paid': paid,
    'status': status,
    'question_count': question_count ,
    'children_count': children_count
  };


}