import 'package:flutter/material.dart';

import '../models/Todo.dart';

class TaskItemWidget extends StatelessWidget 
{
  final Todo todo;
  
  const TaskItemWidget(
    this.todo
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  todo.date,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Comments: $todo.comments',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: todo.tags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      backgroundColor: Colors.green[300],
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Checkbox(
          value: todo.isCompleted,
          onChanged: (newValue) {
            // TODO: Update completion status.
            }
          )
        ],
      ),
    );
  }
}