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

  TextEditingController _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _title = widget.title;
    _isCompleted = widget.isCompleted;
    _dueDate = widget.dueDate;
    _comments = widget.comments;
    _description = widget.description;
    // _tags = widget.tags!;
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
            ? "To-do created!!"
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

    print("create todo:" + task.toString());

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
  void _upsertTodo(RestClient restClient) async {
    var task = _TaskPairs();

    if (!_editMode!) {
      task.removeWhere((key, value) => value.isEmpty);
    }

    print("Upsert todo:" + task.toString());

    var succeded = await restClient.Upsert("tasks", task, true);
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

  // //TODO: MOVE THIS TO A CONTROLLER FILE
  void _toggleDone(RestClient restClient, bool state) async {
    
    Map<String, String> task = _TaskPairs();
    task.removeWhere((key, value) => value.isEmpty);

    print("_toggleDone:" + state.toString());

    var succeded = await restClient.Upsert("tasks/${_id}", task, false);
    // _showToast(succeded);
    print("toggle succeded?:" + succeded.toString());
    
    setState(() {
      _isCompleted = !_isCompleted;
    });
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
    );
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, RestClient>(
        converter: (store) => store.state.restClient,
        builder: (context, restClient) {
          if (_id != null && !_todoLoaded) {
            _editMode = true;
            _populateFormWithData(restClient, _id!);
            _todoLoaded = true;
          } else {
            _editMode = false;
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
                    // CheckboxListTile(
                    //   title: Text('DONE'),
                    //   value: _isCompleted,
                    //   onChanged: (newValue) {
                    //     setState(()
                    //     {
                    //       _toggleDone(restClient, !_isCompleted );
                    //     });
                    //   },
                    //   controlAffinity: ListTileControlAffinity.trailing,
                    //   activeColor: Colors.blue
                    // ),
                    Row(children: [
                      Text("STATUS: "),
                      Checkbox(
                      value: _isCompleted,
                      onChanged: (newValue) {
                        setState(()
                        {
                          _toggleDone(restClient, !_isCompleted );
                        });
                      },
                    ),
                    ]),
                    Text("TITLE"),
                    TextFormField(
                      initialValue: _title  ,
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
                        initialValue: _comments,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: _comments ?? 'Comments',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _comments = value;
                          });
                        }),
                    SizedBox(height: 16),
                    TextFormField(
                      initialValue: _description,
                      minLines: 2,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: _description ?? 'Description',
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
                    // Checkbox(
                    //     value: _isCompleted,
                    //     onChanged: (newValue) {
                    //       // TODO: Update completion status.

                    //       _toggleDone(restClient, !_isCompleted );
                    //       print(newValue);
                    //     }),
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
