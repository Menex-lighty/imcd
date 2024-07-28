import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class UserHomePage extends StatefulWidget {
  static String id = '/UserHomePage';

  const UserHomePage({super.key});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedComplaintType;
  String? _additionalInfo;
  LatLng? _selectedLocation;
  XFile? _image;

  final List<String> _complaintTypes = [
    'Vehicles',
    'Garbage',
    'Park',
    'Road',
    'Street Light',
    'Water Supply',
    'Other'
  ];

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = image;
      });
    }
  }

  void _selectLocation() async {
    final LatLng? result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LocationSelectionMap(
          initialLocation: LatLng(22.7196, 75.8577), // Default to Indore
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
      });
    }
  }

  void _submitComplaint() {
    if (_formKey.currentState!.validate()) {
      // Process and submit the complaint
      // You would typically send this data to your backend
      print('Complaint submitted:');
      print('Type: $_selectedComplaintType');
      print('Location: $_selectedLocation');
      print('Additional Info: $_additionalInfo');
      print('Image: ${_image?.path}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Home Page'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Complaint Type:'),
              DropdownButtonFormField<String>(
                value: _selectedComplaintType,
                items: _complaintTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedComplaintType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a complaint type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectLocation,
                child: Text('Select Location on Map'),
              ),
              if (_selectedLocation != null)
                Text('Location selected: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Take a Photo'),
              ),
              if (_image != null)
                Text('Image captured: ${_image!.path}'),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Additional Information',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _additionalInfo = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitComplaint,
                child: Text('Submit Complaint'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationSelectionMap extends StatefulWidget {
  final LatLng initialLocation;

  LocationSelectionMap({required this.initialLocation});

  @override
  _LocationSelectionMapState createState() => _LocationSelectionMapState();
}

class _LocationSelectionMapState extends State<LocationSelectionMap> {
  late GoogleMapController mapController;
  LatLng? _selectedLocation;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: widget.initialLocation,
              zoom: 14.0,
            ),
            onTap: (LatLng location) {
              setState(() {
                _selectedLocation = location;
              });
            },
            markers: _selectedLocation != null
                ? {
              Marker(
                markerId: MarkerId('selected_location'),
                position: _selectedLocation!,
              ),
            }
                : {},
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: _selectedLocation != null
                  ? () {
                Navigator.of(context).pop(_selectedLocation);
              }
                  : null,
              child: Text('Confirm Location'),
            ),
          ),
        ],
      ),
    );
  }
}
