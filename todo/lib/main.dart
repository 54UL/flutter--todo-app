import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:redux/redux.dart';
import 'package:todo/reducers/app_reducer.dart';
import 'package:todo/states/app_state.dart';
import 'package:todo/views/main_page.dart';

void main() async
{
  //Load envs...
  await dotenv.load();
  String apiKey = dotenv.env['API_KEY']!;
  String baseUrl = dotenv.env['BASE_URL']!;    
  String requestToken = dotenv.env['REQUEST_TOKEN']!;    

  //Set app's initial state
   var store = Store<AppState>(
    appReducer,
    initialState: AppState.initialState(baseUrl, apiKey, requestToken)
  );

  //Run app
  runApp(TodoApp(key: null,  appStore: store));
}
