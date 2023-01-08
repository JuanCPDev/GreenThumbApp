import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:moisturecontentflutter/screens/trackers_screen.dart';
import 'package:moisturecontentflutter/secret.dart';
import 'signup_screen.dart';
import 'package:http/http.dart' as http;

GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> saveTokenToDatabase(String token, String userId) async {
  final updateUserTokenUrl =
      Uri.parse('$serverHost/updateusertoken?token=$token&userId=$userId');
  await http.post(updateUserTokenUrl);
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  Navigator.push(
      navigatorKey.currentState!.context,
      MaterialPageRoute(
          builder: (context) => TrackerScreen(uid: message.data["id"])));
}

void requestPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
}

class Home extends StatefulWidget {
  final String uid;
  const Home({Key? key, required this.uid}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  _HomeState();
  String? token;

  Future<void> setupToken() async {
    token = await FirebaseMessaging.instance.getToken();

    // Save the initial token to the database
    await saveTokenToDatabase(token!, widget.uid);

    // Any time the token refreshes, store this in the database too.
    FirebaseMessaging.instance.onTokenRefresh.listen((event) {
      token = event;
      saveTokenToDatabase(event, widget.uid);
    });
  }

  @override
  void initState() {
     FirebaseMessaging.onMessageOpenedApp.listen(_firebaseMessagingBackgroundHandler);
    //FirebaseMessaging.onBackgroundMessage(
    //    _firebaseMessagingBackgroundHandler);
    setupToken();
    requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/home_screen_background.jpg'),
                fit: BoxFit.cover),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 110,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text("Planters",
                      style: TextStyle(color: Colors.black)),
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                TrackerScreen(uid: widget.uid)));
                  },
                ),
              ),
              SizedBox(
                width: 110,
                child: ElevatedButton(
                  style:
                      ElevatedButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () async {
                    FirebaseAuth auth = FirebaseAuth.instance;
                    auth.signOut().then((res) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => SignUp()),
                          (Route<dynamic> route) => false);
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
