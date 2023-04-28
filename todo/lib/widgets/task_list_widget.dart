import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:todo/services/rest_client.dart';
import 'package:todo/widgets/task_item_widget.dart';

import '../models/Todo.dart';
import '../states/app_state.dart';

//TODO: MOVE THIS O A CONTROLLER FILE...
Future<List<Todo>> FetchTodos(RestClient restClient) async {
  var JsonObject = await restClient.Get("tasks");

  if (JsonObject != null) {
    return JsonObject.map((todoJson) {
      return Todo(
          id: todoJson['id'] as int,
          title: todoJson['title'] as String,
          isCompleted: (todoJson['is_completed'] as int) == 1
              ? true
              : false, //sick ass cast
          date: todoJson['due_date'] ?? 'None' as String,
          comments: "",
          tags: <String>[],
          description: "");
    }).toList();
  } else {
    throw Exception('Failed to fetch todos');
  }
}

class TaskListWidget extends StatefulWidget {
  const TaskListWidget({Key? key}) : super(key: key);

  @override
  _TaskListWidgetState createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  late Future<List<Todo>> _todosFuture;
  List<Todo>? _loadedTodos;

  @override
  void initState() {
    super.initState();
  }

  void _refreshList(dynamic index) {
    var todoIndex = index as int;

    setState(() {
      _loadedTodos!.removeAt(todoIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RestClient>(
        converter: (store) => store.state.restClient,
        builder: (context, restClient) {
          return FutureBuilder<List<Todo>>(
              future: FetchTodos(restClient),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final todos = snapshot.data!;
                  _loadedTodos = todos;
                  if (todos.isNotEmpty){
                    return ListView.builder(
                    itemCount: _loadedTodos?.length,
                    itemBuilder: (context, index) {
                      if (_loadedTodos != null) {
                        final todo = _loadedTodos![index];
                        return TaskItemWidget(todo, _refreshList, index);
                      }
                    },
                  );
                }else{
                  return Center(child: Text('Empty todo list...'));
                }
                } else if (snapshot.hasError) {
                  return Center(child: Text('${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              });
        });
  }
}
