//HTTP REST CLIENT CONFIGURATION...
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

//BASIC XUL REST IMPLEMENTATION V1.0
//DOES NOT IMPLEMENT BODY IN REQUEST ONLY PARAMS

class RestClient {
  String baseUrl= "";
  String bearerToken= "";
  String requestToken = "";

  RestClient({ required this.baseUrl, required this.bearerToken, required this.requestToken});

  Future<List<dynamic>?> Get(String uri) async 
  {
    uri = baseUrl + uri;
    uri += "?token=${requestToken}";

    var url = Uri.parse(uri);
    // create a new HTTP GET request
    var request = http.Request('GET', url);

    // set the headers
    request.headers.addAll({
      // 'Content-Type': 'application/json',
      'Authorization': 'Bearer ${bearerToken}'
    });

    // send the request and wait for the response
    final response = await request.send();
    final rCode = response.statusCode;
    if (rCode >= 200 && rCode < 300) 
    {

      String responseBody = await response.stream.bytesToString();
      print("GET[SUCCEDED]: (${uri}) RESPONSE: ${responseBody}");

      final jsonData = jsonDecode(responseBody) as List<dynamic>;

      return jsonData;
    }
    else {
      print("POST[ERROR]: ${response.stream.bytesToString()}");
      return null;
    }
  }

  Future<bool> Upsert(String uri, Map<String, String> params, bool updateOrInsert) async 
  {
     // set the request body with URL-encoded format
    uri = baseUrl + uri;
    uri += "?token=${requestToken}";
    uri += params.entries.map((e) => '&${e.key}=${e.value}').join('');
    var url = Uri.parse(uri);
    var requestType = updateOrInsert ? 'POST' : 'PUT';
    // create a new HTTP GET request
    var request = http.Request(requestType, url);

    // set the headers
    request.headers.addAll({
      // 'Content-Type': 'application/json',
      'Authorization': 'Bearer ${bearerToken}',
      'Content-Type' : 'application/x-www-form-urlencoded'
    });

    // send the request and wait for the response
    final response = await request.send();
    final rCode = response.statusCode;
    if (rCode >= 200 && rCode < 300) {
        print("${requestType}[ERRROR]: URI ${uri}  RESPONSE: ${await response.stream.bytesToString()}");
      return true;
    }else{
      print("${requestType}[ERRROR]: URI ${uri}  RESPONSE: ${await response.stream.bytesToString()}");
      return false;
    }
  }

  Future<bool> Delete(String uri) async 
  {
    uri = baseUrl + uri;
    uri += "?token=${requestToken}";
    var url = Uri.parse(uri);

    // create a new HTTP GET request
    var request = http.Request('DELETE', url);

    // set the headers
    request.headers.addAll({
      'Authorization': 'Bearer ${bearerToken}'
    });

    // send the request and wait for the response
    final response = await request.send();
    final rCode = response.statusCode;
    if (rCode >= 200 && rCode < 300) {
      print("DELETE[SUCCEDED]: URI ${uri}  RESPONSE: ${await response.stream.bytesToString()}");
      return true;
    }else{
      print("DELETE[ERRROR]: URI ${uri}  RESPONSE: ${await response.stream.bytesToString()}");
      return false;
    }
  }
}