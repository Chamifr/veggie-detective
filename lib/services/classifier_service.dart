import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:veggie_detective/data/label_name.dart';
import '../data/nutrition.dart';

class ClassifierService {
  late Interpreter _interpreter;
  List<String> _labels = [];

  Future<void> loadModelAndLabels(BuildContext context) async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/model_unquant.tflite');
      final labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
      print("✅ Labels loaded: $_labels (${_labels.length})");
    } catch (e) {
      print("❌ Error loading model or labels: $e");
    }
  }

  Future<String> classifyImage(File image) async {
    final rawBytes = await image.readAsBytes();
    img.Image? oriImage = img.decodeImage(rawBytes);
    if (oriImage == null) return "Image error";

    img.Image resizedImage = img.copyResize(oriImage, width: 224, height: 224);
    var input = Float32List(1 * 224 * 224 * 3);
    var buffer = input.buffer.asFloat32List();

    int pixelIndex = 0;
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resizedImage.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0;
        buffer[pixelIndex++] = pixel.b / 255.0;
      }
    }

    var output = List.filled(_labels.length, 0.0).reshape([1, _labels.length]);
    _interpreter.run(input.buffer.asUint8List(), output);

    double highestProb = 0.0;
    int predictedIndex = 0;
    double secondHighest = 0.0;

    for (int i = 0; i < _labels.length; i++) {
      double prob = output[0][i];
      if (prob > highestProb) {
        secondHighest = highestProb;
        highestProb = prob;
        predictedIndex = i;
      } else if (prob > secondHighest) {
        secondHighest = prob;
      }
    }

    // Create list of label-confidence pairs
    List<double> confidences = List<double>.from(output[0]);
    List<MapEntry<String, double>> predictions = List.generate(
      _labels.length,
      (index) => MapEntry(_labels[index], confidences[index]),
    );

    // Sort descending by confidence
    predictions.sort((a, b) => b.value.compareTo(a.value));

    // Top 3 predictions
    final top3 = predictions.take(3).toList();
    String formattedTop3 = top3
        .map((entry) =>
            "${entry.key}: ${(entry.value * 100).toStringAsFixed(2)}%")
        .join('\n');

    // Check if top prediction is confident enough
    bool isConfident = top3[0].value >= 0.9 &&
        (top3[0].value - top3[1].value) >= 0.15;

    if (!isConfident) {
      return "Unknown object.\n\nPredictions Confidence:\n$formattedTop3";
    } else {
      String fruit = top3[0].key;
      String info = nutritionInfo[fruit] ?? "$fruit\nNo nutritional info available.";
      String label_name = labelName[fruit] ?? "$fruit\nNo nutritional info available.";
      return "$label_name\n\nPrediction Confidence:\n$formattedTop3\n\nNutritional Info:\n$info";
    }
  }
}
