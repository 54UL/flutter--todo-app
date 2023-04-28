
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:todo/services/rest_client.dart';
import 'package:todo/widgets/task_item_widget.dart';
import 'package:http/http.dart' as http;

import '../models/Todo.dart';
import '../states/app_state.dart';

//TODO: MOVE THIS O A CONTROLLER FILE...
Future<List<Todo>> FetchTodos(RestClient restClient) async 
{
  var JsonObject = await restClient.Get("tasks");
  print(JsonObject);
  
   if (JsonObject != null) 
   {
    return JsonObject.map((todoJson) {
      return Todo(
        id: todoJson['id'] as int,
        title: todoJson['title'] as String,
        isCompleted: (todoJson['is_completed'] as int) == 1 ? true : false, //sick ass cast
        date: todoJson['due_date'] ?? 'None' as String,
        comments: "",
        tags: <String>[],
        description: ""
      );
    }).toList();
  } else {
    throw Exception('Failed to fetch todos');
  }
}

class TaskListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RestClient>(
      converter: (store) => store.state.restClient,
      builder: (context, restClient) 
      {
        return Scaffold(
        body: FutureBuilder<List<Todo>>(
            future: FetchTodos(restClient),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final todos = snapshot.data!;
                return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];

                      return TaskItemWidget(todo);
                    });
              }
              else if (snapshot.hasError) {
                return Center(child: Text('${snapshot.error}'));
              } 
              else {
                return Center(child: CircularProgressIndicator());
              }
            }
          )
      );
    });
  }
}
