import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class BlankPage extends StatefulWidget {
  static const String routeName = 'Blank_page';

  const BlankPage({Key? key}) : super(key: key);

  @override
  State<BlankPage> createState() => _BlankPageState();
}

class _BlankPageState extends State<BlankPage> {
  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = <Marker>{};
  late TextEditingController _searchController;
  late LatLng coordinates;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _markers.add(
      Marker(
        markerId: MarkerId('1'),
        position: LatLng(20.42796133580664, 75.885749655962),
        infoWindow: InfoWindow(
          title: 'My Position',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<LatLng?> _requestLocationPermissionAndGetCurrentLocation() async {
    final LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('Location Permission Required'),
          content: Text(
            'This app requires access to your location. Please grant the permission in settings.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return null;
    } else {
      Position position = await Geolocator.getCurrentPosition();
      coordinates = LatLng(position.latitude, position.longitude);
      return coordinates;
    }
  }

  void _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: position, zoom: 14),
    ));
  }

  void _showLocationSelectionDialog() async {
    LatLng? currentLocation =
        await _requestLocationPermissionAndGetCurrentLocation();
    if (currentLocation != null) {
      setState(() {
        _markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: currentLocation,
            infoWindow: InfoWindow(
              title: 'Current Location',
            ),
          ),
        );
        _moveCameraToPosition(currentLocation);
      });
      Navigator.of(context).pop(coordinates);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Venue",
          style: TextStyle(
            fontFamily: GoogleFonts.comfortaa().fontFamily,
            fontSize: MediaQuery.of(context).size.height * 0.03,
            color: const Color.fromRGBO(16, 25, 22, 1),
          ),
        ),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
      body: Container(
        child: SafeArea(
          child: GoogleMap(
            initialCameraPosition: _kGoogle,
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: true,
            compassEnabled: true,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showLocationSelectionDialog,
        label: Text('Search'),
        icon: Icon(Icons.search),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
    );
  }
}
