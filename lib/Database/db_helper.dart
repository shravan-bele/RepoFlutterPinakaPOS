import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// class AppDBConst {
//   // Database name
//   static const String dbName = 'pinaka.db';
//
//   // Order table name
//   static const String orderTableName = 'order_table';
//
//   // Order table columns
//   static const String orderId = 'order_id'; // Primary key
//   static const String productId = 'product_id'; // Unique identifier for the product
//   static const String productName = 'product_name'; // Name of the product
//   static const String productPrice = 'product_price'; // Price of the product
//   static const String productQuantity = 'product_quantity'; // Quantity of the product
// }
//
// class DBHelper {
//   // Singleton instance
//   static final DBHelper instance = DBHelper._init();
//
//   // Private constructor
//   DBHelper._init();
//
//   Database? _database;
//
//   // Getter for the database
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDB(AppDBConst.dbName);
//     return _database!;
//   }
//
//   // Initialize the database
//   Future<Database> _initDB(String filePath) async {
//     final dbPath = await getDatabasesPath();
//     final path = join(dbPath, filePath);
//
//     return await openDatabase(
//       path,
//       version: 1,
//       onCreate: _createAllTables,
//     );
//   }
//
//   Future _createAllTables(Database db, int version) async {
//     /// call tables
//     await _createOrderTable(db, version);
//
//   }
//
//   // Create the order table
//   Future<void> _createOrderTable(Database db, int version) async {
//     const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
//     const textType = 'TEXT NOT NULL';
//     const realType = 'REAL NOT NULL';
//     const intType = 'INTEGER NOT NULL';
//
//     await db.execute('''
//       CREATE TABLE ${AppDBConst.orderTableName} (
//         ${AppDBConst.orderId} $idType,
//         ${AppDBConst.productId} $textType,
//         ${AppDBConst.productName} $textType,
//         ${AppDBConst.productPrice} $realType,
//         ${AppDBConst.productQuantity} $intType
//       )
//     ''');
//   }
//
//   // Insert a new order item
//   Future<void> insertOrderItem(Map<String, dynamic> orderItem) async {
//     final db = await database;
//     await db.insert(AppDBConst.orderTableName, orderItem);
//   }
//
//   // Fetch all order items
//   Future<List<Map<String, dynamic>>> getOrderItems() async {
//     final db = await database;
//     return await db.query(AppDBConst.orderTableName);
//   }
//
//   // Update an order item
//   Future<void> updateOrderItem(int orderId, Map<String, dynamic> orderItem) async {
//     final db = await database;
//     await db.update(
//       AppDBConst.orderTableName,
//       orderItem,
//       where: '${AppDBConst.orderId} = ?',
//       whereArgs: [orderId],
//     );
//   }
//
//   // Delete an order item
//   Future<void> deleteOrderItem(int orderId) async {
//     final db = await database;
//     await db.delete(
//       AppDBConst.orderTableName,
//       where: '${AppDBConst.orderId} = ?',
//       whereArgs: [orderId],
//     );
//   }
//
//   // Close the database
//   Future<void> close() async {
//     final db = await database;
//     db.close();
//   }
// }
class AppDBConst { // Build #1.0.8, Naveen added
  static const String dbName = 'pinaka.db';

  // Orders Table
  static const String orderTable = 'order_table';
  static const String orderId = 'order_id';
  static const String userId = 'user_id';
  static const String orderTotal = 'order_total';
  static const String orderStatus = 'order_status';
  static const String orderSyncStatus = 'order_sync_status';

  // Order Items Table
  static const String orderItemsTable = 'order_items';
  static const String itemId = 'item_id';
  static const String itemName = 'item_name';
  static const String itemImage = 'item_image'; // Added image column
  static const String itemPrice = 'item_price';
  static const String itemQuantity = 'item_quantity';
  static const String linkedOrderId = 'linked_order_id';
}

