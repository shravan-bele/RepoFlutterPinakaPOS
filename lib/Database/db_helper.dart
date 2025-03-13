import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class AppDBConst { // Build #1.0.10 - Naveen: Updated DB tables constants
  // Database name
  static const String dbName = 'pinaka.db';

  // User Table
  static const String userTable = 'user_table';
  static const String userId = 'user_id';
  static const String userName = 'name';
  static const String userEmail = 'email';
  static const String userOrderCount = 'order_count'; // Tracks total orders by the user
  static const String userPhone = 'phone'; // Optional: For contact details
  static const String userAddress = 'address'; // Optional: For shipping/billing address

  // Orders Table
  static const String orderTable = 'orders_table';
  static const String orderId = 'orders_id';
  static const String orderTotal = 'total';
  static const String orderStatus = 'status'; // e.g., pending, completed, cancelled
  static const String orderType = 'type'; // e.g., online, in-store
  static const String orderDate = 'date'; // Order creation date
  static const String orderTime = 'time'; // Order creation time
  static const String orderPaymentMethod = 'payment_method'; // e.g., cash, card, UPI
  static const String orderDiscount = 'discount'; // Optional: Discount applied to the order
  static const String orderTax = 'tax'; // Optional: Tax applied to the order
  static const String orderShipping = 'shipping'; // Optional: Shipping charges

  // Purchased Items Table
  static const String purchasedItemsTable = 'purchased_items_table';
  static const String itemId = 'items_id';
  static const String itemName = 'item_name';
  static const String itemSKU = 'item_sku'; // Stock Keeping Unit (unique identifier for the product)
  static const String itemPrice = 'item_price';
  static const String itemImage = 'item_image';
  static const String itemCount = 'items_count'; // Quantity of the item
  static const String itemSumPrice = 'item_sum_price'; // Total price (quantity * price)
  static const String orderIdForeignKey = 'order_id'; // Links to the order this item belongs to

  // FastKey Table
  static const String fastKeyTable = 'fast_key';
  static const String fastKeyId = 'fast_key_id';
  static const String fastKeyName = 'fast_key_name';
  static const String fastKeyImage = 'fast_key_image';
  static const String fastKeyItemId = 'item_id'; // Links to the item in the purchased_items_table
}

class DBHelper {
  // Singleton instance to ensure only one instance of DBHelper exists
  static final DBHelper instance = DBHelper._init();
  DBHelper._init();
  Database? _database;

