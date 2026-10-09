import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram_clone_project/theme/app_colors.dart';
import 'dart:typed_data';
// add import for cloud..
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

final FirebaseAuth _auth = FirebaseAuth.instance;
final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// controllers
final TextEditingController _usercontroller = TextEditingController();
final TextEditingController _biocontroller = TextEditingController();

// img picker
final ImagePicker _picker = ImagePicker();
class _EditProfileState extends State<EditProfile> {

// select photo display in container
XFile? selectedimage;
Uint8List? imageBytes;
String? profilePhoto;

Future<void> selectPhoto() async
{
  // what i want open file
  // choose img
  // byes
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
      filename: "profile_photo.jpg",
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
// update profile
Future<void> updateUser() async
{
  String uid = _auth.currentUser!.uid;

  String? imageUrl = await uploadtoCloudinary();
  _firestore.collection("users").doc(uid).update({
    "bio": _biocontroller.text,
    "username": _usercontroller.text,
    "profilePhoto": imageUrl,
  });
}
// get user
Future<DocumentSnapshot> getUser() async
{
  String uid = _auth.currentUser!.uid;
  DocumentSnapshot documentSnapshot = await _firestore.collection("users")
  .doc(uid).get();

  return documentSnapshot;
}
@override
void initState()
{
  super.initState();
  loadUser();
}
// details
String email = "";

// load user
Future<void> loadUser() async
{
  DocumentSnapshot documentSnapshot = await getUser();
  setState(() {
    email = documentSnapshot["email"];
    // add for bio user
    _usercontroller.text = documentSnapshot["username"];
    _biocontroller.text = documentSnapshot["bio"];
    // profile
    profilePhoto = documentSnapshot["profilePhoto"];
  });
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: black,
        leading: IconButton(onPressed: ()
        {
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios, color: grey,)),
      ),
      backgroundColor: black,
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Padding(padding: EdgeInsets.only(top: 20.0),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: grey,
              shape: BoxShape.circle,
            ),
            child: imageBytes!=null
            ? ClipOval(
              child: Image.memory(imageBytes!,
              fit: BoxFit.cover,
              ),
            )
        : profilePhoto != null && profilePhoto!.isNotEmpty
        ? ClipOval(
            child: Image.network(
              profilePhoto!,
              fit: BoxFit.cover,
            ),
          ):
            Icon(Icons.person, color: white,)
            ),
          ),
          TextButton(onPressed: () async
          {
            await selectPhoto();
          }, child: Text("Choose Photo", style: TextStyle(color: blue),),),
          const SizedBox(height: 10.0,),
          Row(
            children: [
              Text("Email:", style: TextStyle(color: white,),),
              const SizedBox(width: 15.0,),
              Text(email,  style: TextStyle(color: white,),),
            ],
          ),
          // change username
          const SizedBox(height: 10.0,),
          Text(
            "Change Username",
            style: TextStyle(
              color: white,
            ),
          ),
          TextFormField(
            controller: _usercontroller,
            style: TextStyle(
              color: white,
            ),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.5,
                  color: grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.5,
                  color: grey,
                ),
              ),
              hintText: 'username',
              hintStyle: TextStyle(
                color: grey,
              ),
            ),
          ),
          // add bio
          const SizedBox(height: 10.0,),
          Text(
            "Add Bio",
            style: TextStyle(
              color: white,
            ),
          ),
          TextFormField(
            controller: _biocontroller,
            style: TextStyle(
              color: white,
            ),
            decoration: InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.5,
                  color: grey,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 2.5,
                  color: grey,
                ),
              ),
              hintText: 'Bio',
              hintStyle: TextStyle(
                color: grey,
              ),
            ),
          ),
          const SizedBox(height: 10.0,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: white,
              maximumSize: Size(120, 40),
            ),
            onPressed: () async
          {
            await updateUser();
            Navigator.pop(context);
          }, child: Text("Save"),),
        ],
      ),),
    );
  }
}