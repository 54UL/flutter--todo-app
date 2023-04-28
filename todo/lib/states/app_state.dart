import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:todo/services/rest_client.dart';

class AppState {
  final RestClient restClient;

  AppState({required this.restClient});

  factory AppState.initialState(String baseUrl, String apiKey, String requestToken) {
    print("Initial app state: baseuri:${baseUrl}\nBearer ${apiKey}\nrequestToken ${requestToken}");
    
    return AppState(
      restClient: RestClient( baseUrl: baseUrl , bearerToken: apiKey, requestToken: requestToken),
    );
  }
}