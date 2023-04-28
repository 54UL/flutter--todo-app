class Todo {
  int? id;
  String title;
  bool isCompleted;
  String date;
  String comments;
  String description;

  List<String> tags;

  Todo({
    required this.title,
    required this.isCompleted,
    required this.date,
    required this.comments,
    required this.description,
    required this.tags,
    this.id
  });


  Todo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        isCompleted = json['is_completed'] == 1,
        date = json['due_date'],
        comments = json['comments'],
        description = json['description'],
        tags = json['tags'].split(',').map((tag) => tag.trim()).toList();
  
  // factory Todo.fromJson(Map<String, dynamic> json) => 
  //   Todo(json['name'], json['age']);
  
}