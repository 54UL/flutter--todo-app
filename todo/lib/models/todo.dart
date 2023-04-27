class Todo {
  String title;
  bool isCompleted;
  String date;
  String comments;
  List<String> tags;

  Todo({
    required this.title,
    required this.isCompleted,
    required this.date,
    required this.comments,
    required this.tags,
  });
}