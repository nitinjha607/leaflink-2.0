import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

class SelectVenuePage extends StatefulWidget {
  static const String routeName = 'SelectVenue_page';

  const SelectVenuePage({Key? key}) : super(key: key);

  @override
  State<SelectVenuePage> createState() => _SelectVenuePageState();
}

class _SelectVenuePageState extends State<SelectVenuePage> {
  final _locationcontroller = TextEditingController();
  var uuid = const Uuid();
  String _sessionToken = '1234567890';
  List<dynamic> _placeList = [];

  Completer<GoogleMapController> mapController = Completer();
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = <Marker>{};
  late TextEditingController _searchController;
  LatLng? coordinates;

  _onChanged() {
    if (_sessionToken == null) {
      setState(() {
        _sessionToken = uuid.v4();
      });
    }
    getSuggestion(_locationcontroller.text);
  }

  void getSuggestion(String input) async {
    const String PLACES_API_KEY = "AIzaSyC-ihWtRLpJ1uIOK5hsH79u_TV-AOevPo0";

    try {
      String baseURL =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json';
      String request =
          '$baseURL?input=$input&key=$PLACES_API_KEY&sessiontoken=$_sessionToken';
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);
      if (kDebugMode) {
        print('mydata');
        print(data);
      }
      if (response.statusCode == 200) {
        setState(() {
          _placeList = json.decode(response.body)['predictions'];
        });
      } else {
        throw Exception('Failed to load predictions');
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _locationcontroller.addListener(
      () {
        _onChanged();
      },
    );
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
    _requestLocationPermission();
    mapController = Completer();
    super.dispose();
  }

  void _requestLocationPermission() async {
    Location location = Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Location services are disabled')));
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        _showPermissionDialog();
        return;
      }
    }

    // Location permissions granted, now you can get the location
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    LocationData? locationData;
    try {
      locationData = await Location().getLocation();
    } catch (e) {
      print('Error getting location: $e');
      // Handle error - display a message to the user or retry obtaining location
      return;
    }

    if (locationData != null) {
      LatLng selectedCoordinates =
          LatLng(locationData.latitude!, locationData.longitude!);
      coordinates = selectedCoordinates;
      _moveCameraToPosition(selectedCoordinates);
      print(
          'Current Location: ${locationData.latitude}, ${locationData.longitude}');
    } else {
      // Location data is null, handle this case
      print('Failed to get current location');
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
            'This app needs access to your location to function properly.'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await Location().requestPermission();
              // Check permission again after the user interacts with the dialog
              _requestLocationPermission();
            },
            child: Text('Grant'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Handle if the user denies permission
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Location permission denied')));
            },
            child: Text('Deny'),
          ),
        ],
      ),
    );
  }

  void _moveCameraToPosition(LatLng position) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(position, 14));

    // Check if the widget is mounted before calling setState
    if (mounted) {
      setState(() {
        _markers.clear();
        _markers.add(
          Marker(
            markerId: MarkerId('selected_location'),
            position: position,
            infoWindow: InfoWindow(
              title: 'Selected Location',
            ),
          ),
        );
        coordinates = position; // Update coordinates when moving the camera
      });
    }
  }

  void _showLocationSelectionDialog(BuildContext context, String location) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location selected: $location'),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
  }

  void getPlaceDetails(String placeId, String description) async {
    const String PLACES_API_KEY = "AIzaSyC-ihWtRLpJ1uIOK5hsH79u_TV-AOevPo0";
    String baseURL = 'https://maps.googleapis.com/maps/api/place/details/json';
    String request = '$baseURL?place_id=$placeId&key=$PLACES_API_KEY';

    try {
      var response = await http.get(Uri.parse(request));
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        double lat = data['result']['geometry']['location']['lat'];
        double lng = data['result']['geometry']['location']['lng'];

        LatLng selectedCoordinates = LatLng(lat, lng);
        coordinates = selectedCoordinates;
        _moveCameraToPosition(selectedCoordinates);
        print('Selected Coordinates: $selectedCoordinates');
        _showLocationSelectionDialog(context, description);
      } else {
        throw Exception('Failed to load place details');
      }
    } catch (e) {
      print(e);
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
      body: Stack(
        children: [
          Container(
            child: GoogleMap(
              initialCameraPosition: _kGoogle,
              markers: _markers,
              mapType: MapType.normal,
              myLocationEnabled: true,
              compassEnabled: true,
              onMapCreated: onMapCreated,
            ),
          ),
          Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _locationcontroller,
                decoration: InputDecoration(
                  hintText: "Search your location here",
                  focusColor: Colors.white,
                  floatingLabelBehavior: FloatingLabelBehavior.never,
                  prefixIcon: const Icon(Icons.map),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.cancel),
                    onPressed: () {
                      _locationcontroller.clear();
                    },
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            margin: EdgeInsets.only(top: 45),
            child: ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _placeList.length + 1, // Add 1 for the permanent tile
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Render the permanent tile for "Current Location"
                  return ListTile(
                    title: Text(
                      'Current Location',
                      style: TextStyle(
                        color: const Color.fromRGBO(16, 25, 22, 1),
                      ),
                    ),
                    onTap: () {
                      _getCurrentLocation(); // Call function to get current location
                    },
                  );
                } else {
                  // Render the dynamic place list tiles
                  final dynamic place = _placeList[index - 1];
                  return GestureDetector(
                    onTap: () {
                      String placeId = place["place_id"];
                      String description = place["description"];
                      getPlaceDetails(placeId, description);
                    },
                    child: ListTile(
                      title: Text(
                        place["description"],
                        style: TextStyle(
                          color: Colors.blue, // Change color when tapped
                        ),
                      ),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pop(context, coordinates),
        label: Text('Select'),
        icon: Icon(Icons.add),
        backgroundColor: const Color.fromRGBO(97, 166, 171, 1),
      ),
    );
  }
}
