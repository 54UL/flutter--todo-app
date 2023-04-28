import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/views/task_view.dart';

import '../models/Todo.dart';
import '../services/rest_client.dart';
import '../states/app_state.dart';

class TaskItemWidget extends StatelessWidget {
  final Todo todo;
  const TaskItemWidget(this.todo);

  //TODO: MOVER A UN ARCHIVO LLAMADO TODOS_CONTROLLER.DART
  void _deleteTask(RestClient restClient) async
  {
      var succeded = await restClient.Delete("tasks/${todo.id}");
      if (succeded != null)
      {
        Fluttertoast.showToast(
          msg: "Task created!!",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      }
      else {
        Fluttertoast.showToast(
          msg: "Cannot create task",
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
  }

  void NavigateToTaskView(BuildContext context)
  {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => const TaskView(),
        settings: RouteSettings(
        arguments: todo.id,
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Checkbox(
              value: todo.isCompleted,
              onChanged: (newValue) {
                // TODO: Update completion status.
                print(newValue);
              }),
          SizedBox(width: 8),
          Expanded(
            child: InkWell(
            onTap: () => NavigateToTaskView(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.lightBlue),
                ),
                // SizedBox(height: 8),
                // Text(
                //   'Comments: $todo.comments',
                //   style: TextStyle(fontSize: 18),
                // ),
                SizedBox(height: 8),
                Chip(
                  label: Text("Due date [ ${todo.date} ]",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.lightBlueAccent,
                ),
                
                // Wrap(
                //   spacing: 8,
                //   runSpacing: 8,
                //   children: todo.tags.map((tag) {
                //     return Chip(
                //       label: Text(tag),
                //       backgroundColor: Colors.green[300],
                //     );
                //   }).toList(),
                // ),
              ],
            ),
            )
          ),
          SizedBox(width: 8),
          StoreConnector<AppState, RestClient>(
          converter: (store) => store.state.restClient,
          builder: (context, restClient) 
            {
              return  IconButton(
                onPressed: () => _deleteTask(restClient),
                icon: const Icon(Icons.delete));
            }
          )
        ],
      ),
    );
  }
}
