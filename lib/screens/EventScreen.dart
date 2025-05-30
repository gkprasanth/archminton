import 'package:flutter/material.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      // color: Colors.blueAccent,
      child: const Center(
        child: Text("Events Page", style: TextStyle(color: Colors.black, fontSize: 28)),
      ),
    );
  }
}