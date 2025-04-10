import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true; //managing the loading state
  String? _error; //may be null

  //load item method is triggered and this request is sent if the state object is created for the fist time
  @override
  void initState() {
    super.initState();
    //for initialization work here to send my request
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'flutter-prep-e321a-default-rtdb.firebaseio.com',
      //'flutter-prep-e321a-default-rtdb.firebaseio.com',
      'shopping-list.json',
    );
    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data.Please try again later!';
        });
      }

      if (response.body ==
          'null') //what firebase does is it returns to string nullx`
      {
        setState(() {
          _isLoading = false;
        });
        return; //so we will not execute below codes
      }

      final Map<String, dynamic> listData = json.decode(response.body);
      //when there is no data, response body won't yield a map and it will return null
      //we need to write condition about response.body null
      final List<GroceryItem> loadItems = [];
      for (final item in listData.entries) {
        final category =
            categories.entries
                .firstWhere(
                  (catItem) => catItem.value.title == item.value['category'],
                )
                .value;
        loadItems.add(
          GroceryItem(
            id: item.key, //unique id that is provided by firebase
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }
      setState(() {
        _groceryItems = loadItems;
        _isLoading = false;
      });
    } catch (error) {
      _error = 'Something went wrong.Please try again later!';
    }
  }

  void _addedItem() async {
    // final newItem =
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem> //push is generic
    (MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });

    // if (newItem == null) {
    //   return;
    // }
    // setState(() {
    //   _groceryItems.add(newItem);
    // }); //using set State because we want use build method again
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https(
      'flutter-prep-e321a-default-rtdb.firebaseio/.com',
      'shopping-list/${item.id}.json',
    );
    //inject value into the string
    //just one item in the shopping list

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      //optional: show error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Center(
      child: const Text('No shopping items added yet!Please add some.'),
    );
    //managing the loading state
    if (_isLoading) {
      mainContent = const Center(child: CircularProgressIndicator());
    }

    if (_groceryItems.isNotEmpty) {
      mainContent = ListView.builder(
        itemBuilder:
            (ctx, index) => Dismissible(
              onDismissed: (direction) {
                _removeItem(_groceryItems[index]);
              },
              background: Container(
                // ignore: deprecated_member_use
                color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                margin: EdgeInsets.symmetric(
                  horizontal:
                      Theme.of(context).cardTheme.margin?.horizontal ?? 0,
                ),
              ),
              key: ValueKey(_groceryItems[index].id),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(_groceryItems[index].name),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: _groceryItems[index].category.color,
                  ),
                ),
              ),
            ),
        itemCount: _groceryItems.length,
      );
    }
    if (_error != null) {
      mainContent = Center(child: Text(_error!));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('GroceryList'),
        actions: [
          IconButton(onPressed: _addedItem, icon: const Icon(Icons.add)),
        ],
      ),
      body: mainContent,
    );
  }
}
