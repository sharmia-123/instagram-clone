import 'package:flutter/material.dart';
import 'package:instagram_clone_project/pages/add_posts.dart';
import 'package:instagram_clone_project/pages/home_feed.dart';
import 'package:instagram_clone_project/pages/search_page.dart';
import 'package:instagram_clone_project/pages/user_profile.dart';
import 'package:instagram_clone_project/theme/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

int currentIndex = 0;
List<Widget> pages = [
  SearchPage(),
  HomeFeed(),
  AddPosts(),
  UserProfile(),
];
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: pages[currentIndex],
      bottomNavigationBar: BottomAppBar(
        height: 50,
        color: const Color.fromARGB(255, 85, 78, 78),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(onPressed: ()
            {
              setState(() {
                currentIndex = 0;
              });
            }, icon: Icon(Icons.search, color: grey,),),
            IconButton(onPressed: ()
            {
              setState(() {
                currentIndex = 1;
              });
            }, icon: Icon(Icons.home, color: grey,),),
            IconButton(onPressed: ()
            {
              setState(() {
                currentIndex = 2;
              });
            }, icon: Icon(Icons.camera_alt_rounded, color: grey,),),
            IconButton(onPressed: ()
            {
              setState(() {
                currentIndex = 3;
              });
            }, icon: Icon(Icons.person, color: grey,),),
          ],
        ),
      ),
    );
  }
}