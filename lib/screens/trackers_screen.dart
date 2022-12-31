import 'package:moisturecontentflutter/planter_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<void> displayDeleteDialog(
    BuildContext context, String name, String id) async {
  //this brings up an alert dialog to input material
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
            'To add a new tracker follow these steps then press "OK".\n1.Turn on your tracker\n2.After a few seconds locate and connect to the SSID "Greenthumbtracker",the password is "password".\n3. After succesful connection, press "OK".'),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              addnewtracker(
                  "wrongssid", "wrongpassword", "wrongserver", "wrongname");
            },
          ),
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      );
    },
  );
}

Future<Planter?> initRequest(String uid) async {
  final getUserDetailUrl =
      Uri.parse('http://10.0.2.2:5000/getplanters?userId=$uid');
  var response = await http.get(getUserDetailUrl);
  if (response.body.isNotEmpty) {
    Planter planter = Planter.fromJson(jsonDecode(response.body));
    return planter;
  } else {
    return null;
  }
}

class TrackerScreen extends StatefulWidget {
  TrackerScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);
  final String uid;

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initRequest(widget.uid),
      builder: (context, future) {
        if (future.connectionState == ConnectionState.waiting) {
          return Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/gifs/plant_loading2.gif'),
                  fit: BoxFit.cover),
            ),
          );
        } else if ((future.connectionState == ConnectionState.done ||
                future.connectionState == ConnectionState.active) &&
            !future.hasError) {
          return Scaffold(
            body: Container(
              constraints: const BoxConstraints.expand(),
              decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/images/signup_screen_bg.jpg'),
                    fit: BoxFit.cover),
              ),
              child: ListView(
                children: [
                  for (int index = 0;
                      index < future.data!.planters.length;
                      index++)
                    Stack(
                      children: [
                        Card(
                            child: Column(
                          children: [
                            ListTile(
                              title: Text(future.data!.planters[index].name),
                            )
                          ],
                        ))
                      ],
                    )
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: "Add New Tracker",
              child: Ink(
                decoration: const ShapeDecoration(
                    color: Color.fromARGB(255, 162, 220, 96),
                    shape: CircleBorder()),
                child: IconButton(
                  iconSize: 100,
                  onPressed: () async {
                    await displayDeleteDialog(context, "fff", "hh")
                        .then((value) => null);
                    //setState(() {});
                  },
                  icon: Image.asset('assets/icons/add_sensor.png'),
                ),
              ),
            ),
          );
        } else {
          return const Text("mega error");
        }
      },
    );
  }
}

Future<dynamic> addnewtracker(String newSSID, String newPassword,
    String newServerUrl, String newName) async {
  final addNewTrackerUrl = Uri.parse('http://192.168.4.1/');
  var response = await http
      .post(addNewTrackerUrl,
          body: json.encode({
            "ssid": "newSSID",
            "password": "newPassword",
            "serverurl": "newServerUrl",
            "name": "newName"
          }))
      .catchError((error) {
    print(error);
  });

  return response;
}
