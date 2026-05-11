import 'package:flutter/material.dart';

class List extends StatelessWidget {
  const List({super.key});

  @override
  Widget build(BuildContext context) {
    return const Material(
      child: Center(
        child: Text(
          'Liste des éléments',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
