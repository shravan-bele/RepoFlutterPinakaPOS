// product_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../Helper/api_helper.dart';
import '../../Helper/url_helper.dart';
import '../../Models/Search/product_search_model.dart';

class ProductRepository { // Build #1.0.13 : added product search repository
  final APIHelper _helper = APIHelper();

  Future<List<ProductResponse>> fetchProducts({String? searchQuery}) async {
    String url = "${UrlHelper.componentVersionUrl}${UrlMethodConstants.products}";

    // Add search parameter if provided
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += "${UrlParameterConstants.productSearchParameter}$searchQuery${EndUrlConstants.productSearchEndUrl}";
    } else {
      url += EndUrlConstants.productSearchEndUrl;
    }

    if (kDebugMode) {
      print("ProductRepository - URL: $url");
    }

    final response = await _helper.get(url, true);

    if (kDebugMode) {
      print("ProductRepository - Raw Response: $response");
    }

    // Parse the response
    if (response is String) {
      try {
        final List<dynamic> responseData = json.decode(response);
        return responseData.map((productJson) => ProductResponse.fromJson(productJson)).toList();
      } catch (e) {
        if (kDebugMode) {
          print("Error parsing response: $e");
        }
        throw Exception("Failed to parse products");
      }
    } else if (response is List) {
      return response.map((productJson) => ProductResponse.fromJson(productJson)).toList();
    } else {
      throw Exception("Unexpected response type");
    }
  }
}