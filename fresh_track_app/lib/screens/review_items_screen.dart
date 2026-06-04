import 'package:flutter/material.dart';
import '../models/food_item.dart';

class ReviewItemsScreen extends StatefulWidget {
  final List<String> scannedNames;
  final DateTime initialDate;

  const ReviewItemsScreen({super.key, required this.scannedNames, required this.initialDate});

  @override
  State<ReviewItemsScreen> createState() => _ReviewItemsScreenState();
}

class _ReviewItemsScreenState extends State<ReviewItemsScreen> {
  late List<Map<String, dynamic>> _itemsToReview;

  @override
  void initState() {
    super.initState();
    _itemsToReview = widget.scannedNames.map((name) => {'name': name, 'selected': true}).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Scanned Items")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _itemsToReview.length,
              itemBuilder: (context, i) => CheckboxListTile(
                title: Text(_itemsToReview[i]['name']),
                value: _itemsToReview[i]['selected'],
                onChanged: (val) => setState(() => _itemsToReview[i]['selected'] = val),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                final selected = _itemsToReview
                    .where((item) => item['selected'])
                    .map((item) => item['name'] as String)
                    .toList();
                Navigator.pop(context, selected);
              },
              child: const Text("Add Selected Items"),
            ),
          )
        ],
      ),
    );
  }
}