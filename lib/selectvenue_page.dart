import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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

  Completer<GoogleMapController> _controller = Completer();
  static final CameraPosition _kGoogle = const CameraPosition(
    target: LatLng(20.42796133580664, 80.885749655962),
    zoom: 14.4746,
  );

  final Set<Marker> _markers = <Marker>{};
  late TextEditingController _searchController;
  late LatLng coordinates;

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
      body: Stack(
        children: [
          Container(
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
          Container(
            width: MediaQuery.of(context).size.width * 0.9,
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
              itemCount: _placeList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () async {},
                  child: ListTile(
                    title: Text(_placeList[index]["description"]),
                  ),
                );
              },
            ),
          ),
        ],
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
