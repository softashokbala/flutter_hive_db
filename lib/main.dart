import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("shopping_box");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Hive',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();

  List<Map<String, dynamic>> _item = [];
  final _shoppingBox = Hive.box("shopping_box");

  @override
  void initState() {
    _refreshItems();
    super.initState();
  }

  void _refreshItems() {
    final data = _shoppingBox.keys.map((key) {
      final item = _shoppingBox.get(key);
      return {"key": key, "name": item["name"], "quantity": item['quantity']};
    }).toList();

    setState(() {
      _item = data.reversed.toList();
      print(_item.length);
    });
  }

  Future<void> _createItem(Map<String, dynamic> newItem) async {
    await _shoppingBox.add(newItem);
    print("Amount data is ${_shoppingBox.length}");
    _refreshItems();
  }

  Future<void> _updateItem(int itemkey, Map<String, dynamic> item) async {
    await _shoppingBox.put(itemkey, item);
    print("Amount data is ${_shoppingBox.length}");
    _refreshItems();
  }

  Future<void> _deleteItem(int itemkey) async {
    await _shoppingBox.delete(itemkey);
    print("Amount data is ${_shoppingBox.length}");
    _refreshItems();
  }

  void _showForm(BuildContext ctx, int? itemkey) async {
    var key = _item.asMap().containsKey(itemkey);

    if (itemkey != null) {
      final existingItem =
          _item.firstWhere((element) => element['key'] == itemkey);
      _nameController.text = existingItem['name'];
      _quantityController.text = existingItem['quantity'];
    }

    showModalBottomSheet(
      context: ctx,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 15,
            left: 15,
            right: 15),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(hintText: "Name"),
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Quantity"),
              ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () async {
                    if (itemkey != null) {
                      _updateItem(itemkey, {
                        "name": _nameController.text,
                        "quantity": _quantityController.text
                      });
                    } else {
                      _createItem({
                        "name": _nameController.text,
                        "quantity": _quantityController.text
                      });
                    }

                    //clear the text fields
                    _nameController.clear();
                    _quantityController.clear();
                  },
                  child: Text(itemkey == null ? "Create New" : "Update")),
              const SizedBox(
                height: 10,
              ),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: _item.length,
        itemBuilder: (context, index) {
          final currentItem = _item[index];
          return Card(
            color: Colors.orange.shade100,
            margin: const EdgeInsets.all(10),
            elevation: 3,
            child: ListTile(
              title: Text(currentItem['name']),
              subtitle: Text(currentItem['quantity'].toString()),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(
                    onPressed: () => _showForm(context, currentItem['key']),
                    icon: const Icon(Icons.edit)),
                IconButton(
                    onPressed: () => _deleteItem(currentItem['key']),
                    icon: const Icon(Icons.delete))
              ]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, null),
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
