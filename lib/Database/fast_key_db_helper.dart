import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'db_helper.dart';

class FastKeyHelper { // Build #1.0.11 : FastKeyHelper for all fast key related methods
  static final FastKeyHelper _instance = FastKeyHelper._internal();
  factory FastKeyHelper() => _instance;

  FastKeyHelper._internal() {
    if (kDebugMode) {
      print("#### FastKeyHelper initialized!");
    }
  }

  Future<int> addFastKeyTab(int userId, String title, String image, int count) async {
    final db = await DBHelper.instance.database;
    final tabId = await db.insert(AppDBConst.fastKeyTable, {
      AppDBConst.userIdForeignKey: userId,
      AppDBConst.fastKeyTabTitle: title,
      AppDBConst.fastKeyTabImage: image,
      AppDBConst.fastKeyTabCount: count,
    });

    if (kDebugMode) {
      print("#### FastKey Tab added with ID: $tabId");
    }
    return tabId;
  }

  Future<List<Map<String, dynamic>>> getFastKeyTabsByUserId(int userId) async {
    final db = await DBHelper.instance.database;
    final tabs = await db.query(
      AppDBConst.fastKeyTable,
      where: '${AppDBConst.userIdForeignKey} = ?',
      whereArgs: [userId],
    );

    if (kDebugMode) {
      print("#### Retrieved ${tabs.length} FastKey Tabs for User ID: $userId");
    }
    return tabs;
  }

  Future<void> updateFastKeyTab(int tabId, Map<String, dynamic> updatedData) async {
    final db = await DBHelper.instance.database;
    await db.update(
      AppDBConst.fastKeyTable,
      updatedData,
      where: '${AppDBConst.fastKeyId} = ?',
      whereArgs: [tabId],
    );

    if (kDebugMode) {
      print("#### FastKey Tab updated with ID: $tabId");
    }
  }

  Future<void> updateFastKeyTabCount(int tabId, int newCount) async {
    final db = await DBHelper.instance.database;
    await db.update(
      AppDBConst.fastKeyTable,
      {AppDBConst.fastKeyTabCount: newCount},
      where: '${AppDBConst.fastKeyId} = ?',
      whereArgs: [tabId],
    );

    if (kDebugMode) {
      print("#### FastKey Tab count updated to $newCount for ID: $tabId");
    }
  }

  Future<void> deleteFastKeyTab(int tabId) async {
    final db = await DBHelper.instance.database;
    await db.delete(
      AppDBConst.fastKeyTable,
      where: '${AppDBConst.fastKeyId} = ?',
      whereArgs: [tabId],
    );

    if (kDebugMode) {
      print("#### FastKey Tab deleted with ID: $tabId");
    }
  }

  Future<int> addFastKeyItem(int tabId, String name, String image, double price,
      {String? sku, String? variantId}) async {
    final db = await DBHelper.instance.database;
    final itemId = await db.insert(AppDBConst.fastKeyItemsTable, {
      AppDBConst.fastKeyIdForeignKey: tabId,
      AppDBConst.fastKeyItemName: name,
      AppDBConst.fastKeyItemImage: image,
      AppDBConst.fastKeyItemPrice: price,
      AppDBConst.fastKeyItemSKU: sku ?? 'N/A',
      AppDBConst.fastKeyItemVariantId: variantId ?? 'N/A',
    });

    if (kDebugMode) {
      print("#### FastKey Item added with ID: $itemId");
    }
    return itemId;
  }

  Future<List<Map<String, dynamic>>> getFastKeyItems(int tabId) async {
    final db = await DBHelper.instance.database;
    final items = await db.query(
      AppDBConst.fastKeyItemsTable,
      where: '${AppDBConst.fastKeyIdForeignKey} = ?',
      whereArgs: [tabId],
    );

    if (kDebugMode) {
      print("#### Retrieved ${items.length} FastKey Items for Tab ID: $tabId");
    }
    return items;
  }

  Future<void> deleteFastKeyItem(int itemId) async {
    final db = await DBHelper.instance.database;
    await db.delete(
      AppDBConst.fastKeyItemsTable,
      where: '${AppDBConst.fastKeyItemId} = ?',
      whereArgs: [itemId],
    );

    if (kDebugMode) {
      print("#### FastKey Item deleted with ID: $itemId");
    }
  }

  Future<void> saveActiveFastKeyTab(int? tabId) async {
    final prefs = await SharedPreferences.getInstance();
    if (tabId != null) {
      await prefs.setInt('activeFastKeyTabId', tabId);
    } else {
      await prefs.remove('activeFastKeyTabId');
    }
  }

  Future<int?> getActiveFastKeyTab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('activeFastKeyTabId');
  }
}
