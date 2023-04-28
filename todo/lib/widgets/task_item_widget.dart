import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:todo/views/task_view.dart';

import '../models/Todo.dart';
import '../services/rest_client.dart';
import '../states/app_state.dart';

class TaskItemWidget extends StatelessWidget {
  final Todo todo;
  final ValueChanged onDeletedCallBack;
  final int widgetIndex;

  const TaskItemWidget(this.todo, this.onDeletedCallBack, this.widgetIndex, {super.key});

  //TODO: MOVER A UN ARCHIVO LLAMADO TODOS_CONTROLLER.DART
  void _deleteTask(RestClient restClient) async {;
    var succeded = await restClient.Delete("tasks/${todo.id}");
    if (succeded != null) 
    {
      onDeletedCallBack(widgetIndex);

      Fluttertoast.showToast(
        msg: "Todo deleted...",
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } else {
      Fluttertoast.showToast(
        msg: "Can't delete todo... (error)",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }
  
  void NavigateToTaskView(BuildContext context) {
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
    return StoreConnector<AppState, RestClient>(
        converter: (store) => store.state.restClient,
        builder: (context, restClient) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Row(children: [
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
                          decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.lightBlue),
                    ),
                    SizedBox(height: 8),
                    Row(children: [
                      Chip(
                      label: Text("${todo.isCompleted ? "DONE" : "TO-DO"}",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      backgroundColor: todo.isCompleted ? Colors.green : Colors.amber,
                    ),
                    Chip(
                      label: Text("Due date [ ${todo.date} ]",
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold)),
                      backgroundColor: Colors.lightBlueAccent,
                    )
                    ],)
                  ],
                ),
              )),
              SizedBox(width: 8),
              IconButton(
                  onPressed: () => _deleteTask(restClient),
                  icon: const Icon(Icons.delete))
            ]),
          );
        });
  }
}
