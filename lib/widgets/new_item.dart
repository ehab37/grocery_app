import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';
import 'package:shop/models/grocery_item.dart';
import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({Key? key}) : super(key: key);

  @override
  State<NewItem> createState() => _NewItemState();
}

class _NewItemState extends State<NewItem> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var groceryName = '';
  int quantity = 0;
  Category category = categories[Categories.fruit]!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Enter valid name';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: border(),
                  hintText: 'Enter Name of Grocery',
                ),
                onSaved: (newValue) {
                  groceryName = newValue!;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: '1',
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! < 1) {
                          return 'Enter valid Quantity';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: border(),
                        hintText: 'Quantity',
                      ),
                      onSaved: (newValue) {
                        quantity = int.parse(newValue!);
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: DropdownButtonFormField(
                      borderRadius: BorderRadius.circular(16),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select value';
                        }
                        return null;
                      },
                      hint: const Text('Select Category'),
                      items: categories.entries
                          .map((e) => DropdownMenuItem(
                              value: e.value,
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 8,
                                    backgroundColor: e.value.color,
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(e.value.name),
                                ],
                              )))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          category = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      _formKey.currentState!.validate();
                      _formKey.currentState!.save();
                      Uri uri = Uri.parse(
                          'https://mycare-18182-default-rtdb.firebaseio.com/shopping.json');
                      http.Response response = await http.post(
                        uri,
                        body: json.encode(
                          {
                            'name': groceryName,
                            'quantity': quantity,
                            'category': category.name,
                          },
                        ),
                        headers: {'Content-Type': 'application/json'},
                      );
                      if (response.statusCode == 200 ||
                          response.statusCode == 201) {
                        if (context.mounted) {
                          final Map<String, dynamic> decodedData =
                              json.decode(response.body);
                          Navigator.of(context).pop(
                            GroceryItem(
                              id: decodedData['name'],
                              name: groceryName,
                              quantity: quantity,
                              category: category,
                            ),
                          );
                        }
                      } else {
                        throw Exception('Failed to add data');
                      }
                    },
                    child: const Text('Add Item'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
    );
  }
}
