import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

import 'email_login_screen.dart';
import 'email_signup_screen.dart';

class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Sign Up"),
        ),
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/signup_screen_bg.jpg'),
                fit: BoxFit.cover),
          ),
          child: Center(
            
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
                Widget>[
              const Padding(
                padding: EdgeInsets.all(10.0),
                child: Text("Modern Green Thumb",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: 'Roboto')),
              ),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: SignInButton(
                    Buttons.Email,
                    text: "Sign up with Email",
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EmailSignUp()),
                      );
                    },
                  )),
              Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: GestureDetector(
                      child: const Text("Log In Using Email",
                          style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EmailLogIn()),
                        );
                      }))
            ]),
          ),
        ));
  }
}
