import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../Constants/text.dart';
import '../../Helper/api_response.dart';
import '../../Models/FastKey/fastkey_product_model.dart';
import '../../Repositories/FastKey/fastkey_product_repository.dart';

class FastKeyProductBloc {  // Build #1.0.15
  final FastKeyProductRepository _repository;

  // Stream Controllers
  final StreamController<APIResponse<FastKeyProductResponse>> _addProductsController =
  StreamController<APIResponse<FastKeyProductResponse>>.broadcast();

  final StreamController<APIResponse<FastKeyProductsResponse>> _getProductsController =
  StreamController<APIResponse<FastKeyProductsResponse>>.broadcast();

  // Getters for Streams
  StreamSink<APIResponse<FastKeyProductResponse>> get addProductsSink => _addProductsController.sink;
  Stream<APIResponse<FastKeyProductResponse>> get addProductsStream => _addProductsController.stream;

  StreamSink<APIResponse<FastKeyProductsResponse>> get getProductsSink => _getProductsController.sink;
  Stream<APIResponse<FastKeyProductsResponse>> get getProductsStream => _getProductsController.stream;

  FastKeyProductBloc(this._repository) {
    if (kDebugMode) {
      print("FastKeyProductBloc Initialized");
    }
  }

  // POST: Add products to FastKey
  Future<void> addProducts({required int fastKeyId, required List<FastKeyProductItem> products}) async {
    if (_addProductsController.isClosed) return;

    addProductsSink.add(APIResponse.loading(TextConstants.loading));
    try {
      final request = FastKeyProductRequest(
        fastKeyId: fastKeyId,
        products: products,
      );

      final response = await _repository.addProductsToFastKey(request);

      if (kDebugMode) {
        print("FastKeyProductBloc - Added products to FastKey: ${response.fastkeyId}");
      }
      addProductsSink.add(APIResponse.completed(response));
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        addProductsSink.add(APIResponse.error("Network error. Please check your connection."));
      } else {
        addProductsSink.add(APIResponse.error("Failed to add products: ${e.toString()}"));
      }
      if (kDebugMode) print("Exception in addProducts: $e");
    }
  }

  // GET: Fetch products by FastKey ID
  Future<void> fetchProductsByFastKeyId(int fastKeyId) async {
    if (_getProductsController.isClosed) return;

    getProductsSink.add(APIResponse.loading(TextConstants.loading));
    try {
      final response = await _repository.getProductsByFastKeyId(fastKeyId);

      if (kDebugMode) {
        print("FastKeyProductBloc - Fetched ${response.products.length} products for FastKey $fastKeyId");
      }
      getProductsSink.add(APIResponse.completed(response));
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        getProductsSink.add(APIResponse.error("Network error. Please check your connection."));
      } else {
        getProductsSink.add(APIResponse.error("Failed to fetch products: ${e.toString()}"));
      }
      if (kDebugMode) print("Exception in fetchProductsByFastKeyId: $e");
    }
  }

  // Dispose all controllers
  void dispose() {
    if (!_addProductsController.isClosed) {
      _addProductsController.close();
    }
    if (!_getProductsController.isClosed) {
      _getProductsController.close();
    }
    if (kDebugMode) print("FastKeyProductBloc disposed");
  }
}