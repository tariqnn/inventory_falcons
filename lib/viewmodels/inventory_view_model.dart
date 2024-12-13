import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/item.dart';

class InventoryViewModel extends ChangeNotifier {
  List<Item> items = [];
  List<Item> filteredItems = [];
  Database? database;
  bool isLoading = true;
  bool isAscending = true;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  InventoryViewModel() {
    _initializeDatabase().then((_) => fetchData());
  }

  Future<void> _initializeDatabase() async {
    database = await openDatabase(
      join(await getDatabasesPath(), 'inventory.db'),
      version: 2,
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < newVersion) {
          db.execute('DROP TABLE IF EXISTS items');
          db.execute(
            'CREATE TABLE items(id INTEGER PRIMARY KEY, itemNo TEXT, name TEXT, qty REAL)',
          );
        }
      },
    );
  }

  Future<void> fetchData() async {
    try {
      final itemsResponse = await http.get(Uri.parse(
          'http://173.249.1.117:8095/van.dll/getvanalldata?cono=290&strno=1&case=4'));
      final quantityResponse = await http.get(Uri.parse(
          'http://173.249.1.117:8095/van.dll/getvanalldata?cono=290&strno=1&case=9'));

      if (itemsResponse.statusCode == 200 &&
          quantityResponse.statusCode == 200) {
        final itemsData = json.decode(itemsResponse.body)['Items_Master'];
        final quantityData =
        json.decode(quantityResponse.body)['SalesMan_Items_Balance'];

        items = _mergeData(itemsData, quantityData);
        await _storeData(items);
        filteredItems = items;
      } else {
        throw Exception('Failed to fetch data from APIs');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  List<Item> _mergeData(List<dynamic> itemsData, List<dynamic> quantityData) {
    Map<String, Item> itemMap = {};
    for (var item in itemsData) {
      itemMap[item['ITEMNO']] = Item(item['ITEMNO'], item['NAME'], 0);
    }
    for (var qty in quantityData) {
      if (itemMap.containsKey(qty['ItemOCode'])) {
        itemMap[qty['ItemOCode']]!.qty = double.parse(qty['QTY']);
      }
    }
    return itemMap.values.toList();
  }

  Future<void> _storeData(List<Item> items) async {
    await database!.delete('items');
    for (var item in items) {
      await database!.insert('items', item.toMap());
    }
  }

  void filterItems(String query) {
    _searchQuery = query;
    filteredItems = items
        .where((item) =>
    item.name.toLowerCase().contains(query.toLowerCase()) ||
        item.itemNo.toLowerCase().contains(query.toLowerCase()))
        .toList();
    notifyListeners();
  }

  void sortItems() {
    isAscending = !isAscending;
    filteredItems.sort((a, b) =>
    isAscending ? a.qty.compareTo(b.qty) : b.qty.compareTo(a.qty));
    notifyListeners();
  }
}
