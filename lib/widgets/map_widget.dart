import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'symbol_list_widget.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({super.key});
  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  final apiKey = 'sk.eyJ1Ijoia2luZ2lzaGFudHMyNTI1IiwiYSI6ImNseWUydzVrazA5MWMycXM2cnRyY3VrNjUifQ.U-2AA0JZhBxn2g0T9hGmMA';

  @override
  void initState() {
    super.initState();
    _fetchStores();
  }

  void _fetchStores() async {
    // Example placeholder data for stores
    List<Map<String, dynamic>> stores = [
      {'center': [75.8577, 22.7196], 'type': 'Complaint'},
      {'center': [75.8600, 22.7200], 'type': 'Park'},
      {'center': [75.8625, 22.7210], 'type': 'Toilet'},
    ];

    setState(() {
      _markers = stores.map((store) {
        final LatLng location = LatLng(store['center'][1], store['center'][0]);
        final String storeType = store['type'];
        // Get icon and color from SymbolListWidget
        final matchingSymbol = SymbolListWidget.symbolDefinitions.firstWhere(
              (symbol) => symbol['definition'] == storeType,
          orElse: () => {'icon': Icons.store, 'color': Colors.grey},
        );
        return Marker(
          point: location,
          width: 80.0,
          height: 80.0,
          child: GestureDetector(
            onTap: () => _openURL(location),
            child: Icon(
              matchingSymbol['icon'],
              size: 40.0,
              color: matchingSymbol['color'],
            ),
          ),
        );
      }).toList();
    });
  }

  void _openURL(LatLng location) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400, // Adjust height as needed
      child: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: LatLng(22.7196, 75.8577), // Example: Indore coordinates
          initialZoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://api.mapbox.com/styles/v1/{id}/tiles/{z}/{x}/{y}?access_token=$apiKey',
            additionalOptions: const {
              'id': 'mapbox/streets-v11', // Adjust to your preferred Mapbox style
            },
            userAgentPackageName: 'YOUR_PACKAGE_NAME',  // Replace with your actual package name
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
    );
  }
}