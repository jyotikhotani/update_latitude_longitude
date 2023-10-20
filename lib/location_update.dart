import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationUpdate extends StatefulWidget {
  const LocationUpdate({super.key});

  @override
  State<LocationUpdate> createState() => _LocationUpdateState();
}

class _LocationUpdateState extends State<LocationUpdate> {
  Location location = Location();
  bool? serviceEnabled;
  PermissionStatus? permissionGranted;
  LocationData? locationData;
  String latitude = "";
  String longitutde = "";

  requestLocationEnbled() async {
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled!) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled!) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    location.onLocationChanged.listen((locate) {
      setState(() {
        latitude = locate.latitude.toString();
        longitutde = locate.longitude.toString();
      });
      print("locate $latitude");
    });
    sendDataToApi();
  }

  sendDataToApi() async {
    var client = http.Client();
    try {
      var response = await client.post(
          Uri.https('machinetest.encureit.com', '/locationapi.php'),
          body: {'latitude': latitude, 'longitude': longitutde});

      if (response.statusCode == 200) {
        print("location updated successfully");
      } else {
        print("location updation faild");
      }
    } catch (execption) {
      print(execption);
    } finally {
      client.close();
    }
  }

  @override
  void initState() {
    requestLocationEnbled();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Location Update"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("latitude: $latitude"),
            Text("longitutde: $longitutde"),
          ],
        ),
      ),
    );
  }
}
