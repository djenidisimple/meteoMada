import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Text(
          'Home Screen',
          style: TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        Center(
            child: ElevatedButton(
          onPressed: () {
            // Action when the button is pressed
          },
          child: Text('Go to Details'),
        ))
      ],
    ));
  }
}
