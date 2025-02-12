import 'package:flutter/material.dart';

class IeltsCoachingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Coaching'),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Center(
        child: Text(
          'IELTS Coaching Content Goes Here!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
