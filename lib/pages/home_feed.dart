import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone_project/theme/app_colors.dart';
// animation for like button
import 'package:like_button/like_button.dart';

class HomeFeed extends StatefulWidget {
  const HomeFeed({super.key});

  @override
  State<HomeFeed> createState() => _HomeFeedState();
}

// addd firestore
final FirebaseFirestore _firestore = FirebaseFirestore.instance;
// auth
final FirebaseAuth _auth = FirebaseAuth.instance;
class _HomeFeedState extends State<HomeFeed> {

  // get user
  Future<DocumentSnapshot> getUser() async
  {
    String uid = _auth.currentUser!.uid;

   DocumentSnapshot documentSnapshot = await _firestore.collection("users").doc(uid).get();
   return documentSnapshot;
  }
  @override
  void initState()
  {
    super.initState();
    loadUser();
  }
  // user
  String username = "";
  String profilePhoto = "";
  // load user
  Future<void> loadUser() async
  {
    DocumentSnapshot documentSnapshot = await getUser();

    setState(() {
      username = documentSnapshot["username"];
      profilePhoto = documentSnapshot["profilePhoto"];
    });
  }
  // like img
  Future<bool> handleLike(String postId, bool isLiked) async {
  String uid = _auth.currentUser!.uid;

  DocumentReference likeRef = _firestore
      .collection("posts")
      .doc(postId)
      .collection("likes")
      .doc(uid);

  if (isLiked) {
    await likeRef.delete();
  } else {
    await likeRef.set({
      "userId": uid,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  return !isLiked;
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Instgram", style: GoogleFonts.satisfy(fontSize: 30, fontWeight: FontWeight.w500, color: white),),
        backgroundColor: black,
        centerTitle: true,
      ),
      backgroundColor: black,
      body: StreamBuilder(stream: _firestore.collection("posts").snapshots(), builder: (context, snapshot)
      {
        if(snapshot.connectionState == ConnectionState.waiting)
        {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if(!snapshot.hasData  || snapshot.data!.docs.isEmpty)
        {
          return const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_rounded, color: grey,),
                Text("No Posts Yet", style: TextStyle(color: grey,),),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {

    DocumentSnapshot post = snapshot.data!.docs[index];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Username + profile photo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [

                CircleAvatar(
                  radius: 20,
                  backgroundImage:
                      post["profilePhoto"] != null &&
                              post["profilePhoto"] != ""
                          ? NetworkImage(post["profilePhoto"])
                          : null,
                  child:
                      post["profilePhoto"] == null ||
                              post["profilePhoto"] == ""
                          ? const Icon(Icons.person)
                          : null,
                ),

                const SizedBox(width: 10),

                Text(
                  post["username"],
                  style: const TextStyle(
                    color: white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Delete Post?"),
                          content: const Text(
                            "Are you sure you want to delete this post?",
                            ),
                            actions: [
                              TextButton(onPressed: () {
                                Navigator.pop(context);
                                },
                                child: const Text("Cancel"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await _firestore
                                    .collection("posts").doc(post.id).delete();Navigator.pop(context);},
                                    child: const Text("Delete"),),
                                    ],
                                  );
                                },
                              );
                            },
                    icon: const Icon(
                    Icons.more_vert,
                    color: white,
                ),
              ),         
             ],
            ),
          ),
          const SizedBox(height: 10),
          // Post image
          Image.network(
            post["imageUrl"],
            width: double.infinity,
            height: 350,
            fit: BoxFit.cover,
          ),
          // Like + comment 
          Column(
            children: [
              Row(
            children: [
              // IconButton(
              //   onPressed: () {},
              //   icon: const Icon(
              //     Icons.favorite_border,
              //     color: white,
              //   ),
              // ),
              StreamBuilder<QuerySnapshot>(
  stream: _firestore
      .collection("posts")
      .doc(post.id)
      .collection("likes")
      .snapshots(),
  builder: (context, likeSnapshot) {
    if (!likeSnapshot.hasData) {
      return LikeButton(
        size: 30,
        likeCount: 0,
        likeBuilder: (bool isLiked) {
          return Icon(
            CupertinoIcons.heart_fill,
            color: isLiked ? Colors.red : Colors.white,
          );
        },
      );
    }

    String uid = _auth.currentUser!.uid;

    bool isLiked = likeSnapshot.data!.docs
        .any((like) => like.id == uid);

    int likeCount = likeSnapshot.data!.docs.length;

    return LikeButton(
      size: 30,
      isLiked: isLiked,
      likeCount: likeCount,
      onTap: (currentIsLiked) async {
        return await handleLike(post.id, currentIsLiked);
      },
      likeBuilder: (bool isLiked) {
        return Icon(
          CupertinoIcons.heart_fill,
          color: isLiked ? Colors.red : Colors.white,
        );
      },
    );
  },
),
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.comment_outlined,
                  color: white,
                ),
              ),         
            ],
          ),
          // Caption
          Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Text(
        post["caption"] ?? "",
        style: const TextStyle(
          color: white,
        ),
      ),
    ),
            ],
          ),
      ],),
    );
  },
);
}),
);
  }
}