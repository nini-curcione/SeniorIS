import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// GpsScreen: A StatefulWidget that displays a Google Map and provides directions.
class GpsScreen extends StatefulWidget {
  const GpsScreen({Key? key}) : super(key: key);

  @override
  State<GpsScreen> createState() => _GpsScreenState();
}

// _GpsScreenState: The state class for GpsScreen with the main functionality.
class _GpsScreenState extends State<GpsScreen> {
  GoogleMapController? mapController; // Controller for Google Map.
  final TextEditingController _originController = TextEditingController(); // Controller for origin input.
  final TextEditingController _destinationController = TextEditingController(); // Controller for destination input.
  List<LatLng> polylineCoordinates = []; // Stores coordinates for the route's polyline.
  Map<PolylineId, Polyline> polylines = {}; // Stores the polyline representation on the map.
  final List<Map<String, String>> _steps = []; // Holds step-by-step navigation instructions.
  String _selectedTransportMode = 'driving'; // Current transportation mode (default is 'driving').

  // Mapping of transportation modes to their respective icons.
  Map<String, IconData> modeIcons = {
    'driving': Icons.directions_car,
    'walking': Icons.directions_walk,
    'bicycling': Icons.directions_bike,
    'transit': Icons.directions_bus,
  };

  // Callback for when the map is created.
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Converts an address string to LatLng using Google's Geocoding API.
  Future<LatLng?> _getLatLngFromString(String address) async {
    String url = 'https://maps.googleapis.com/maps/api/geocode/json?'
        'address=${Uri.encodeComponent(address)}&'
        'key= YOUR_TOKEN';

    http.Response response = await http.get(Uri.parse(url));
    Map data = json.decode(response.body);
    if (data['status'] == 'OK') {
      final lat = data['results'][0]['geometry']['location']['lat'];
      final lng = data['results'][0]['geometry']['location']['lng'];
      return LatLng(lat, lng);
    } else {
      // Handle error or return null
      return null;
    }
  }

  // Requests directions from Google Directions API and updates the map.
  void _getDirections(String mode) async {
    LatLng? originLatLng = await _getLatLngFromString(_originController.text);
    LatLng? destinationLatLng = await _getLatLngFromString(_destinationController.text);

    // If any of the coordinates are null, show an error or return
    if (originLatLng == null || destinationLatLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not find location')),
      );
      return;
    }

    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${originLatLng.latitude},${originLatLng.longitude}&'
        'destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&'
        'mode=$mode&' 
        'key= YOUR_TOKEN'; 

    http.Response response = await http.get(Uri.parse(url));
    Map data = json.decode(response.body);

    if (data['status'] == 'OK') {
      setState(() {
        polylineCoordinates.clear();
        _steps.clear();
        final steps = data['routes'][0]['legs'][0]['steps'] as List;
        for (var step in steps) {
          polylineCoordinates.add(LatLng(
            step['start_location']['lat'],
            step['start_location']['lng'],
          ));
          polylineCoordinates.add(LatLng(
            step['end_location']['lat'],
            step['end_location']['lng'],
          ));

          _steps.add({
            'instruction': step['html_instructions']
                .replaceAll(RegExp(r'<[^>]*>'), ''),
            'distance': step['distance']['text'],
            'duration': step['duration']['text'],
          });
        }

        PolylineId id = const PolylineId("poly");
        polylines[id] = Polyline(
          polylineId: id,
          color: Colors.blue,
          points: polylineCoordinates,
          width: 5,
        );

        // Adjust the map's camera to the new polyline
        mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(
            _createBounds(polylineCoordinates), 
            100.0, // padding
          ),
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['error_message'] ?? 'Error fetching directions')),
      );
    }
  }

  // Creates LatLngBounds for adjusting the map's camera view based on the route.
  LatLngBounds _createBounds(List<LatLng> polylineCoordinates) {
    double? southwestLat, southwestLng, northeastLat, northeastLng;
    for (var point in polylineCoordinates) {
      if (southwestLat == null || point.latitude < southwestLat) southwestLat = point.latitude;
      if (southwestLng == null || point.longitude < southwestLng) southwestLng = point.longitude;
      if (northeastLat == null || point.latitude > northeastLat) northeastLat = point.latitude;
      if (northeastLng == null || point.longitude > northeastLng) northeastLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(southwestLat!, southwestLng!),
      northeast: LatLng(northeastLat!, northeastLng!),
    );
  }

  // Builds the UI with input fields, map display, and navigation steps.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _originController,
              decoration: const InputDecoration(
                labelText: 'From',
                hintText: 'Enter Start Location',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _destinationController,
              decoration: const InputDecoration(
                labelText: 'To',
                hintText: 'Enter Destination',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          DropdownButton<String>(
            value: _selectedTransportMode,
            onChanged: (String? newValue) {
              setState(() {
                _selectedTransportMode = newValue!;
              });
            },
            items: modeIcons.keys.map<DropdownMenuItem<String>>((String mode) {
              return DropdownMenuItem<String>(
                value: mode,
                child: Row(
                  children: [
                    Icon(modeIcons[mode]), 
                    const SizedBox(width: 8.0),
                    Text(mode),
                  ],
                ),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: () {
              _getDirections(_selectedTransportMode);
            },
            child: const Text('Show Directions'),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(0, 0), 
                zoom: 2,
              ),
              polylines: Set<Polyline>.of(polylines.values),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _steps.length,
              itemBuilder: (BuildContext context, int index) {
                var step = _steps[index];
                return ListTile(
                  title: Text(step['instruction'] ?? ''),
                  subtitle: Text('${step['distance']} (${step['duration']})'),
                  leading: Icon(modeIcons[_selectedTransportMode]), 
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}




