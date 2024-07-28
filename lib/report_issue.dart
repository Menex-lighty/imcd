import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
// You'll need to import your database and email service here
// import 'package:your_app/services/database_service.dart';
// import 'package:your_app/services/email_service.dart';

class ReportIssuePage extends StatefulWidget {
  @override
  _ReportIssuePageState createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends State<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _issueController = TextEditingController();
  File? _image;
  bool _needImmediateHelp = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save to your database
      // For example:
      // await DatabaseService.saveIssue({
      //   'name': _nameController.text,
      //   'contact': _contactController.text,
      //   'issue': _issueController.text,
      //   'imageUrl': _image?.path,
      //   'needImmediateHelp': _needImmediateHelp,
      // });

      if (_needImmediateHelp) {
        // Send email to responsible authority
        // For example:
        // await EmailService.sendUrgentHelpRequest(
        //   name: _nameController.text,
        //   contact: _contactController.text,
        //   issue: _issueController.text,
        // );
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Issue reported successfully')),
      );

      // Clear form
      _nameController.clear();
      _contactController.clear();
      _issueController.clear();
      setState(() {
        _image = null;
        _needImmediateHelp = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Report an Issue')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your contact number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _issueController,
                decoration: InputDecoration(labelText: 'Issue Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the issue';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Image'),
              ),
              if (_image != null) ...[
                SizedBox(height: 10),
                Image.file(_image!, height: 100),
              ],
              CheckboxListTile(
                title: Text('Do you need immediate help?'),
                value: _needImmediateHelp,
                onChanged: (bool? value) {
                  setState(() {
                    _needImmediateHelp = value ?? false;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _issueController.dispose();
    super.dispose();
  }
}