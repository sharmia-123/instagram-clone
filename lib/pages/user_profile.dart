import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_project/pages/edit_profile.dart';
import 'package:instagram_clone_project/theme/app_colors.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _UserProfileState extends State<UserProfile> {

  // get user
  Future<DocumentSnapshot> getUser() async {
    String uid = _auth.currentUser!.uid;

    DocumentSnapshot documentSnapshot =
        await _firestore.collection("users").doc(uid).get();

    return documentSnapshot;
  }

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  // user details
  String username = "";
  String bio = "";
  String? profilePhoto;
  int followers = 0;
  int following = 0;

  // load user
  Future<void> loadUser() async {
    DocumentSnapshot documentSnapshot = await getUser();

    setState(() {
      username = documentSnapshot["username"];
      followers = documentSnapshot["followers"];
      following = documentSnapshot["following"];
      bio = documentSnapshot["bio"];
      profilePhoto = documentSnapshot["profilePhoto"];
    });
  }

  @override
  Widget build(BuildContext context) {

    String uid = _auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: black,

      body: Padding(
        padding: const EdgeInsets.only(top: 20.0),

        child: Column(
          children: [

            // Profile photo
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: grey,
                shape: BoxShape.circle,
              ),
              child: profilePhoto != null && profilePhoto!.isNotEmpty
                  ? ClipOval(
                      child: Image.network(
                        profilePhoto!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: white,
                    ),
            ),

            const SizedBox(height: 10.0),

            // Username
            Text(
              username,
              style: const TextStyle(
                fontSize: 18,
                color: white,
              ),
            ),

            // Bio
            Text(
              bio,
              style: const TextStyle(
                fontSize: 13,
                color: white,
              ),
            ),

            const SizedBox(height: 10.0),

            // User information
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Column(
                  children: [
                    const Text(
                      "Followers",
                      style: TextStyle(
                        color: white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      followers.toString(),
                      style: const TextStyle(
                        color: white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 15.0),

                Column(
                  children: [
                    const Text(
                      "Following",
                      style: TextStyle(
                        color: white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      following.toString(),
                      style: const TextStyle(
                        color: white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 15.0),

                // Posts count
                StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection("posts")
                      .where("userId", isEqualTo: uid)
                      .snapshots(),

                  builder: (context, snapshot) {

                    int postCount = 0;

                    if (snapshot.hasData) {
                      postCount = snapshot.data!.docs.length;
                    }

                    return Column(
                      children: [
                        const Text(
                          "Posts",
                          style: TextStyle(
                            color: white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          postCount.toString(),
                          style: const TextStyle(
                            color: white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 10.0),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: white,
                    minimumSize: const Size(120, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfile(),
                      ),
                    );
                  },
                  child: const Text("Edit Profile"),
                ),

                const SizedBox(width: 15.0),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: white,
                    minimumSize: const Size(120, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  onPressed: () {},
                  child: const Text("Log Out"),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // User posts
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection("posts")
                    .where("userId", isEqualTo: uid)
                    .snapshots(),

                builder: (context, snapshot) {

                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Icon(
                            Icons.camera_alt_rounded,
                            color: grey,
                            size: 40,
                          ),

                          SizedBox(height: 10),

                          Text(
                            "No Posts Yet",
                            style: TextStyle(
                              color: grey,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    itemCount: snapshot.data!.docs.length,

                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),

                    itemBuilder: (context, index) {

                      DocumentSnapshot post =
                          snapshot.data!.docs[index];

                      return Image.network(
                        post["imageUrl"],
                        fit: BoxFit.cover,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