  // Getter for the database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppDBConst.dbName);
    return _database!;
  }

  // Initialize the database
  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Uncomment the line below to delete the database during development/testing
   // await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }

  // Create all tables in the database
  Future _createTables(Database db, int version) async {
    // User Table
    await db.execute('''
    CREATE TABLE ${AppDBConst.userTable} (
      ${AppDBConst.userId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${AppDBConst.userName} TEXT NOT NULL,
      ${AppDBConst.userEmail} TEXT NOT NULL UNIQUE,
      ${AppDBConst.userPhone} TEXT, -- Optional: For contact details
      ${AppDBConst.userAddress} TEXT, -- Optional: For shipping/billing address
      ${AppDBConst.userOrderCount} INTEGER DEFAULT 0 -- Optional: Tracks total orders by the user
    )
    ''');

    // Orders Table
    await db.execute('''
    CREATE TABLE ${AppDBConst.orderTable} (
      ${AppDBConst.orderId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${AppDBConst.userId} INTEGER NOT NULL,
      ${AppDBConst.orderTotal} REAL NOT NULL,
      ${AppDBConst.orderStatus} TEXT NOT NULL,
      ${AppDBConst.orderType} TEXT NOT NULL,
      ${AppDBConst.orderDate} TEXT NOT NULL,
      ${AppDBConst.orderTime} TEXT NOT NULL,
      ${AppDBConst.orderPaymentMethod} TEXT, -- Optional: Payment method (e.g., cash, card)
      ${AppDBConst.orderDiscount} REAL DEFAULT 0, -- Optional: Discount applied to the order
      ${AppDBConst.orderTax} REAL DEFAULT 0, -- Optional: Tax applied to the order
      ${AppDBConst.orderShipping} REAL DEFAULT 0, -- Optional: Shipping charges
      FOREIGN KEY(${AppDBConst.userId}) REFERENCES ${AppDBConst.userTable}(${AppDBConst.userId}) ON DELETE CASCADE
    )
    ''');

    // Purchased Items Table
    await db.execute('''
    CREATE TABLE ${AppDBConst.purchasedItemsTable} (
      ${AppDBConst.itemId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${AppDBConst.itemName} TEXT NOT NULL,
      ${AppDBConst.itemSKU} TEXT NOT NULL,
      ${AppDBConst.itemPrice} REAL NOT NULL,
      ${AppDBConst.itemImage} TEXT NOT NULL,
      ${AppDBConst.itemCount} INTEGER NOT NULL,
      ${AppDBConst.itemSumPrice} REAL NOT NULL,
      ${AppDBConst.orderIdForeignKey} INTEGER NOT NULL,
      FOREIGN KEY(${AppDBConst.orderIdForeignKey}) REFERENCES ${AppDBConst.orderTable}(${AppDBConst.orderId}) ON DELETE CASCADE
    )
    ''');

    // FastKey Table
    await db.execute('''
    CREATE TABLE ${AppDBConst.fastKeyTable} (
      ${AppDBConst.fastKeyId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${AppDBConst.fastKeyName} TEXT NOT NULL,
      ${AppDBConst.fastKeyImage} TEXT NOT NULL,
      ${AppDBConst.fastKeyItemId} INTEGER NOT NULL,
      FOREIGN KEY(${AppDBConst.fastKeyItemId}) REFERENCES ${AppDBConst.purchasedItemsTable}(${AppDBConst.itemId}) ON DELETE CASCADE
    )
    ''');
  }

  // Create a new order and update the user's order count
  Future<int> createOrder(int userID, double orderTotal, String orderStatus, String orderType) async {
    final db = await database;
    final orderId = await db.insert(AppDBConst.orderTable, {
      AppDBConst.userId: userID,
      AppDBConst.orderTotal: orderTotal,
      AppDBConst.orderStatus: orderStatus,
      AppDBConst.orderType: orderType,
      AppDBConst.orderDate: DateTime.now().toString(), // Current date
      AppDBConst.orderTime: DateTime.now().toString(), // Current time
    });

    // Update the user's order count
    await db.rawUpdate('''
    UPDATE ${AppDBConst.userTable}
    SET ${AppDBConst.userOrderCount} = ${AppDBConst.userOrderCount} + 1
    WHERE ${AppDBConst.userId} = ?
    ''', [userID]);

    if (kDebugMode) {
      print('Order created with ID: $orderId');
    }
    return orderId;
  }

  // Add an item to an order
  Future<void> addItemToOrder(int orderID, String name, String image, double price, int quantity, String sku) async {
    final db = await database;

    // Insert the item into the purchased items table
    await db.insert(AppDBConst.purchasedItemsTable, {
      AppDBConst.itemName: name,
      AppDBConst.itemImage: image,
      AppDBConst.itemPrice: price,
      AppDBConst.itemCount: quantity,
      AppDBConst.itemSumPrice: price * quantity,
      AppDBConst.orderIdForeignKey: orderID,
      AppDBConst.itemSKU: sku,
    });

    if (kDebugMode) {
      print('Item added to order: $name');
    }
  }

  // Fetch all orders for a specific user
  Future<List<Map<String, dynamic>>> getUserOrders(int userID) async {
    final db = await database;
    return await db.query(
      AppDBConst.orderTable,
      where: '${AppDBConst.userId} = ?',
      whereArgs: [userID],
    );
  }

  // Fetch all items for a specific order
  Future<List<Map<String, dynamic>>> getOrderItems(int orderID) async {
    final db = await database;
    return await db.query(
      AppDBConst.purchasedItemsTable,
      where: '${AppDBConst.orderIdForeignKey} = ?',
      whereArgs: [orderID],
    );
  }

  // Delete an item from an order
  Future<void> deleteItem(int itemID) async {
    final db = await database;
    await db.delete(
      AppDBConst.purchasedItemsTable,
      where: '${AppDBConst.itemId} = ?',
      whereArgs: [itemID],
    );

    if (kDebugMode) {
      print('Item deleted with ID: $itemID');
    }
  }

  // Delete an order from the database
  Future<void> deleteOrder(int orderId) async {
    final db = await database;
    await db.delete(
      AppDBConst.orderTable,
      where: '${AppDBConst.orderId} = ?',
      whereArgs: [orderId],
    );

    if (kDebugMode) {
      print('Order deleted with ID: $orderId');
    }
  }

  // Close the database connection
  Future<void> close() async {
    final db = await database;
    db.close();

    if (kDebugMode) {
      print('Database closed');
    }
  }
}

