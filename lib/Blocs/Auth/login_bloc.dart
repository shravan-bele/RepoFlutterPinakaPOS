import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../Constants/text.dart';
import '../../Helper/api_response.dart';
import '../../Helper/file_helper.dart';
import '../../Models/Auth/login_model.dart';
import '../../Repositories/Auth/login_repository.dart';

class LoginBloc { // Build #1.0.8
  final LoginRepository _loginRepository;
  final StreamController<APIResponse<LoginResponse>> _loginController = StreamController<APIResponse<LoginResponse>>.broadcast();

  StreamSink<APIResponse<LoginResponse>> get loginSink => _loginController.sink;
  Stream<APIResponse<LoginResponse>> get loginStream => _loginController.stream;

  LoginBloc(this._loginRepository) {
    if (kDebugMode) {
      print("************** LoginBloc Initialized");
    }
  }

  Future<void> fetchLoginToken() async {
    if (_loginController.isClosed) return;

    loginSink.add(APIResponse.loading(TextConstants.loading));
    try {
      String token = await _loginRepository.fetchLoginToken();
      await FileHelper("${TextConstants.login}${TextConstants.jsonfileExtension}").writeJOSNDataToFile(token);

      LoginResponse loginResponse = LoginResponse.fromJson(json.decode(token));
      loginSink.add(APIResponse.completed(loginResponse));
    } catch (e, s) {
      _handleException(e, "fetchLoginToken");
      if (kDebugMode) print("Exception in fetchLoginToken: $e\nStackTrace: $s");
    }
  }

  Future<void> fetchRefreshToken() async {
    if (_loginController.isClosed) return;

    loginSink.add(APIResponse.loading('loading'));
    try {
      if (await _checkTokenStatus()) {
        String token = await _loginRepository.fetchRefreshToken();
        await FileHelper("${TextConstants.login}${TextConstants.jsonfileExtension}").writeJOSNDataToFile(token);

        LoginResponse loginResponse = LoginResponse.fromJson(json.decode(token));
        loginSink.add(APIResponse.completed(loginResponse));
      } else {
        loginSink.add(APIResponse.error("Token not available"));
      }
    } catch (e, s) {
      _handleException(e, "fetchRefreshToken");
      if (kDebugMode) print("Exception in fetchRefreshToken: $e\nStackTrace: $s");
    }
  }

  Future<bool> _checkTokenStatus() async {
    String? token = await FileHelper.readToken();
    return token!.isNotEmpty;
  }

  void _handleException(dynamic e, String methodName) {
    String errorMessage = "$methodName: ${e.toString()}";
    loginSink.add(APIResponse.error(errorMessage));
    if (kDebugMode) print(errorMessage);
  }

  void dispose() {
    if (!_loginController.isClosed) {
      _loginController.close();
      if (kDebugMode) print("LoginBloc disposed");
    }
  }
}
