import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_project/pages/home_page.dart';
import 'package:instagram_clone_project/theme/app_colors.dart';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPosts extends StatefulWidget {
  const AddPosts({super.key});

  @override
  State<AddPosts> createState() => _AddPostsState();
}

// caption cntrlr
final TextEditingController _captioncontroller = TextEditingController();

// img picker
final ImagePicker _picker = ImagePicker();

// auth firestore
final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

class _AddPostsState extends State<AddPosts> {

  // get user 
  Future<DocumentSnapshot> getuser() async
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
  // load user name , profile
  String username = "";
  String profilePhoto = "";

  // Function to call img
  Future<void> loadUser() async
  {
    DocumentSnapshot documentSnapshot = await getuser();

    setState(() {
      username = documentSnapshot["username"];
      profilePhoto = documentSnapshot["profilePhoto"];
    });
  }

  XFile? selectedimage;
  Uint8List? imageBytes;

  Future<void> getImage() async
  {
    XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if(image!=null)
    {
      Uint8List bytes = await image.readAsBytes();
      setState(() {
        selectedimage = image;
        imageBytes = bytes;
      });
    }
  }
  // createpost
  Future<void> uploadPost() async
  {
    if(imageBytes == null)
    {
      return;
    }
     // Upload the post image to Cloudinary
     String? imageUrl = await uploadtoCloudinary();

     if(imageUrl == null)
     {
      return;
     }

     String uid = _auth.currentUser!.uid;

     await _firestore.collection("posts").add({
      "imageUrl": imageUrl,
      "caption": _captioncontroller.text,
      "username": username,
      "profilePhoto": profilePhoto,
      "userId": uid,
      "createdAt": FieldValue.serverTimestamp(),
     });

    Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => const HomePage(),
    ),
  );
  }
  // upload to cloud..
Future<String?> uploadtoCloudinary() async
{
  if(imageBytes == null)
  {
    return null;
  }

  final url = Uri.parse("https://api.cloudinary.com/v1_1/m10juxjx/image/upload");

  final request = http.MultipartRequest("POST" , url);

  request.fields["upload_preset"] = "instagram_clone_upload";

  request.files.add(
    http.MultipartFile.fromBytes(
      "file",
      imageBytes!,
      filename: "post_image.jpg",
    ),
  );
  final response = await request.send();

  if (response.statusCode == 200) {
    final responseData = await response.stream.bytesToString();
    final data = jsonDecode(responseData);

    return data["secure_url"];
  } 
  else
  {
    return null;
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: black,
        actions: [
          IconButton(onPressed: () async
          {
            await uploadPost();
          }, icon: Icon(Icons.add, color: white,))
        ],
      ),
      backgroundColor: black,
      body: Padding(padding: EdgeInsets.only(top: 20.0,),
      child: Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          InkWell(
            onTap: () async
            {
              await getImage();
            },
            child: Container(
            width: double.infinity,
            height: 270,
            decoration: BoxDecoration(
              color: grey,
            ),
            child: imageBytes !=null
            ?Image.memory(imageBytes!,fit: BoxFit.cover,):Center(child: Text("Add Post", style: TextStyle(color: white,),),),),
          ),
          const SizedBox(height: 10.0,),
          Container(
            width: double.infinity,
            height: 100,
            decoration: BoxDecoration(
              color: black,
            ),
            child: TextFormField(
              controller: _captioncontroller,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              style: TextStyle(
                color: white,
              ),
              decoration: InputDecoration(
                hintText: "Add Caption",
                hintStyle: TextStyle(
                  color: grey,
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.5,
                    color: grey,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    width: 2.5,
                    color: grey,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
      ),),
    );
  }
}