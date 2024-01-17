import 'package:application/main.dart';
import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NiHao Penyou'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Welcome!'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to the main screen (BottomNavigationBar)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const BottomNavBar(),
                  ),
                );
              },
              child: const Text('Explore!'),
            ),
          ],
        ),
      ),
    );
  }
}
