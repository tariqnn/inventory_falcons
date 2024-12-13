import 'package:flutter/material.dart';
import 'views/inventory_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory System',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: InventoryScreen(),
    );
  }
}
