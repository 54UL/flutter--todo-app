import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:todo/models/todo.dart';

import '../services/rest_client.dart';
import '../states/app_state.dart';

class TaskView extends StatefulWidget {
  final String? title;
  final bool isCompleted;
  final String? dueDate;
  final String? comments;
  final String? description;
  final List<String>? tags;

  const TaskView(
      {Key? key,
      this.title,
      this.isCompleted = false,
      this.dueDate,
      this.comments,
      this.description,
      this.tags})
      : super(key: key);

  @override
  _TaskViewState createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  final _formKey = GlobalKey<FormState>();

  //TODO: MOVE TO A MODEL
  int? _id;
  String? _title;
  bool _isCompleted = false;
  String? _dueDate;
  String? _comments;
  String? _description;
  List<String> _tags = [];
  bool? _editMode;
  bool _todoLoaded = false;

  //TODO: REFACTOR all text input values to his controller (forget the _name references)
  TextEditingController _tagsController = TextEditingController();
  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _isCompleted = widget.isCompleted;
    _dueDate = widget.dueDate;
    _comments = widget.comments;
    _description = widget.description;
    _editMode = false;
  }

  String formatDate(DateTime? date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = formatter.format(date!);
    return formattedDate;
  }

  //Date picker on select action
  void selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    setState(() {
      if (picked != null) _dueDate = formatDate(picked);
    });
  }

  //if successToast == true shows an succes messages otherwise the opposite.
  Future<bool?> _showToast(bool successToast) {
    return Fluttertoast.showToast(
        msg: successToast
            ? (_editMode! ? "Todo-updated" : "To-do created!!")
            : "Erro while saving to-do(Try again later)",
        backgroundColor: successToast ? Colors.greenAccent : Colors.redAccent,
        textColor: successToast ? Colors.white : Colors.black);
  }

  //TODO: MOVE THIS O A CONTROLLER FILE...
  void _createTodo(RestClient restClient) async {
    Map<String, String> task = {
      'title': _title ?? '',
      'is_completed':
          _isCompleted.toString().compareTo("true") == 0 ? "1" : "0",
      'due_date': _dueDate ?? '',
      'comments': _comments ?? '',
      'description': _description ?? '',
      'tags': _tags.join(',')
    };

    task.removeWhere((key, value) => value.isEmpty);

    var succeded = await restClient.Upsert("tasks", task, false);
    _showToast(succeded);
  }

  Map<String, String> _TaskPairs()=> <String, String>{
      'title': _title ?? '',
      'is_completed': _isCompleted.toString().compareTo("true") == 0 ? "1" : "0",
      'due_date': _dueDate ?? '',
      'comments': _comments ?? '',
      'description': _description ?? '',
      'tags': _tags.join(',')
    };

  //TODO: MOVE THIS O A CONTROLLER FILE...
  void _upsertTodo(RestClient restClient, String? todoId) async {
    var task = _TaskPairs();

    if (!_editMode!) {
      task.removeWhere((key, value) => value.isEmpty);
    }
    String path = todoId == null ? "tasks" : "tasks/${todoId ?? ''}"; 
    var succeded = await restClient.Upsert(path, task, !_editMode!);

    _showToast(succeded);
  }

  //TODO: MOVE THIS O A CONTROLLER FILE...
  Future<Todo> _fetchTodoById(RestClient restClient, int todoId) async {
    final jsonObject = await restClient.Get("tasks/$todoId");
    if (jsonObject != null) {
      final todoJson = jsonObject[0];
      return Todo(
        id: todoJson['id'] as int,
        title: todoJson['title'] as String,
        isCompleted: (todoJson['is_completed'] as int) == 1,
        date: todoJson['due_date'] ?? '',
        comments: todoJson['comments'] ?? '',
        tags: todoJson['tags']?.split(',') ?? [],
        description: todoJson['description'] ?? '',
      );
    } else {
      throw Exception('Failed to fetch todo');
    }
  }

  PreferredSizeWidget _resolveAppBar(bool editOrCreate) {
    return editOrCreate
        ? AppBar(
            title: Text(_title ?? 'New Task'),
          )
        : AppBar();
  }

  void _saveForm(RestClient restClient, int? todoId) {
    
    _upsertTodo(
      restClient,
      todoId?.toString(),
    );

    if (!_editMode!) {
      //Clean fields
      setState(() {
        _isCompleted = false;
        _id = null;
        _tags = [];
        _dueDate = "";
        _tagsController.clear();
        _titleController.clear();
        _descriptionController.clear();
        _commentsController.clear();
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the navigation arguments here
    int? todoId = ModalRoute.of(context)?.settings.arguments as int?;

    if (todoId != _id) {
      _todoLoaded = false;
    }

    _id = todoId;
  }

  Future<void> _populateFormWithData(RestClient restClient, int todoId) async {
    Todo todo = await _fetchTodoById(restClient, todoId);

    setState(() {
      _id = todo.id;
      _isCompleted = todo.isCompleted;
      _title = todo.title;
      _dueDate = todo.date;
      _comments = todo.comments;
      _description = todo.description;
      _tags = todo.tags;

      //set controllers
      _titleController.text = todo.title;
      _commentsController.text = todo.comments;
      _descriptionController.text = todo.description;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RestClient>(
        converter: (store) => store.state.restClient,
        builder: (context, restClient) {
          
          //TODO: implement a better way to fix this
          if (_id != null && !_todoLoaded) {
            _editMode = true;
            _populateFormWithData(restClient, _id!);
            _todoLoaded = true;
          }
      
          return Scaffold(
            appBar: _resolveAppBar(!_editMode!),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isCompleted ? Colors.green : Colors.amber,
                        minimumSize: const Size.fromHeight(50), // NEW
                      ),
                      child: Text( _isCompleted ? 'UNMARK AS DONE':'MARK AS DONE'),
                      onPressed: () {
                        setState(() {
                           _isCompleted = !_isCompleted;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      // initialValue: _title  ,
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _title = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                        controller: _commentsController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Comments',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _comments = value;
                          });
                        }),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description',
                      ),
                      onChanged: (value) {
                        setState(() {
                          _description = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      onTap: () {
                        selectDate(context);
                      },
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'Select Date',
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      controller: TextEditingController(
                        text: _dueDate,
                      ),
                    ),
                    SizedBox(height: 32),
                    Wrap(
                      children: [
                        for (final tag in _tags)
                          InputChip(
                            backgroundColor: Colors.blue[100],
                            label: Text(tag),
                            onDeleted: () {
                              setState(() {
                                _tags.remove(tag);
                              });
                            },
                          ),
                        SizedBox(width: 8),
                        InputChip(
                          backgroundColor: Colors.green[300],
                          label: Text('Add Tag'),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Add Tag'),
                                  content: TextFormField(
                                    controller: _tagsController,
                                    decoration: InputDecoration(
                                      labelText: 'Tag',
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        _tagsController.clear();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Add'),
                                      onPressed: () {
                                        setState(() {
                                          _tags.add(_tagsController.text);
                                          _tagsController.clear();
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Divider(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.green,
                        minimumSize: const Size.fromHeight(50), // NEW
                      ),
                      child: Text('SAVE'),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _saveForm(restClient, _id);
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }
}
