import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// MapsScreen: A StatefulWidget that displays a Google Map and allows for searching nearby places.
class MapsScreen extends StatefulWidget {
  const MapsScreen({Key? key}) : super(key: key);

  @override
  State<MapsScreen> createState() => MapsScreenState();
}

// MapsScreenState: The state class for MapsScreen where the main functionality resides.
class MapsScreenState extends State<MapsScreen> {
  GoogleMapController? mapController; // Controller for Google Map.
  TextEditingController searchController = TextEditingController(); // Controller for search input.
  final LatLng _center = const LatLng(25.0330, 121.5654); // Initial center point of the map.
  List<Marker> markers = []; // Stores markers for locations on the map.

  // Callback for when the map is created.
  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  // Searches for nearby places using Google Places API and updates markers on the map.
  void searchNearbyPlaces(String place) async {
    const apiKey = 'YOUR_TOKEN';
    final url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${_center.latitude},${_center.longitude}&radius=1000&keyword=$place&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      setState(() {
        markers.clear();

        for (var result in results) {
          final name = result['name'];
          final address = result['vicinity'] ?? 'No address available';
          final rating = result['rating']?.toString() ?? 'No rating';
          final geometry = result['geometry'];
          final location = geometry['location'];
          final lat = location['lat'];
          final lng = location['lng'];

          markers.add(
            Marker(
              markerId: MarkerId(name),
              position: LatLng(lat, lng),
              infoWindow: InfoWindow(
                title: name,
                snippet: 'Rating: $rating, Address: $address',
              ),
            ),
          );
        }
      });
    } else {
      throw Exception('Failed to load nearby places');
    }
  }

  // Builds the UI with a search field and Google Map display.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search for nearby places',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    searchNearbyPlaces(searchController.text);
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 11.0,
              ),
              markers: Set<Marker>.of(markers),
            ),
          ),
        ],
      ),
    );
  }
}










