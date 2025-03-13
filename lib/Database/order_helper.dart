import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Constants/text.dart';
import 'db_helper.dart';

class OrderHelper { // Build #1.0.10 - Naveen: Added Order Helper to Maintain Order data
  // Singleton instance to ensure only one instance of OrderHelper exists
  static final OrderHelper _instance = OrderHelper._internal();
  factory OrderHelper() => _instance;

  int? activeOrderId; // Stores the currently active order ID
  int? activeUserId; // Stores the active user ID
  List<int> orderIds = []; // List of order IDs for the active user

  OrderHelper._internal() {
    loadData(); // Load existing order data on initialization
  }

  // Loads order data from the local database and shared preferences
  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    activeOrderId = prefs.getInt('activeOrderId'); // Retrieve the saved active order ID

    // Fetch the user's orders from the database
    List<Map<String, dynamic>> orders = await DBHelper.instance.getUserOrders(activeUserId ?? 1);

    if (orders.isNotEmpty) {
      // Convert order list from DB into a list of order IDs
      orderIds = orders.map((order) => order[AppDBConst.orderId] as int).toList();

      // If activeOrderId is null or invalid, set it to the last available order ID
      if (activeOrderId == null || !orderIds.contains(activeOrderId)) {
        activeOrderId = orders.last[AppDBConst.orderId];
        await prefs.setInt('activeOrderId', activeOrderId!);
      }
    } else {
      // No orders found, reset values
      activeOrderId = null;
      orderIds = [];
    }

    // Debugging logs
    if (kDebugMode) {
      print("#### loadData: activeOrderId = $activeOrderId");
      print("#### loadData: orderIds = $orderIds");
    }
  }

  // Creates a new order and sets it as active
  Future<int> createOrder() async {
    activeOrderId = await DBHelper.instance.createOrder(activeUserId ?? 1, 0.0, 'pending', 'in-store');

    // Save the newly created order ID in shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeOrderId', activeOrderId!);

    // Refresh the order list
    await loadData();

    return activeOrderId!;
  }

  // Deletes an order from the database and updates local storage
  Future<void> deleteOrder(int orderId) async {
    await DBHelper.instance.deleteOrder(orderId);
    final prefs = await SharedPreferences.getInstance();

    // If the deleted order was the active order, reset the activeOrderId
    if (orderId == activeOrderId) {
      activeOrderId = null;
      await prefs.remove('activeOrderId');
    }

    // Reload the updated order list
    await loadData();

    // Debugging logs
    if (kDebugMode) {
      print('Order deleted with ID: $orderId');
      print('Updated activeOrderId: $activeOrderId');
      print('Updated orderIds: $orderIds');
    }
  }

  // Sets a specific order as the active order
  Future<void> setActiveOrder(int orderId) async {
    activeOrderId = orderId;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('activeOrderId', activeOrderId!);

    // Debugging log
    if (kDebugMode) {
      print("Active order set to: $activeOrderId");
    }
  }

  // Adds an item to the currently active order; creates an order if none exists
  Future<void> addItemToOrder(String name, String image, double price, int quantity, String sku, {VoidCallback? onItemAdded}) async {
    // Ensure there is an active order; create one if needed
    if (activeOrderId == null) {
      await createOrder();
    }

    // Debugging log
    if (kDebugMode) {
      print("#### TEST addItemToOrder : $activeOrderId");
    }

    // Add the item to the order in the database
    await DBHelper.instance.addItemToOrder(activeOrderId!, name, image, price, quantity, sku);

    // Trigger callback if provided (used for UI updates)
    if (onItemAdded != null) {
      onItemAdded();
    }
  }
}


