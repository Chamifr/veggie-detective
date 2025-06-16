import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/classifier_service.dart';


class FruitClassifierPage extends StatefulWidget {
  @override
  _FruitClassifierPageState createState() => _FruitClassifierPageState();
}

class _FruitClassifierPageState extends State<FruitClassifierPage> {
  File? _image;
  final picker = ImagePicker();
  final ClassifierService _classifierService = ClassifierService();
  String _prediction = '';

  @override
  void initState() {
    super.initState();
    _classifierService.loadModelAndLabels(context);
  }

  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      final prediction = await _classifierService.classifyImage(_image!);
      setState(() {
        _prediction = prediction;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Veggie Detective')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _image != null
                ? Image.file(_image!, height: 200)
                : Text('No image selected'),
            SizedBox(height: 20),
            Text('Prediction: $_prediction', style: TextStyle(fontSize: 18)),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.gallery),
              child: Text('Pick from Gallery'),
            ),
            ElevatedButton(
              onPressed: () => pickImage(ImageSource.camera),
              child: Text('Take a Picture'),
            ),
          ],
        ),
      ),
    );
  }
}
