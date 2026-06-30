import 'package:flutter/material.dart';

// Add reusable widgets used by the Home feature here.
class HomeHeader extends StatelessWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Text('Welcome to Home', style: TextStyle(fontSize: 24)),
    );
  }
}
