import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../Helper/api_helper.dart';
import '../../Helper/url_helper.dart';
import '../../Models/FastKey/fastkey_model.dart';

class FastKeyRepository {  // Build #1.0.15
  final APIHelper _helper = APIHelper();

  // POST: Create FastKey
  Future<FastKeyResponse> createFastKey(FastKeyRequest request) async {
    final url = "${UrlHelper.componentVersionUrl}${UrlMethodConstants.fastKeys}${EndUrlConstants.createFastKeyEndUrl}";

    if (kDebugMode) {
      print("FastKeyRepository - POST URL: $url");
      print("Request body: ${request.toJson()}");
    }

    final response = await _helper.post(url, request.toJson(), true);

    if (kDebugMode) {
      print("FastKeyRepository - POST Raw Response: $response");
    }

    if (response is String) {
      try {
        final responseData = json.decode(response);
        return FastKeyResponse.fromJson(responseData);
      } catch (e) {
        if (kDebugMode) print("Error parsing POST response: $e");
        throw Exception("Failed to parse FastKey response");
      }
    } else if (response is Map<String, dynamic>) {
      return FastKeyResponse.fromJson(response);
    } else {
      throw Exception("Unexpected response type");
    }
  }

  // GET: Fetch FastKeys by User
  Future<FastKeyListResponse> getFastKeysByUser() async {
    final url = "${UrlHelper.componentVersionUrl}${UrlMethodConstants.fastKeys}${EndUrlConstants.getFastKeyEndUrl}";

    if (kDebugMode) {
      print("FastKeyRepository - GET URL: $url");
    }

    final response = await _helper.get(url, true);

    if (kDebugMode) {
      print("FastKeyRepository - GET Raw Response: $response");
    }

    if (response is String) {
      try {
        final responseData = json.decode(response);
        return FastKeyListResponse.fromJson(responseData);
      } catch (e) {
        if (kDebugMode) print("Error parsing GET response: $e");
        throw Exception("Failed to parse FastKey GET response");
      }
    } else if (response is Map<String, dynamic>) {
      return FastKeyListResponse.fromJson(response);
    } else {
      throw Exception("Unexpected response type in GET");
    }
  }
}