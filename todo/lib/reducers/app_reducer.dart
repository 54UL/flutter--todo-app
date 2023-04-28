

import '../states/app_state.dart';

AppState appReducer(AppState state, dynamic action) {
  return AppState(
    restClient: state.restClient
  );
}