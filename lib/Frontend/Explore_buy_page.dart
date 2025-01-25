// ignore_for_file: deprecated_member_use, use_build_context_synchronously, prefer_const_constructors, use_super_parameters, avoid_print, unused_import, file_names

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_location/background_location.dart';
import 'package:geocoding/geocoding.dart';
import 'package:far/Backend/Explore_functionality.dart'; // Import the backend functions

class ExploreBuy extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const ExploreBuy({super.key, this.initialLatitude, this.initialLongitude});

  @override
  State<ExploreBuy> createState() => _ExploreState();
}

class _ExploreState extends State<ExploreBuy> {
  final MapController mapController = MapController();
  LatLng? location;
  String? pincode;

  @override
  void initState() {
    super.initState();
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      location = LatLng(widget.initialLatitude!, widget.initialLongitude!);
      ExploreBuyFunctions.getPincode(location!.latitude, location!.longitude, setPincode);
    }
    ExploreBuyFunctions.requestLocationPermission();
  }

  void setPincode(String newPincode) {
    setState(() {
      pincode = newPincode;
    });
  }

  void setLocation(LatLng newLocation) {
    setState(() {
      location = newLocation;
      mapController.move(location!, 13.0);
      ExploreBuyFunctions.getPincode(location!.latitude, location!.longitude, setPincode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 83, 134, 72),
          ),
          child: AppBar(
            title: const Text(
              'far',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.fromLTRB(40, 10, 40, 5),
                  child: TextField(
                    onSubmitted: (value) {
                      ExploreBuyFunctions.getLocationFromQuery(value, setLocation);
                    },
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          ExploreBuyFunctions.getCurrentLocation(setLocation);
                        },
                        child: const Icon(Icons.location_searching_rounded),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height - 280,
                  child: FlutterMap(
                    mapController: mapController,
                    options: MapOptions(
                      initialCenter: location ?? const LatLng(11.0168, 76.9558),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      if (location != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 100.0,
                              height: 100.0,
                              point: location!,
                              child: const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 40.0,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                if (pincode != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Pincode: $pincode',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    blurRadius: 5,
                    spreadRadius: 2,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color.fromARGB(255, 83, 134, 72),
                          Color.fromARGB(255, 174, 212, 170),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, pincode);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: const Text(
                        'Next',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
