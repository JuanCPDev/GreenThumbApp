import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:moisturecontentflutter/planter_model.dart';
import 'package:progress_indicators/progress_indicators.dart';
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
        title: Text('Are you sure you would like to remove $name material?'),
        actions: <Widget>[
          TextButton(
            child: Text('OK'),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(name + " removed."),
              ));
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text('Cancel'),
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

//.then((value) {
//Planter planters = Planter.fromJson(jsonDecode(value.body));
//return planters;
//});

class InventoryScreen extends StatefulWidget {
  InventoryScreen({
    Key? key,
    required this.uid,
  }) : super(key: key);
  final String uid;

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Stream<Map> productNameStream;
  //late DatabaseReference productnameStreamRef;
  //allows the state to be updated when a value is changed
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //final getUserDetailUrl = Uri.parse('http://10.0.2.2:5000/getUserDetails');

    //http.get(getUserDetailUrl, headers: {"userid":uid});

    //productNameStream = FirebaseDatabase.instance
    //    .ref('Users/${widget.uid}/Plantmouisturetackers')
    //  .onValue
    //   .map((event) => event.snapshot.value as Map<dynamic,dynamic>? ?? {} );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initRequest(widget.uid),
      builder: (context, future) {
        if (future.connectionState == ConnectionState.waiting) {
          return Text("waiting");
        } else if (future.hasData) {
          return Scaffold(
              body: ListView(
            children: [
              for (int index = 0; index < future.data!.planters.length; index++)
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
          ));
        } else {
          return Text("mega error");
        }
      },
    );

    /*
                  floatingActionButton: FloatingActionButton(
                    onPressed: () {},
                    child: Ink(
                      decoration: ShapeDecoration(
                          color: Colors.grey[400], shape: CircleBorder()),
                      child: IconButton(
                        iconSize: 100,
                        onPressed: () {
                          setState(() {});
                          /*
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ItemForm()));
                                  */
                        },
                        icon: Image.asset('assets/icons/addBasketIco.png'),
                      ),
                    ),
                  )*/
  }
}
