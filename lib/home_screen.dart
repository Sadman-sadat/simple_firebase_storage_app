import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  List<String> storedImages = [];
  XFile? pickedImage;

  Future<void> _getImagesFromStorage() async {
    final storageRef = _firebaseStorage.ref().child('images');
    final listResult = await storageRef.listAll();
    storedImages = await Future.wait(
      listResult.items.map((ref) => ref.getDownloadURL()).toList(),
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getImagesFromStorage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gallery')),
      body: GridView.builder(
        itemCount: storedImages.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
        ),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 100,
              width: 100,
              color: Colors.deepPurpleAccent,
              child: Image.network(storedImages[index]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera_alt_outlined),
        onPressed: () {
          _pickImageFromGalleryAndCamera();
        },
      ),
    );
  }

  Future<void> _pickImageFromGalleryAndCamera() async {
    final ImagePicker imagePicker = ImagePicker();
    XFile? pickedImage =
    await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      await _uploadImageToFirebase(imageFile);
      _getImagesFromStorage();
    }
  }

  Future<void> _uploadImageToFirebase(File imageFile) async {
    final storageRef = FirebaseStorage.instance.ref().child('images/${imageFile.path.split('/').last}');
    await storageRef.putFile(imageFile);
  }
}