import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';
import 'package:shopping_list/models/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;

  @override
  void initState() {

    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('flutter-prep-4326-default-rtdb.asia-southeast1.firebasedatabase.app', 'shopping-list.json');
    final response = await http.get(url);

    try {
      final Map<String, dynamic> listData = json.decode(response.body);

      final List<GroceryItem> _loadedItems = [];
      for(final item in listData.entries) {

        final category = categories.entries.firstWhere((catItem) => catItem.value.name == item.value['category']);

        _loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category.value
        ));

        if(_loadedItems.isNotEmpty) {
          setState(() {
            _groceryItems = _loadedItems;
          });
        }
      
      }
    } catch(e) {
      /**
       * Try to change the URL, and it will come in this block.
       */
      print('COMING HERE');
    }
    
  }
  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    // if(newItem == null) {
    //   return;
    // }

    // setState(() {
    //   _groceryItems.add(newItem);
    // });

    if(newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
    // _loadItems();
  }

  

  @override
  Widget build(BuildContext context) {
    
    // Widget content = const Center(
    //   child: Text('No items added yet.'),
    // );
    Widget content = const Center(
        child: CircularProgressIndicator(
          color: Colors.red,
        ),
    );

    if(_groceryItems.length > 1) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => ListTile(
          title: Text(_groceryItems[index].name),
          leading: Container(
              width: 24, height: 24, color: _groceryItems[index].category.color),
          trailing: Text(_groceryItems[index].quantity.toString()),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
      body: content,
    );
  }
}
