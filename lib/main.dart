import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gemini/flutter_gemini.dart';

const apiKey = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=GEMINI_API_KEY'; // Replace with your API key

void main() {
  Gemini.init(apiKey: apiKey); // Initialize Gemini
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini with Image Picker',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GeminiWithImage(),
    );
  }
}

class GeminiWithImage extends StatefulWidget {
  const GeminiWithImage({Key? key}) : super(key: key);

  @override
  State<GeminiWithImage> createState() => _GeminiWithImageState();
}

class _GeminiWithImageState extends State<GeminiWithImage> {
  String _output = "Press the button to interact with Gemini.";
  File? _selectedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _fetchResponse() async {
    if (_selectedImage == null) {
      setState(() => _output = "Please select an image first.");
      return;
    }

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final result = await Gemini.instance.textAndImage(
        text: "What does this image depict?",
        images: [bytes],
      );
      setState(() => _output = result?.content?.parts?.last.text ?? "No response received.");
    } catch (error) {
      setState(() => _output = "Error: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini with Image Picker')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (_selectedImage != null)
              Image.file(_selectedImage!, height: 200, width: 200)
            else
              const Text("No image selected"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _fetchResponse,
              child: const Text('Send to Gemini'),
            ),
            const SizedBox(height: 20),
            Text(
              _output,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
