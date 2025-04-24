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
  static const  String _dev = "https://pinakapos.techkumard.com/"; // Build #1.0.13: new base url
  static const  String _uat = "http://uatapi.pinaka.com/";
  static const  String _prod = "http://api.pinaka.com/";

  //API keys
  static const  String _AndroidApiKey = "?apikey=987654321";
  static const  String _iOSApiKey = "?apikey=123456789";

/////START: make changes here to switch environment
  static const  String host = _dev ;
  static const  String baseUrl = host;
  static const  String componentVersionUrl = "wp-json/pinaka-pos/v1/"; // Build #1.0.13: new componentVersionUrl
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

class UrlMethodConstants { // Build #1.0.13
  static const String token          = "token";
  static const String products       = "products";
  static const String fastKeys       = "fastkeys";  // Build #1.0.15
}

class UrlParameterConstants { // Build #1.0.13
  static const  String productSearchParameter = "?search=";

}

class EndUrlConstants { // Build #1.0.13
  static const  String productSearchEndUrl = "&page=1&limit=10";
  static const  String createFastKeyEndUrl        = "/create";  // Build #1.0.15
  static const  String getFastKeyEndUrl           = "/get-by-user";
  static const  String addFastKeyProductEndUrl    = "/add-products";
  static const  String getFastKeyProductsEndUrl   = "/get-by-fastkey-id/";
}

