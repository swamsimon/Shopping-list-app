import 'package:flutter/material.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:shopping_list/models/grocery_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void _addedItem() async {
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem> //push is generic
    (MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    }); //using set State because we want use build method again
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget mainContent = Center(
      child: const Text('No shopping items added yet!Please add some.'),
    );

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
