import 'package:flutter/material.dart';

class AddAssetPage extends StatefulWidget {
  @override
  _AddAssetPageState createState() => _AddAssetPageState();
}

class _AddAssetPageState extends State<AddAssetPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedAssetType = 'Vehicular';

  // Controllers for common fields
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();

  // Controllers for vehicle-specific fields
  final _categoryController = TextEditingController();
  final _licenseNumberController = TextEditingController();

  // Controllers for park-specific fields
  bool _isOnLease = false;
  final _societyNameController = TextEditingController();

  // Controllers for building-specific fields
  // Add more controllers as needed for building fields

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Asset')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedAssetType,
                decoration: InputDecoration(labelText: 'Asset Type'),
                items: ['Vehicular', 'Park', 'Building', 'Road', 'Monument']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedAssetType = newValue!;
                  });
                },
              ),
              SizedBox(height: 20),
              _buildDynamicFields(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Add Asset'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicFields() {
    switch (_selectedAssetType) {
      case 'Vehicular':
        return Column(
          children: [
            TextFormField(
              controller: _categoryController,
              decoration: InputDecoration(labelText: 'Category (e.g., Police Car, Garbage Truck)'),
              validator: (value) => value!.isEmpty ? 'Please enter a category' : null,
            ),
            TextFormField(
              controller: _licenseNumberController,
              decoration: InputDecoration(labelText: 'License Number'),
              validator: (value) => value!.isEmpty ? 'Please enter a license number' : null,
            ),
          ],
        );
      case 'Park':
        return Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Park Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a park name' : null,
            ),
            SwitchListTile(
              title: Text('On Lease'),
              value: _isOnLease,
              onChanged: (bool value) {
                setState(() {
                  _isOnLease = value;
                });
              },
            ),
            if (_isOnLease)
              TextFormField(
                controller: _societyNameController,
                decoration: InputDecoration(labelText: 'Society Name'),
                validator: (value) => value!.isEmpty ? 'Please enter the society name' : null,
              ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
              validator: (value) => value!.isEmpty ? 'Please enter the location' : null,
            ),
          ],
        );
      case 'Building':
      // Add fields for building
        return Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Building Name'),
              validator: (value) => value!.isEmpty ? 'Please enter a building name' : null,
            ),
            TextFormField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Location'),
              validator: (value) => value!.isEmpty ? 'Please enter the location' : null,
            ),
            // Add more fields specific to buildings
          ],
        );
    // Add cases for 'Road' and 'Monument' as needed
      default:
        return Container();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save to your database
      // For example:
      // await DatabaseService.addAsset({
      //   'type': _selectedAssetType,
      //   'name': _nameController.text,
      //   'location': _locationController.text,
      //   // Add other fields based on the asset type
      // });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Asset added successfully')),
      );

      // Clear form
      _formKey.currentState!.reset();
      _nameController.clear();
      _locationController.clear();
      _categoryController.clear();
      _licenseNumberController.clear();
      _societyNameController.clear();
      setState(() {
        _isOnLease = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _categoryController.dispose();
    _licenseNumberController.dispose();
    _societyNameController.dispose();
    super.dispose();
  }
}