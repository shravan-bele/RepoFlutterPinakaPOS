import 'dart:ffi';
import 'dart:io';

class UrlHelper {
  static const Map<String, String> environment = {
    _dev : "DEV",
    _prod : "PROD",
    _uat : "UAT",
    _AndroidApiKey : "ANDROID"
  };
//Hosts
  static const  String _dev = "https://srilokanatha.org/";
  static const  String _uat = "http://uatapi.pinaka.com/";
  static const  String _prod = "http://api.pinaka.com/";

  //API keys
  static const  String _AndroidApiKey = "?apikey=987654321";
  static const  String _iOSApiKey = "?apikey=123456789";

/////START: make changes here to switch environment
  static const  String host = _dev ;
  static const  String baseUrl = host;
  // static const  String apiKey = _devApiKey ;
  static final String apiKey = Platform.isIOS ? _iOSApiKey : _AndroidApiKey; // Build #1.0.8, Naveen updated this line

  // static String get apiKey => _apiKey;///do not change this setting in any circumstances
  //
  // static set apiKey(String value) {
  //   if(Platform.isIOS) {
  //     _apiKey = _iOSApiKey;
  //   } else if(Platform.isAndroid) {
  //     _apiKey = _AndroidApiKey;
  //   }
  // }
  /////END: make changes here to switch environment

  static const  String clientID = "IOS";
  static const  String confirmSuccessUrl = baseUrl;
  static const  String markerUrl =  baseUrl;

  static const  String login = "wp-json/pinaka-pos/v1/token"; // Build #1.0.8
  static const  String refresh = "auth/refresh_token";
  static const  String signup = "auth/signup";
  static const  String forgotPassword = "auth/reestpassword";
  static const  String updatePassword = "auth/update_password";
  static const  String myProfile = "profile/view";
  static const  String updateMyProfile = "profile/update";
  static const  String deleteProfile = "auth/logout";

  static const  String assets = "assets/public";

}

