import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// EmergencyScreen: A StatelessWidget that provides a list of emergency contact numbers.
class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  // Static list of emergency numbers along with their names.
  static const List<Map<String, String>> numbers = [
    {'name': 'Police', 'number': '110'},
    {'name': 'Fire and Ambulance', 'number': '119'},
    {'name': 'Emergency Bad Cell Reception', 'number': '112'},
    {'name': 'English-language Directory Assistance', 'number': '106'},
    {'name': '24-Hour Toll-Free Travel Information Hotline', 'number': '0800-011-765'},
    {'name': 'Information For Foreigners In Taiwan', 'number': '1990'},
    {'name': 'American Institute of Taiwan', 'number': '+886-02-2162-2000'},
  ];

  // Build method that constructs the UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using ListView.builder to create a scrollable list of emergency numbers.
      body: ListView.builder(
        itemCount: numbers.length, // The number of items in the list is equal to the length of 'numbers'.
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(numbers[index]['name'] ?? 'Unknown'), // Displaying the name of the emergency service.
            trailing: IconButton(
              icon: const Icon(Icons.call), // Icon to represent the calling action.
              onPressed: () {
                final number = numbers[index]['number']; // Retrieves the number from the list.
                if (number != null) {
                  launch('tel:$number'); // Launches the phone dialer with the specified number.
                } else {
                  // If the number is not available, show a snack bar with an error message.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Phone number is not available')),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}