class DBHelper { // Build #1.0.8, Naveen added
  static final DBHelper instance = DBHelper._init();
  DBHelper._init();
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppDBConst.dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // DELETE the old database (only for development/testing)
   // await deleteDatabase(path);

    return await openDatabase(path, version: 1, onCreate: _createTables);
  }


  Future _createTables(Database db, int version) async {
    await db.execute('''
    CREATE TABLE ${AppDBConst.orderTable} (
      ${AppDBConst.orderId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${AppDBConst.userId} INTEGER NOT NULL,
      ${AppDBConst.orderTotal} REAL NOT NULL,
      ${AppDBConst.orderStatus} TEXT NOT NULL,
      ${AppDBConst.orderSyncStatus} TEXT NOT NULL
    )
  ''');

    await db.execute('''
    CREATE TABLE ${AppDBConst.orderItemsTable} (
      ${AppDBConst.itemId} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${AppDBConst.itemName} TEXT NOT NULL,
      ${AppDBConst.itemImage} TEXT NOT NULL,
      ${AppDBConst.itemPrice} REAL NOT NULL,
      ${AppDBConst.itemQuantity} INTEGER NOT NULL,
      ${AppDBConst.linkedOrderId} INTEGER NOT NULL,
      ${AppDBConst.userId} INTEGER NOT NULL,  -- ADD THIS COLUMN
      FOREIGN KEY(${AppDBConst.linkedOrderId}) REFERENCES ${AppDBConst.orderTable}(${AppDBConst.orderId}) ON DELETE CASCADE,
      FOREIGN KEY(${AppDBConst.userId}) REFERENCES ${AppDBConst.orderTable}(${AppDBConst.userId}) ON DELETE CASCADE
    )
  ''');
  }


  // Add item to an order with user ID
  Future<void> addItemToOrder(int userID, int orderID, String name, String image, double price, int quantity) async {
    final db = await database;
    await db.insert(AppDBConst.orderItemsTable, {
      AppDBConst.itemName: name,
      AppDBConst.itemImage: image,
      AppDBConst.itemPrice: price,
      AppDBConst.itemQuantity: quantity,
      AppDBConst.linkedOrderId: orderID,
      AppDBConst.userId: userID, // Now it's correctly included
    });
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

// Fetch all order items for a specific user's order
  Future<List<Map<String, dynamic>>> getUserOrderItems(int userID, int orderID) async {
    final db = await database;
    return await db.query(
      AppDBConst.orderItemsTable,
      where: '${AppDBConst.userId} = ? AND ${AppDBConst.linkedOrderId} = ?',
      whereArgs: [userID, orderID],
    );
  }

  // Delete an item from order (Swipe delete)
  Future<void> deleteItem(int itemID) async {
    final db = await database;
    await db.delete(
      AppDBConst.orderItemsTable,
      where: '${AppDBConst.itemId} = ?',
      whereArgs: [itemID],
    );
  }

  // Update an order item
  Future<void> updateOrderItem(int orderId, int userId, Map<String, dynamic> updatedItem) async {
    final db = await database;
    await db.update(
      AppDBConst.orderItemsTable,
      updatedItem,
      where: '${AppDBConst.itemId} = ?',
      whereArgs: [updatedItem[AppDBConst.itemId]],
    );

    // Check if the order still has items
    List<Map<String, dynamic>> remainingItems = await getUserOrderItems(userId, orderId);

    if (remainingItems.isEmpty) {
      // If no items left, mark order as empty or delete it
      await db.update(
        AppDBConst.orderTable,
        {AppDBConst.orderStatus: 'empty'}, // Update status instead of deleting order
        where: '${AppDBConst.orderId} = ?',
        whereArgs: [orderId],
      );
    }
  }


  // Hold an order (Save status as pending)
  Future<void> holdOrder(int orderID) async {
    final db = await database;
    await db.update(
      AppDBConst.orderTable,
      {AppDBConst.orderStatus: 'on_hold'},
      where: '${AppDBConst.orderId} = ?',
      whereArgs: [orderID],
    );
  }

  // Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

