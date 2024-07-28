import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'report_issue.dart';
import 'add_asset.dart';

class ActiveVehiclesPage extends StatefulWidget {
  const ActiveVehiclesPage({Key? key}) : super(key: key);

  @override
  _ActiveVehiclesPageState createState() => _ActiveVehiclesPageState();
}

class _ActiveVehiclesPageState extends State<ActiveVehiclesPage> {
  List<FlSpot> fuelConsumedData = [
    FlSpot(0, 10),
    FlSpot(1, 15),
    FlSpot(2, 13),
    FlSpot(3, 17),
    FlSpot(4, 12),
  ];

  List<FlSpot> breakdownsData = [
    FlSpot(0, 2),
    FlSpot(1, 1),
    FlSpot(2, 3),
    FlSpot(3, 0),
    FlSpot(4, 2),
  ];

  List<FlSpot> complaintsData = [
    FlSpot(0, 5),
    FlSpot(1, 3),
    FlSpot(2, 7),
    FlSpot(3, 2),
    FlSpot(4, 4),
  ];

  List<Map<String, dynamic>> maintenanceSchedule = [
    {'vehicleId': '001', 'task': 'Tire Change', 'dueDate': DateTime.now().add(Duration(days: 30))},
    {'vehicleId': '002', 'task': 'Refuel', 'dueDate': DateTime.now().add(Duration(days: 2))},
    {'vehicleId': '003', 'task': 'Oil Change', 'dueDate': DateTime.now().add(Duration(days: 15))},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Vehicles'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vehicle Statistics', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 20),
              _buildLineChart('Fuel Consumed', fuelConsumedData, Colors.blue),
              SizedBox(height: 20),
              _buildLineChart('Number of Breakdowns', breakdownsData, Colors.red),
              SizedBox(height: 20),
              _buildLineChart('Complaints in Past Month', complaintsData, Colors.orange),
              SizedBox(height: 40),
              Text('Maintenance Schedule', style: Theme.of(context).textTheme.titleLarge),
              SizedBox(height: 20),
              _buildMaintenanceSchedule(),
              SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ReportIssuePage()),
                      );
                    },
                    child: Text('Report an Issue'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddAssetPage()),
                      );
                    },
                    child: Text('Add New Asset'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLineChart(String title, List<FlSpot> spots, Color color) {
    return Container(
      height: 200,
      child: Column(
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: true),
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY: 20,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceSchedule() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: maintenanceSchedule.length,
      itemBuilder: (context, index) {
        final item = maintenanceSchedule[index];
        return ListTile(
          title: Text('Vehicle ${item['vehicleId']}: ${item['task']}'),
          subtitle: Text('Due: ${DateFormat('yyyy-MM-dd').format(item['dueDate'])}'),
          trailing: Icon(Icons.calendar_today),
        );
      },
    );
  }
}