import 'package:application/start_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'gps_screen.dart';
import 'translator_screen.dart';
import 'map_screen.dart';
import 'emergency_screen.dart';

// Main function to run the app.
void main() {
  runApp(const MyApp());
}

// MyApp: A StatelessWidget that defines the main structure of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Builds the MaterialApp with initial routing.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/', // Setting the initial route to StartScreen.
      routes: {
        '/': (context) => const StartScreen(), // Mapping '/' route to StartScreen.
      },
    );
  }
}

// BottomNavBar: A StatefulWidget to manage the bottom navigation bar.
class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

// _BottomNavBarState: State class for BottomNavBar.
class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0; // Current index for the selected tab in the navigation bar.

  // List of screens corresponding to each tab in the bottom navigation bar.
  final List<Widget> _screens = [
    const GpsScreen(),
    const TranslatorScreen(),
    const MapsScreen(),
    const EmergencyScreen(),
  ];

  // Builds the UI with AppBar, current screen body, and bottom navigation bar.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ni Hao Penyou'), // AppBar title.
      ),
      body: _screens[_currentIndex], // Display the screen based on the current index.
      bottomNavigationBar: CupertinoTabBar(
        currentIndex: _currentIndex, // Current selected tab index.
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the current index on tab tap.
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'GPS',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.translate),
            label: 'Translator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Maps',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning),
            label: 'Emergency',
          ),
        ],
      ),
    );
  }
}

