import 'package:flutter/material.dart';
import 'package:shop/widgets/grocery_list.dart';

void main() {
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        useMaterial3: true,
        bottomSheetTheme: const BottomSheetThemeData()
            .copyWith(backgroundColor: Colors.black12),
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 118, 15, 159),
          surface: const Color.fromARGB(104, 0, 0, 0),
        ),
      ),
      home: const GroceryList(),
    );
  }
}
