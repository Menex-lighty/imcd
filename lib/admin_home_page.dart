import 'package:flutter/material.dart';
import 'widgets/map_widget.dart';
import 'widgets/symbol_list_widget.dart';
import 'widgets/counter_widget.dart';
import 'complaint_page.dart';
import 'active_vehicles_page.dart'; // Add this import

class AdminHomePage extends StatelessWidget {
  static String id = '/AdminHomePage';

  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Home Page')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const MapWidget(),
            SymbolListWidget(),
            CounterWidget(
              title: 'Active Vehicles',
              count: 5332,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActiveVehiclesPage()),
                );
              },
            ),
            CounterWidget(
              title: 'Parks Running',
              count: 300,
              onTap: () {
                // Navigate to parks page
              },
            ),
            CounterWidget(
              title: 'Working Toilets',
              count: 465,
              onTap: () {
                // Navigate to toilets page
              },
            ),
            // Add more CounterWidgets for other metrics
            SizedBox(height: 20), // Add some spacing
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ComplaintPage()),
                );
              },
              child: Text('Lodge a Complaint'),
            ),
          ],
        ),
      ),
    );
  }
}