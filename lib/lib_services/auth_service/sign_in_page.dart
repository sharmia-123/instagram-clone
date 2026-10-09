import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:instagram_clone_project/lib_services/auth_service.dart';
import 'package:instagram_clone_project/lib_services/auth_service/sign_up_page.dart';
import 'package:instagram_clone_project/pages/home_page.dart';
import 'package:instagram_clone_project/theme/app_colors.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}
// call auth service
final AuthService _service = AuthService();

// add controllers
final TextEditingController _emailcontroller = TextEditingController();
final TextEditingController _passwordcontroller = TextEditingController();

// errors
String? invalidemail;
String? missingpassword;
String? weakpassword;
String? invalidcredential;

class _SignInPageState extends State<SignInPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Padding(padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Instagram Login",
          style: GoogleFonts.satisfy(color: white, fontSize: 35,),),
          const SizedBox(height: 10.0,),
          if(invalidemail !=null)
          Text(
            invalidemail!,
            style: TextStyle(
              color: red,
            ),
          ),
          if(invalidcredential!=null)
          Text(
            invalidcredential!,
            style: TextStyle(
              color: red,
            ),
          ),
          Row(
            children: [
              Icon(Icons.email,color: grey,),
              Expanded(child: TextFormField(
                controller: _emailcontroller,
                style: TextStyle(
                  color: white,
                ),
                decoration: InputDecoration(
                  hintText: "Email",
                  hintStyle: TextStyle(
                    color: grey,
                  ),
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
                ),
               ),
              ),
            ],
          ),
          const SizedBox(height: 10.0,),  
          if(missingpassword != null)
          Text(
            missingpassword!,
            style: TextStyle(
              color: red,
            ),
          ),
          if(weakpassword != null)
          Text(
            weakpassword!,
            style: TextStyle(
              color: red,
            ),
          ),

          Row(
            children: [
              Icon(Icons.abc,color: grey,),
              Expanded(child: TextFormField(
                onChanged: (value)
                {
                  setState(() {
                    missingpassword = null;
                  });
                },
                controller: _passwordcontroller,
                obscureText: true,
                style: TextStyle(
                  color: white,
                ),
                decoration: InputDecoration(
                  hintText: "Password",
                  hintStyle: TextStyle(
                    color: grey,
                  ),
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
                ),
               ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text("Dont have an account?", style: TextStyle(color: white, fontSize: 14,),),
              TextButton(onPressed: ()
              {
                Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignUpPage()));
              },  child: Text("Sign Up", style: TextStyle(color: blue, fontSize: 17,),))
            ],
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: blue,
              foregroundColor: white,
              minimumSize: Size(120, 50),
            ),
            onPressed: () async
          {
            String message = await _service.signIn(email: _emailcontroller.text, 
            password: _passwordcontroller.text);

            if(message == "success")
            {
              Navigator.push(context,
              MaterialPageRoute(builder: (context) => HomePage()));
            }
            // types of errors
            if(message == "invalid-email")
            {
              setState(() {
                invalidemail = "invalid-email";
              });
            }
            if(message == "missing-password")
            {
              setState(() {
                missingpassword = "missing-password";
              });
            }
            if(message == "weak-password")
            {
              setState(() {
                weakpassword = "weak-password";
              });
            }
            if(message == "invalid-credential")
            {
              setState(() {
                invalidcredential = "invalid-credential";
              });
            }
          }, child: Text("Sign In"))
        ],
      ),),
    );
  }
}