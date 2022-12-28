import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moisturecontentflutter/screens/home_screen.dart';
import 'package:moisturecontentflutter/screens/signup_screen.dart';
import 'package:splashscreen/splashscreen.dart';
import 'firebase_options.dart';






 main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
 runApp(MaterialApp(
    home: IntroScreen(),
  ));
}

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    User? result = FirebaseAuth.instance.currentUser;
    return SplashScreen(
        //navigateAfterFuture: updateValue(result.uid),
        useLoader: true,
        loadingTextPadding: EdgeInsets.all(0),
        loadingText: Text(""),
        navigateAfterSeconds: result != null ? Home(uid: result.uid) : SignUp(),
        seconds: 3,
        title: Text(
          'Welcome To Smart Inventory!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
       // image: Image.asset('assets/images/main.png', fit: BoxFit.scaleDown),
        backgroundColor: Colors.white,
        styleTextUnderTheLoader: new TextStyle(),
        photoSize: 100.0,
        loaderColor: Colors.red);
  }
  
}
