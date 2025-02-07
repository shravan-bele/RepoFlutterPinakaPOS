import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pinaka_pos/Helper/url_helper.dart';

import 'dart:async';
import 'file_helper.dart';
import '../main.dart';
import 'package:pinaka_pos/Helper/Extentions/exceptions.dart';

class APIHelper {

  Future<dynamic> get(String url, bool useToken) async {
    var responseJson;
    String finalUrl = "";
    String? token= "";
    try {
      finalUrl = UrlHelper.baseUrl + url;
      token = await FileHelper.readToken(); // Issue Fixed: added await to readToken
      //FileHelper.readToken().toString() ?? "";
      if (kDebugMode) {
        print("URL: $finalUrl");
        print("environment : ${UrlHelper.environment[UrlHelper.baseUrl]}");
        print("bearer token : $token");
      }
      /// Sending Bearer token to required services.
      if(useToken){
        if(token != "") {
          final response = await http.get(Uri.parse(finalUrl),
              headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
          responseJson = _returnResponse(response);
        }
      } else {
        ///Bearer token not required services.
        final response = await http.get(Uri(path: finalUrl));
        responseJson = _returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e, s){ // #Build 1.1.194
      if (kDebugMode) {
        print("Exception in GET REQUEST $e ");
        print("FINAL URL ${UrlHelper.baseUrl}$url");
      }
      String log = "FinalURL: $finalUrl; environment : ${UrlHelper.environment[UrlHelper.baseUrl]}; token: $token;";
      throw Exception("Exception: $e ; Stack: $s; Request: $log");
    }
    return responseJson;
  }

  Future<Future<http.StreamedResponse>> downloadFile(String url) async {
    var httpClient = http.Client();
    String finalUrl = "";
    String? token= "";
    try {
      finalUrl = UrlHelper.baseUrl + url;
      token = await FileHelper.readToken(); // Issue Fixed: added await to readToken
      if (kDebugMode) {
        print("URL: $finalUrl");
        print("environment : ${UrlHelper.environment[UrlHelper.baseUrl]}");
        print("bearer token : $token");
      }
      var request = http.Request('GET', Uri.parse(finalUrl));
      request.headers.addAll({HttpHeaders.authorizationHeader: "Bearer $token"});
      var response = httpClient.send(request);
      return response;

    } on SocketException {
      throw FetchDataException('No Internet connection');
    } catch (e, s){ // #Build 1.1.194
      if (kDebugMode) {
        print("Exception in GET REQUEST $e ");
        print("FINAL URL ${UrlHelper.baseUrl}$url");
      }
      String log = "FinalURL: $finalUrl; environment : ${UrlHelper.environment[UrlHelper.baseUrl]}; token: $token;";
      throw Exception("Exception: $e ; Stack: $s; Request: $log");
    }
  }

  Future<dynamic> post(String url, Map<String, dynamic> params, bool useToken) async {
    var responseJson;
    String finalUrl = "";
    String? token= "";
    var body = "";
    try {
      finalUrl = UrlHelper.baseUrl + url;
      token = await FileHelper.readToken(); // Issue Fixed: added await to readToken
      body = json.encode(params);
      if (kDebugMode) {
        print("URL: $finalUrl");
        print("environment : ${UrlHelper.environment[UrlHelper.baseUrl]}");
        print("Body: $body");
        print("bearer token : $token");
      }

      /// Sending Bearer token to required services.
      if(useToken){
        if(token != "") {
          final response = await http.post(Uri.parse(finalUrl), body: body, headers: {
            'Content-Type': "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token"});
          responseJson = _returnResponse(response);
        }
      } else{ ///Bearer token not required services.
        final response = await http.post(Uri.parse(finalUrl), body: body, headers: {
          'Content-Type': "application/json",});
        responseJson = _returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    catch (e,s){
      if (kDebugMode) {
        print("Exception in POST REQUEST $e ");
        print("FINAL URL ${UrlHelper.baseUrl}$url");
      }
      String log = "FinalURL: $finalUrl; environment : ${UrlHelper.environment[UrlHelper.baseUrl]}; token: $token; body: $body";
      throw Exception("Exception: $e ; Stack: $s; Request: $log");
    }
    return responseJson;
  }
// this method added to send multipart form file
  Future<dynamic> postWithFile(String url, bool useToken, FileHelper fileHelper) async {
    var responseJson;
    String log = "";
    String finalUrl = "";
    String? token= "";
    // Build 1.1.45 updated: FileHelper file sending from repository for re-usability of this postWithFile method using FileHelper as parameter
    // This method using Logger and HereMap Logger Service Repositories, check these two repositories.
    // FileHelper fileHelper = FileHelper("${TextConstants.hereMapsLogs}${TextConstants.jsonfileExtension}");
    File formDataFile = await fileHelper.getFile();
    log = " * MultiPartForm file data exists : ${fileHelper.exists()} , ";
    if (kDebugMode) {
      print("MultiPartForm file data exists : ${fileHelper.exists()}");
      print("URL: $finalUrl");
      print("environment : ${UrlHelper.environment[UrlHelper.baseUrl]}");
      print("bearer token : $token");
    }
    try {
      finalUrl = UrlHelper.baseUrl + url;
      token = await FileHelper.readToken();
      if (useToken) {
        if (token != "") {
          if (formDataFile != null) {
            // Create a new multipart request
            var request = http.MultipartRequest('POST', Uri.parse(finalUrl));
            request.headers['Authorization'] = 'Bearer $token';

            // Attach file to the request body
            String fieldName = 'file'; // Customize the field name as needed
            http.MultipartFile file = await http.MultipartFile.fromPath(fieldName, formDataFile.path);
            request.files.add(file);

            // // Attach JSON data to the request body
            // request.fields.addAll(
            //     params.map((key, value) => MapEntry(key, value.toString())));

            var streamedResponse = await request.send();
            var response = await http.Response.fromStream(streamedResponse);
            responseJson = _returnResponse(response);
          }
        }
      }
    } catch (e,s){// #Build 1.1.194
      if (kDebugMode) {
        print("Exception in POST WITH FILE REQUEST $e ");
        print("FINAL URL ${UrlHelper.baseUrl}$url");
      }
      log = "FinalURL: $finalUrl; token: $token;";
      throw Exception("Exception: $e ; environment : ${UrlHelper.environment[UrlHelper.baseUrl]}; Stack: $s; Request: $log");
    }
    return responseJson;
  }

  Future<dynamic> delete(String url) async {
    var responseJson;
    String finalUrl = "";
    String? token= "";
    try {
      finalUrl = UrlHelper.baseUrl + url;
      token = await FileHelper.readToken();
      final response = await http.delete(Uri.parse(finalUrl),
          headers: {HttpHeaders.authorizationHeader: "Bearer $token"});
      responseJson = _returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    catch (e, s){
      if (kDebugMode) {
        print("Exception in DELETE REQUEST $e ");
        print("FINAL URL ${UrlHelper.baseUrl}$url");
      }
      String log = "FinalURL: $finalUrl; environment : ${UrlHelper.environment[UrlHelper.baseUrl]}; token: $token;";
      throw Exception("Exception: $e ; Stack: $s; Request: $log");
    }
    return responseJson;
  }

  Future<dynamic> put(String url, Map<String, dynamic> params, bool useToken) async {
    var responseJson;
    String finalUrl = "";
    String? token= "";
    var body = "";
    try {
      token = await FileHelper.readToken(); // Issue Fixed: added await to readToken
      body = json.encode(params);
      finalUrl = UrlHelper.baseUrl + url;
      if (kDebugMode) {
        print("URL: $finalUrl");
        print("environment : ${UrlHelper.environment[UrlHelper.baseUrl]}");
        print("bearer token : $token");
        print("Body: $body");
      }

      /// Sending Bearer token to required services.
      if(useToken){
        if(token != "") {
          final response = await http.put(Uri.parse(finalUrl), body: body, headers: {
            'Content-Type': "application/json",
            HttpHeaders.authorizationHeader: "Bearer $token"});
          responseJson = _returnResponse(response);
        }
      } else{ ///Bearer token not required services.
        final response = await http.put(Uri.parse(finalUrl), body: body, headers: {
          'Content-Type': "application/json",});
        responseJson = _returnResponse(response);
      }
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    catch (e, s){
      if (kDebugMode) {
        print("Exception in PUT REQUEST $e ");
        print("FINAL URL ${UrlHelper.baseUrl}$url");
      }
      String log = "FinalURL: $finalUrl; environment : ${UrlHelper.environment[UrlHelper.baseUrl]}; token: $token; body: $body";
      throw Exception("Exception: $e ; Stack: $s; Request: $log");
    }
    return responseJson;
  }

  dynamic _returnResponse(http.Response response) {
    if (kDebugMode) {
      print("***************** APIHelper _returnResponse");
    }

    String responseData = //"Body: ${response.body.toString()},"
        "\nHeader: ${response.headers.toString()},"
        "\nReason: ${response.reasonPhrase.toString()}, "
        "\nStatus: ${response.statusCode.toString()}"
        "\nContent Length: ${response.contentLength.toString()}"
    //"\nbodyBytes: ${response.bodyBytes}"
        "\nRequest: ${response.request.toString()}";
    switch (response.statusCode) {
      case 200:
        var responseJson = response.body.trim().toString();//json.decode(response.body.toString());
        if (kDebugMode) {
          print("APIHelper._returnResponse responseJson");
          print(responseData);
        }
        return responseJson;
      case 400:
        throw BadRequestException(responseData);
      case 401:
      case 403:
        if (kDebugMode) {
          print("################  Unauthorised  ############### ");
        }
        // navigatorKey.currentState?.pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const LoginView()),(route) => false);
        throw UnauthorisedException(responseData); // Build #1.1.187
      case 402:
        throw PaymentRequiredException(responseData);
      case 404:
        throw NotFoundException(responseData);
      case 405:
        throw MethodNotAllowedException(responseData);
      case 406:
        throw NotAcceptableException(responseData);
      case 408:
        throw RequestTimeoutException(responseData);
      case 409:
        throw ConflictException(responseData);
      case 410:
        throw GoneException(responseData);
      case 415:
        throw UnsupportedMediaTypeException(responseData);
      case 429:
        throw TooManyRequestsException(responseData);
      case 500:
        throw InternalServerErrorException(responseData);
      case 502:
        throw BadGatewayException(responseData);
      case 503:
        throw ServiceUnavailableException(responseData);
      case 504:
        throw GatewayTimeoutException(responseData);
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response
                .statusCode}');
    }
  }
}