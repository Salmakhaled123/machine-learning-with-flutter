import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tensorflow_lite_flutter/tensorflow_lite_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'image recognition',
      home: MachineLearningApp(),
    );
  }
}

class MachineLearningApp extends StatefulWidget {
  const MachineLearningApp({Key? key}) : super(key: key);

  @override
  State<MachineLearningApp> createState() => _MachineLearningAppState();
}

class _MachineLearningAppState extends State<MachineLearningApp> {
  ImagePicker imagePicker = ImagePicker();
  XFile? image;
  var data;
  @override
  void initState() {
    loadModel();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.image),
          onPressed: () async {
            await pickImage();
            if (image != null) {
              data = await Tflite.runModelOnImage(path: image!.path);
              print(data);
              print(getLabels(data));
            }
            setState(() {});
          }),
      appBar: AppBar(
        title: const Text('MachineLearningApp'),
      ),
      body: image == null
          ? Container()
          : Column(
              children: [
                Image.file(File(image!.path)),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  getLabels(data).toString(),
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ],
            ),
    );
  }

  loadModel() async {
    await Tflite.loadModel(
      model: 'assets/model_unquant.tflite',
      labels: 'assets/labels.txt',
    );
  }

  pickImage() async {
    var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = pickedImage;
    });
  }

  List<dynamic> getLabels(List<dynamic> objects) {
    setState(() {});
    return objects
        .map((object) => object['label'].split(' ').sublist(1).join(' '))
        .toList();
  }
}
