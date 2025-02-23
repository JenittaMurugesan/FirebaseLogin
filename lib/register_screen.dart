import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  File? _image;
  bool isLoading = false;
  String? errorMessage = "";

  Future<void> pickImage() async {
    final pickedFile =
    await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _image = File(pickedFile.path));
    }
  }

  Future<void> register() async {
    if (passwordController.text != confirmPasswordController.text) {
      setState(() => errorMessage = "Passwords do not match");
      return;
    }

    // setState(() => isLoading = true);

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      String? profileImageUrl;

      if (_image != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref("profile_pictures/${userCredential.user!.uid}.jpg");
        await storageRef.putFile(_image!);
        profileImageUrl = await storageRef.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
        "uid": userCredential.user!.uid,
        "name": nameController.text,
        "email": emailController.text.trim(),
        "mobile": mobileController.text.trim(),
        "profileImageUrl": profileImageUrl ?? "",
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => HomeScreen(userId: userCredential.user!.uid)),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
                    child: _image == null
                        ? Icon(Icons.camera_alt, size: 50)
                        : null,
                  ),
                ),
                SizedBox(height: 28),
                TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        labelText: "Name")),
                SizedBox(height: 16),

                TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        labelText: "Email")),
                SizedBox(height: 16),

                TextField(
                    controller: mobileController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        labelText: "Mobile")),
                SizedBox(height: 16),

                TextField(
                    controller: passwordController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        labelText: "Password"),
                    obscureText: true),
                SizedBox(height: 16),

                TextField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24)),
                        labelText: "Confirm Password"),
                    obscureText: true),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                  Text(errorMessage!, style: TextStyle(color: Colors.red)),
                ),
                SizedBox(height: 20),
                isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  style: ButtonStyle(backgroundColor:  MaterialStateProperty.all(Colors.blue),),
                  onPressed: register,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Register",style: TextStyle(color: Colors.white,fontSize: 18),),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
