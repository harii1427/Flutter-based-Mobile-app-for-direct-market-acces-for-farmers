// ignore_for_file: file_names

import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:background_location/background_location.dart';
import 'package:geocoding/geocoding.dart';

class ExploreBuyFunctions {
  static Future<void> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    }
  }

  static void getCurrentLocation(Function(LatLng) setLocation) async {
    await BackgroundLocation.startLocationService();
    BackgroundLocation.getLocationUpdates((location) {
      setLocation(LatLng(location.latitude!, location.longitude!));
    });
  }

  static Future<void> getPincode(
      double latitude, double longitude, Function(String) setPincode) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        setPincode(placemarks.first.postalCode ?? '');
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  static void getLocationFromQuery(String query, Function(LatLng) setLocation) async {
    try {
      var locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        var firstLocation = locations.first;
        double latitude = firstLocation.latitude;
        double longitude = firstLocation.longitude;
        setLocation(LatLng(latitude, longitude));
      }
      // ignore: empty_catches
    } catch (e) {}
  }
}
