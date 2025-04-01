// product_bloc.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../Constants/text.dart';
import '../../Helper/api_response.dart';
import '../../Models/Search/product_search_model.dart';
import '../../Repositories/Search/product_search_repository.dart';

class ProductBloc { // Build #1.0.13: Added Product Search Bloc
  final ProductRepository _productRepository;
  late StreamController<APIResponse<List<ProductResponse>>> _productController;
  // = StreamController<APIResponse<List<ProductResponse>>>.broadcast();
  StreamController<APIResponse<List<ProductResponse>>> get productController => _productController;

  StreamSink<APIResponse<List<ProductResponse>>> get productSink => _productController.sink;
  Stream<APIResponse<List<ProductResponse>>> get productStream => _productController.stream;

  ProductBloc(this._productRepository) {
    if (kDebugMode) {
      print("ProductBloc Initialized");
    }
    _productController =
    StreamController<APIResponse<List<ProductResponse>>>.broadcast();
  }

  Future<void> fetchProducts({String? searchQuery}) async {
    if (_productController.isClosed) return;

    productSink.add(APIResponse.loading(TextConstants.loading));
    try {
      List<ProductResponse> products = await _productRepository.fetchProducts(searchQuery: searchQuery);

      if (products.isNotEmpty) {
        if (kDebugMode) {
          print("ProductBloc - Fetched ${products.length} products");
          print("First product: ${products.first.toJson()}");
        }
        productSink.add(APIResponse.completed(products));
      } else {
        productSink.add(APIResponse.error("No products found"));
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        productSink.add(APIResponse.error("Network error. Please check your connection."));
      } else {
        productSink.add(APIResponse.error("No products found"));
      }
      if (kDebugMode) print("Exception in fetchProducts: $e");
    }
  }

  void dispose() {
    if (!_productController.isClosed) {
      _productController.close();
      if (kDebugMode) print("ProductBloc disposed");
    }
  }
}