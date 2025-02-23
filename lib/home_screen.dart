import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatelessWidget {
  final String userId;

  HomeScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Profile"),
        centerTitle: true,),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("users").doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("User not found"));
          }

          var userData = snapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userData["profileImageUrl"].isNotEmpty
                      ? NetworkImage(userData["profileImageUrl"])
                      : null,
                  child: userData["profileImageUrl"].isEmpty ? Icon(Icons.person, size: 50) : null,
                ),
                SizedBox(height: 10),
                Text("Name: ${userData["name"]}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("Email: ${userData["email"]}", style: TextStyle(fontSize: 16)),
                Text("Mobile: ${userData["mobile"]}", style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}
