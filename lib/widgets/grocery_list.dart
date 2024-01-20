import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/grocery_item.dart';
import 'package:shop/widgets/new_item.dart';
import 'package:http/http.dart' as http;

import '../models/category.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryList = [];
  void _loadData() async {
    Uri uri = Uri.parse(
        'https://mycare-18182-default-rtdb.firebaseio.com/shopping.json');
    final http.Response response = await http.get(uri);
    final Map<String, dynamic> data = json.decode(response.body);
    final List<GroceryItem> decodedItems = [];

    for (var item in data.entries) {
      final Category category = categories.entries
          .firstWhere(
            (element) => element.value.name == item.value['category'],
          )
          .value;
      decodedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
      setState(() {
        _groceryList = decodedItems;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Grocery'),
          actions: [
            IconButton(
                onPressed: () async {
                  final newItem = await Navigator.of(context).push<GroceryItem>(
                    MaterialPageRoute(
                      builder: (context) {
                        return const NewItem();
                      },
                    ),
                  );
                  if (newItem != null) {
                    setState(() {
                      _groceryList.add(newItem);
                    });
                  }
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: _groceryList.isEmpty
            ? const Center(
                child: Text('No Item Added Yet'),
              )
            : ListView.builder(
                itemCount: _groceryList.length,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(_groceryList[index].id),
                    onDismissed: (_) {
                      removeItem(_groceryList[index]);
                    },
                    child: ListTile(
                      title: Text(_groceryList[index].name),
                      leading: CircleAvatar(
                        radius: 12,
                        backgroundColor: _groceryList[index].category.color,
                      ),
                      trailing: Text(
                        _groceryList[index].quantity.toString(),
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void removeItem(GroceryItem item) async {
    final index = _groceryList.indexOf(item);
    setState(() {
      _groceryList.remove(item);
    });
    Uri uri = Uri.parse(
        'https://mycare-18182-defult-rtdb.firebaseio.com/shopping/${item.id}.json');
    http.Response response = await http.delete(uri);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryList.insert(index, item);
      });
    }
  }
}
