import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool isLoading = true;

  void addItem() async {
    final item = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) {
          return const NewItem();
        },
      ),
    );
    if (item == null) {
      return;
    }
    setState(() {
      _groceryItems.add(item);
    });
  }

  void _getItems() async {
    final url = Uri.https(
      'shopping-list-aee6e-default-rtdb.firebaseio.com',
      'shopping-list.json', //a folder/collection in our db
    );
    final response = await http.get(url);
    //decoding all grocery item in the db
    //listData = response => all groceryItems in the db
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> temporaryItems = [];
    for (final item in listData.entries) {
      //finding category matching to the one from our db
      final category = categories.values.firstWhere((element) {
        return element.title == item.value['category'];
      });
      //add every groceryItem from db to a temporary list
      temporaryItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    //reassigning oldlist to new so we ui rebuilds
    setState(() {
      _groceryItems = temporaryItems;
      isLoading = false;
    });
  }

  @override
  void initState() {
    _getItems();
    super.initState();
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

    if (isLoading) {
      activeContent = Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );
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
