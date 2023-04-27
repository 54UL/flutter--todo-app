
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:todo/widgets/task_item_widget.dart';
import 'package:http/http.dart' as http;

import '../models/Todo.dart';
final String token = "e864a0c9eda63181d7d65bc73e61e3dc6b74ef9b82f7049f1fc7d9fc8f29706025bd271d1ee1822b15d654a84e1a0997b973a46f923cc9977b3fcbb064179ecd";

Future<List<Todo>> fetchTodos() async {
  var url = Uri.parse('https://ecsdevapi.nextline.mx/vdev/tasks-challenge/tasks?token=0xFF');
  // create a new HTTP GET request
  var request = http.Request('GET', url);

  // set the headers
  request.headers.addAll({
    // 'Content-Type': 'application/json',
    'Authorization': 'Bearer ${token}'
  });

  

  // send the request and wait for the response
  final response = await request.send();

  if (response.statusCode == 200) {
    String responseBody = await response.stream.bytesToString();
    final jsonData = jsonDecode(responseBody) as List<dynamic>;
    print(jsonData);
    return jsonData.map((todoJson) {
      return Todo(
        title: todoJson['title'] as String,
        isCompleted: (todoJson['is_completed'] as int) == 1 ? true : false, //sick ass cast
        date:todoJson['due_date'] as String,
        // comments: todoJson['comments'] as String,
        // tags: List<String>.from(todoJson['tags'] as List<dynamic>),
        comments: "",
        tags: <String>[]
      );
    }).toList();
  } else {
    throw Exception('Failed to fetch todos');
  }
}

class TaskListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder<List<Todo>>(
            future: fetchTodos(),
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
  }
}
