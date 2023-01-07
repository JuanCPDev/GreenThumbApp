import 'dart:async';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:moisturecontentflutter/planter_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:moisturecontentflutter/secret.dart';

Future<void> displayNewTrackerInstructions(BuildContext context, String id) {
  //this brings up an alert dialog to input material
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
            'To add a new tracker follow these steps then press "OK".\n1.Turn on your tracker\n2.After a few seconds locate and connect to the SSID "Greenthumbtracker",the password is "password".\n3. After succesful connection, press "Next".'),
        actions: <Widget>[
          TextButton(
            child: const Text('Next'),
            onPressed: () {
              Navigator.pop(context);
              showCredentialsInput(context, id);
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

Future<void> showCredentialsInput(BuildContext context, String id) async {
  bool httperror = false;
  TextEditingController ssidController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  //this brings up an alert dialog to input credentials
  return await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Please enter the following information'),
        actions: <Widget>[
          TextField(
            controller: ssidController,
            decoration: const InputDecoration(
                helperText: "*WiFi SSID",
                helperStyle: TextStyle(color: Colors.black, fontSize: 16),
                hintText: "YourWiFiName"),
          ),
          TextField(
            controller: passwordController,
            decoration: const InputDecoration(
                helperText: "*WiFi Password",
                helperStyle: TextStyle(color: Colors.black, fontSize: 16),
                hintText: "YourWiFiPassword"),
          ),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
                helperText: "Tracker Display Name",
                helperStyle: TextStyle(color: Colors.black, fontSize: 16),
                hintText: "Kitchen Cactus"),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  child: const Text('Add'),
                  onPressed: () async {
                    showLoadingDialog(context);
                    await addnewtracker(ssidController.text,
                            passwordController.text, id, nameController.text)
                        .timeout(const Duration(seconds: 15), onTimeout: (() {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(seconds: 8),
                          content: Text(
                              "Error, make sure you are connected to tracker Wifi(GreenThumbTracker) and try again")));
                      Navigator.pop(context);
                      Navigator.pop(context);
                    })).whenComplete(() async {
                      http.Response response =
                          await getConnectionStatus().catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            duration: Duration(seconds: 8),
                            content: Text(
                                "Error, make sure you are connected to tracker Wifi(GreenThumbTracker) and try again")));
                        Navigator.pop(context);
                        Navigator.pop(context);
                      });
                      while (!response.body.contains("Connected") &&
                          !response.body.contains("incorrect credentials") &&
                          !httperror) {
                        response =
                            await getConnectionStatus().catchError((error) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              duration: Duration(seconds: 8),
                              content: Text(
                                  "Error, make sure you are connected to tracker Wifi(GreenThumbTracker) and try again")));
                          Navigator.pop(context);
                          Navigator.pop(context);
                        });
                      }
                      if (response.body.contains("Connected")) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 8),
                            content: Text(
                                "Succesfully added ${nameController.text}, refresh page.")));
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } else if (response.body
                          .contains("incorrect credentials")) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                duration: Duration(seconds: 8),
                                content: Text(
                                    "Incorrect credentials!! Try again.")));
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          duration: Duration(seconds: 8),
                          content: Text(
                              "Error, make sure you are connected to tracker Wifi(GreenThumbTracker) and try again")));
                      Navigator.pop(context);
                      Navigator.pop(context);
                    });
                  }),
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      );
    },
  );
}

Future<void> showLoadingDialog(BuildContext context) {
  return showDialog(
      context: context,
      builder: (context) {
        return const CircularProgressIndicator();
      });
}

Future<Planter?> initRequest(String uid) async {
  final getUserDetailUrl = Uri.parse('$serverHost/getplanters?userId=$uid');
  var response;
  try {
    response = await http
        .get(getUserDetailUrl)
        .timeout(const Duration(seconds: 15), onTimeout: () {
      http.Response emptyFuture = http.Response("", 404);
      return emptyFuture;
    });
  } catch (error) {}

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
            !future.hasError &&
            future.hasData) {
          return RefreshIndicator(
            onRefresh: () =>
                Future.delayed(Duration(seconds: 1), (() => setState(() {}))),
            child: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/signup_screen_bg.jpg'),
                      fit: BoxFit.cover),
                ),
                child: ListView.builder(
                  itemCount: future.data!.planters.length,
                  itemBuilder: (context, index) {
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Colors.white,
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(
                              future.data!.planters[index].name,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 20),
                            ),
                          ),
                          GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onLongPress: () => addTrackerImage(widget.uid,
                                  future.data!.planters[index].name),
                              child: AspectRatio(
                                aspectRatio: 16 / 9,
                                child: Ink.image(
                                    fit: BoxFit.fill,
                                    image: CachedNetworkImageProvider(future
                                        .data!.planters[index].thumbnailUrl)),
                              )),
                          ListTile(
                            title: Text(
                                "Moisture level: ${loademojis(future.data!.planters[index].value)}"),
                            subtitle: Text(
                                "Last Checked: ${future.data!.planters[index].lastTimeChecked}"),
                          ),
                        ],
                      ),
                    );
                  },
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
                    onPressed: () {
                      displayNewTrackerInstructions(context, widget.uid);
                      setState() {}
                    },
                    icon: Image.asset('assets/icons/add_sensor.png'),
                  ),
                ),
              ),
            ),
          );
        } else {
          return Scaffold(
              body: Container(
            constraints: const BoxConstraints.expand(),
            decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/signup_screen_bg.jpg'),
                  fit: BoxFit.cover),
            ),
          ));
        }
      },
    );
  }

  addTrackerImage(String uid, String name) async {
    String filename;

    XFile? pickedImage = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxHeight: 1000, maxWidth: 1000);

    if (pickedImage != null) {
      File file = File(pickedImage.path);
      filename = pickedImage.name;
      final firebaseStorage =
          FirebaseStorage.instance.ref("users/$uid/").child("images/$filename");

      await firebaseStorage.putFile(file);
      String url = await firebaseStorage.getDownloadURL();
      uploadTrackerImage(url, uid, name);
    }
  }

  uploadTrackerImage(String url, String uid, String name) async {
    final updateTrackerImageUrl =
        Uri.parse('$serverHost/updatetrackerimage?userId=$uid');
    var response;
    var data = {"thumbnailUrl": url, "name": name};
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        duration: Duration(seconds: 1),
        content: Text("Setting photo..."),
      ),
    );
    response = await http.post(updateTrackerImageUrl,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"}).then(
      (value) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text("Photo set"),
        ),
      ),
    );
    setState(() {});
  }
}

Future<http.Response?> addnewtracker(
    String newSSID, String newPassword, String userId, String newName) async {
  final addNewTrackerUrl = Uri.parse(
      '$trackerAddNewUrl/credentials?ssid=$newSSID&password=$newPassword&userId=$userId&name=$newName');
  var response = http.post(addNewTrackerUrl);
  return response;
}

Future<http.Response> getConnectionStatus() async {
  final getConnectionStatusUrl =
      Uri.parse('$trackerConnectionStatusUrl/getstatus');
  var response = await http.get(getConnectionStatusUrl);
  return response;
}

String loademojis(int moistureLevel) {
  if (moistureLevel > 800) {
    return "💧";
  } else if (moistureLevel > 600) {
    return "💧💧";
  } else if (moistureLevel > 500) {
    return "💧💧💧";
  } else if (moistureLevel > 400) {
    return "💧💧💧";
  } else {
    return moistureLevel.toString();
  }
}