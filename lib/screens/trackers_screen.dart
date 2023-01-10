import 'dart:async';
import 'dart:io';
import 'package:ModernGreenThumbApp/moisture_level_dispays.dart';
import 'package:ModernGreenThumbApp/new_tracker_dialogs.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ModernGreenThumbApp/planter_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ModernGreenThumbApp/secret.dart';

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
            onRefresh: () => Future.delayed(
                const Duration(seconds: 1), (() => setState(() {}))),
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
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 20),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 1),
          content: Text("Setting photo..."),
        ),
      );

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

    response = await http.post(updateTrackerImageUrl,
        body: jsonEncode(data),
        headers: {"Content-Type": "application/json"}).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 4),
          content: Text("Photo set"),
        ),
      );
      setState(() {});
    });
  }
}
