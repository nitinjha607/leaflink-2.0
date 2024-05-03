import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SeeVenuePage extends StatefulWidget {
  static const String routeName = 'SeeVenue_page';
  final String address;

  const SeeVenuePage({Key? key, required this.address}) : super(key: key);

  @override
  State<SeeVenuePage> createState() => _SeeVenuePageState();
}

class _SeeVenuePageState extends State<SeeVenuePage> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    markers.add(Marker(
      markerId: MarkerId('selected_location'),
      position: LatLng(0, 0),
      infoWindow: InfoWindow(
        title: 'Selected Location',
      ),
    ));
    _getCurrentLocation(); // Fetch the current location when the page initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Event Venue",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.03,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: LatLng(0, 0),
          zoom: 14,
        ),
        markers: markers,
        polylines: polylines,
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
      _moveCameraToPosition(widget.address);
    });
  }

  void _moveCameraToPosition(String address) async {
    print(
        'Address received: $address'); // Debug print to check the received address

    // Extract latitude and longitude from the address
    List<String> parts = address.substring(7, address.length - 1).split(', ');
    if (parts.length == 2) {
      try {
        double lat = double.parse(parts[0]);
        double lng = double.parse(parts[1]);
        LatLng position = LatLng(lat, lng);

        print(
            'Fetching coordinates for: $position'); // Debug print to check the coordinates

        setState(() {
          markers.clear();
          markers.add(Marker(
            markerId: MarkerId('selected_location'),
            position: position,
            infoWindow: InfoWindow(
              title: 'Selected Location',
            ),
          ));
        });

        // Move the camera to the position
        mapController.moveCamera(CameraUpdate.newLatLngZoom(position, 14));

        // Add direction lines between current location and event venue
        _addDirectionLines(position);
      } catch (e) {
        print('Error parsing coordinates: $e');
      }
    } else {
      print('Error: Invalid address format');
    }
  }

  void _getCurrentLocation() async {
    LocationData? locationData;
    Location location = Location();

    try {
      locationData = await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
    }

    if (locationData != null) {
      LatLng currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _addCurrentLocationMarker(currentPosition);
    } else {
      print('Failed to get current location');
    }
  }

  void _addCurrentLocationMarker(LatLng position) {
    setState(() {
      markers.add(Marker(
        markerId: MarkerId('current_location'),
        position: position,
        infoWindow: InfoWindow(
          title: 'Current Location',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ));
    });
  }

  void _addDirectionLines(LatLng destination) async {
    LocationData? locationData;
    Location location = Location();

    try {
      locationData = await location.getLocation();
    } catch (e) {
      print('Error getting location: $e');
      return;
    }

    if (locationData == null) {
      print('Failed to get current location');
      return;
    }

    LatLng origin = LatLng(locationData.latitude!, locationData.longitude!);

    // Fetch direction lines from current location to the destination
    String apiKey =
        "AIzaSyC-ihWtRLpJ1uIOK5hsH79u_TV-AOevPo0"; // Replace with your Google Maps Directions API key
    String apiUrl = 'https://maps.googleapis.com/maps/api/directions/json';
    String requestUrl =
        '$apiUrl?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    var response = await http.get(Uri.parse(requestUrl));
    var data = json.decode(response.body);

    if (response.statusCode == 200 && data['status'] == 'OK') {
      List<LatLng> points =
          _decodePoly(data['routes'][0]['overview_polyline']['points']);
      setState(() {
        polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: points,
          color: Colors.green,
          width: 5,
        ));
      });
    } else {
      print('Error fetching route: ${data['status']}');
    }
  }

  List<LatLng> _decodePoly(String poly) {
    List<PointLatLng> points = PolylinePoints().decodePolyline(poly);
    List<LatLng> decodedPoints = [];
    for (var point in points) {
      decodedPoints.add(LatLng(point.latitude, point.longitude));
    }
    return decodedPoints;
  }
}
