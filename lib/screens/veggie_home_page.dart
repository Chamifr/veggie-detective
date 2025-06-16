import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/classifier_service.dart';

class VeggieHomePage extends StatefulWidget {
  @override
  _VeggieHomePageState createState() => _VeggieHomePageState();
}

class _VeggieHomePageState extends State<VeggieHomePage> {
  File? _image;
  String _resultText = 'Result Preview';
  final picker = ImagePicker();
  
  late ClassifierService _classifierService;

  @override
  void initState() {
    super.initState();
    _classifierService = ClassifierService();
    _classifierService.loadModelAndLabels(context);
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _resultText = 'Processing...';
      });

      final result = await _classifierService.classifyImage(imageFile);

      setState(() {
        _resultText = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFDFF5D6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
              child: Column(
                children: [
                  Text(
                    'Veggie Detective',
                    style: GoogleFonts.itim(
                      fontSize: screenW * 0.07,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black26,
                          offset: Offset(1.5, 1.5),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenH * 0.04),
                  Container(
                    width: screenW * 0.5,
                    height: screenW * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    child: _image == null
                        ? Center(
                            child: Text(
                              'Image Preview',
                              style: GoogleFonts.nunito(fontSize: screenW * 0.035),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.file(_image!, fit: BoxFit.cover),
                          ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _resultText,
                    style: GoogleFonts.itim(
                      fontSize: screenW * 0.035,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: screenH * 0.05),
                  Wrap(
                    spacing: 30,
                    runSpacing: 30,
                    alignment: WrapAlignment.center,
                    children: [
                      CustomIconButton(
                        imagePath: 'assets/camera_logo.png',
                        label: 'Take Photo',
                        onTap: () => _pickImage(ImageSource.camera),
                        width: screenW * 0.3,
                      ),
                      CustomIconButton(
                        imagePath: 'assets/file_selection_logo.png',
                        label: 'Choose File',
                        onTap: () => _pickImage(ImageSource.gallery),
                        width: screenW * 0.3,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;
  final double width;

  const CustomIconButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: width,
            height: width,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Image.asset(imagePath, fit: BoxFit.contain),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.itim(
              fontSize: width * 0.15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
