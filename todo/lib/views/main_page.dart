import 'dart:convert';
import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:http/http.dart' as http;
import 'package:redux/redux.dart';
import 'package:todo/views/task_view.dart';

import '../reducers/app_reducer.dart';
import '../states/app_state.dart';
import '../widgets/task_item_widget.dart';
import '../widgets/task_list_widget.dart';

class MyScaffold extends StatefulWidget {
  @override
  _MyScaffoldState createState() => _MyScaffoldState();
}

class _MyScaffoldState extends State<MyScaffold> {
  int _selectedIndex = 0;

  List<Widget> _pages = [TaskListWidget(), TaskView(), TaskView()];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tasks"),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'To-do',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_add),
            label: 'Add to-do',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

Widget BaseApp(){
  return  MaterialApp(
      title: 'Basic todo list',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyScaffold()
    );
}

//entry point
class TodoApp extends StatelessWidget 
{
  Store<AppState>? appStore;
  TodoApp({super.key, this.appStore });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) 
  {
    return StoreProvider(store: appStore!, child: BaseApp());
  }
}

