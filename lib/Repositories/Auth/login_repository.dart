import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_udid/flutter_udid.dart';
import '../../Helper/api_helper.dart';
import '../../Helper/url_helper.dart';
import '../../Models/Auth/login_model.dart';

class LoginRepository { // Build #1.0.8, Naveen added
  final APIHelper _helper = APIHelper();
  final LoginRequest? params;

  LoginRepository([this.params]);

  Future<void> getUniqueDeviceId() async {
    try {
      String udid = await FlutterUdid.udid;
      if (kDebugMode) {
        print('Device ID >>>>>> $udid');
      }
    //  params?.deviceID = udid;
    } on PlatformException {
      if (kDebugMode) {
        print('Failed to get Device ID');
      }
    }
  }

  // Future<void> _getFCMToken() async {
  //   try {
  //     String? token = await FirebaseMessaging.instance.getToken();
  //     if (kDebugMode) {
  //       print("FCM token: $token");
  //     }
  //     params?.client_id = token ?? "";
  //
  //     if (Platform.isAndroid) {
  //       final deviceInfo = await DeviceInfoPlugin().androidInfo;
  //       params?.deviceModel = "${deviceInfo.model}-${deviceInfo.device}-${deviceInfo.product}-${deviceInfo.brand}-${deviceInfo.fingerprint}-${deviceInfo.display}-${deviceInfo.version.release}";
  //     } else {
  //       final deviceInfo = await DeviceInfoPlugin().iosInfo;
  //       String? apnToken = await FirebaseMessaging.instance.getAPNSToken();
  //       if (kDebugMode) {
  //         print("APN token: $apnToken");
  //       }
  //       params?.client_id = apnToken ?? "";
  //       params?.deviceModel = "${deviceInfo.model}-${deviceInfo.name}-${deviceInfo.localizedModel}-${deviceInfo.systemName}-${deviceInfo.systemVersion}";
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print("Error getting FCM token: $e");
  //     }
  //   }
  // }

  Future<String> fetchLoginToken() async {
  //  await getUniqueDeviceId();
  //  await _getFCMToken();

    String url = UrlHelper.login;

    if (kDebugMode) {
      print("*********** LoginRepository");
      print(url);
      print(params?.toJson().toString());
    }

    final response = await _helper.post(url, params!.toJson(), false);

    return response;
  }

  Future<String> fetchRefreshToken() async {
    String url = "${UrlHelper.refresh}${UrlHelper.apiKey}";
    if (kDebugMode) {
      print("*********** LoginRepository.fetchRefreshToken");
      print(url);
      print(params?.toJson().toString());
    }
    final response = await _helper.post(url, {}, true);
    return response;
  }
}
