import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_project/theme/app_colors.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

// add firestore
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _SearchPageState extends State<SearchPage> {

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      // 1. get post collection
  body: StreamBuilder(
  stream: _firestore.collection("posts").snapshots(),
  builder: (builder, Snapshot) {
    if (Snapshot.connectionState == ConnectionState.waiting) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (!Snapshot.hasData || Snapshot.data!.docs.isEmpty) {
      return const Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_rounded,
              color: grey,
            ),
            Text(
              "No Posts Yet",
              style: TextStyle(color: grey),
            ),
          ],
        ),
      );
    }
    return GridView.builder(
      itemCount: Snapshot.data!.docs.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemBuilder: (context, index) {
        DocumentSnapshot post = Snapshot.data!.docs[index];
        return Image.network(
          post["imageUrl"],
          fit: BoxFit.cover,
        );
      },
    );
  },
),
    );
  }
}