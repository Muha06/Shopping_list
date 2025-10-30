import 'package:flutter/material.dart';
import 'package:shopping_list/models/grocery.dart';
import 'package:shopping_list/widgets/new_item.dart';


class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  void addItem() async {
    final addedItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );

    //specify what to be done if addedItem == null
    if (addedItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(addedItem);
    });
  }

  void _removeItem(GroceryItem item) {
    _groceryItems.remove(item);
  }

  @override
  Widget build(context) {
    Widget activeContent = ListView.builder(
      itemCount: _groceryItems.length,
      itemBuilder: (ctx, index) {
        return Dismissible(
          key: ValueKey(_groceryItems[index].id),
          background: Container(
            color: Colors.red,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(Icons.delete, color: Colors.white),
                SizedBox(width: 10),
                Text('delete', style: TextStyle(color: Colors.white)),
                SizedBox(width: 10),
              ],
            ),
          ),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Item deleted')));
          },
          child: ListTile(
            title: Text(_groceryItems[index].name.toString()),
            leading: Container(
              height: 15,
              width: 15,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(_groceryItems[index].quantity.toString()),
          ),
        );
      },
    );

    if (_groceryItems.isEmpty) {
      activeContent = const Center(child: Text('Nothing'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your groceries'),
        actions: [IconButton(onPressed: addItem, icon: const Icon(Icons.add))],
      ),
      body: activeContent,
    );
  }
}
