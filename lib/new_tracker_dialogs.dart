import 'package:flutter/material.dart';
import 'package:ModernGreenThumbApp/screens/trackers_screen.dart';
import 'package:http/http.dart' as http;
import 'package:ModernGreenThumbApp/secret.dart';

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
                                "Succesfully added ${nameController.text}")));
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => TrackerScreen(uid: id)));
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

