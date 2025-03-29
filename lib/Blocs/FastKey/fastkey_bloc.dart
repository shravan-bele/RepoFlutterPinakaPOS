import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../Constants/text.dart';
import '../../Helper/api_response.dart';
import '../../Models/FastKey/fastkey_model.dart';
import '../../Repositories/FastKey/fastkey_repository.dart';

class FastKeyBloc { // Build #1.0.15
  final FastKeyRepository _fastKeyRepository;

  // Stream Controllers
  final StreamController<APIResponse<FastKeyResponse>> _createFastKeyController =
  StreamController<APIResponse<FastKeyResponse>>.broadcast();

  final StreamController<APIResponse<FastKeyListResponse>> _getFastKeysController =
  StreamController<APIResponse<FastKeyListResponse>>.broadcast();

  // Getters for Streams
  StreamSink<APIResponse<FastKeyResponse>> get createFastKeySink => _createFastKeyController.sink;
  Stream<APIResponse<FastKeyResponse>> get createFastKeyStream => _createFastKeyController.stream;

  StreamSink<APIResponse<FastKeyListResponse>> get getFastKeysSink => _getFastKeysController.sink;
  Stream<APIResponse<FastKeyListResponse>> get getFastKeysStream => _getFastKeysController.stream;

  FastKeyBloc(this._fastKeyRepository) {
    if (kDebugMode) {
      print("FastKeyBloc Initialized");
    }
  }

  // POST: Create FastKey
  Future<void> createFastKey({required String title, required int index, required String imageUrl, required int userId}) async {
    if (_createFastKeyController.isClosed) return;

    createFastKeySink.add(APIResponse.loading(TextConstants.loading));
    try {
      final request = FastKeyRequest(
        fastkeyTitle: title,
        fastkeyIndex: index,
        fastkeyImage: imageUrl,
        userId: userId,
      );

      final response = await _fastKeyRepository.createFastKey(request);

      if (kDebugMode) {
        print("FastKeyBloc - Created FastKey: ${response.fastkeyId}");
      }
      createFastKeySink.add(APIResponse.completed(response));
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        createFastKeySink.add(APIResponse.error("Network error. Please check your connection."));
      } else {
        createFastKeySink.add(APIResponse.error("Failed to create FastKey: ${e.toString()}"));
      }
      if (kDebugMode) print("Exception in createFastKey: $e");
    }
  }

  // GET: Fetch FastKeys by User
  Future<void> fetchFastKeysByUser() async {
    if (_getFastKeysController.isClosed) return;

    getFastKeysSink.add(APIResponse.loading(TextConstants.loading));
    try {
      final response = await _fastKeyRepository.getFastKeysByUser();

      if (kDebugMode) {
        print("FastKeyBloc - Fetched ${response.fastkeys.length} fastkeys");
      }
      getFastKeysSink.add(APIResponse.completed(response));
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        getFastKeysSink.add(APIResponse.error("Network error. Please check your connection."));
      } else {
        getFastKeysSink.add(APIResponse.error("Failed to fetch FastKeys: ${e.toString()}"));
      }
      if (kDebugMode) print("Exception in fetchFastKeysByUser: $e");
    }
  }

  // Dispose all controllers
  void dispose() {
    if (!_createFastKeyController.isClosed) {
      _createFastKeyController.close();
    }
    if (!_getFastKeysController.isClosed) {
      _getFastKeysController.close();
    }
    if (kDebugMode) print("FastKeyBloc disposed");
  }
}