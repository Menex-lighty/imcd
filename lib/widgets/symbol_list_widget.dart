import 'package:flutter/material.dart';

class SymbolListWidget extends StatelessWidget {
  // Define a data structure for your symbols (replace with your actual data)
  static final List<Map<String, dynamic>> symbolDefinitions = [
    {'icon': Icons.warning, 'color': Colors.red, 'definition': 'Complaint'},
    {'icon': Icons.park, 'color': Colors.green, 'definition': 'Park'},
    {'icon': Icons.wc, 'color': Colors.blue, 'definition': 'Toilet'},
    // ... Add more symbols here
  ];

  SymbolListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symbol Definitions:',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10.0),
          ListView.builder(
            shrinkWrap: true, // Important to prevent infinite height in Column
            physics: const NeverScrollableScrollPhysics(), // Disable scrolling if not needed
            itemCount: symbolDefinitions.length,
            itemBuilder: (context, index) {
              final symbol = symbolDefinitions[index];
              return ListTile(
                leading: Icon(
                  symbol['icon'],
                  color: symbol['color'],
                  size: 28.0,
                ),
                title: Text(
                  symbol['definition'],
                  style: const TextStyle(fontSize: 16.0),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
