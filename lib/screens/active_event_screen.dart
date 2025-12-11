import 'package:flutter/material.dart';

class ActiveEventScreen extends StatelessWidget {
  const ActiveEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E7D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9DD79D),
        title: const Text('Active Event'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Color(0xFF9DD79D),
            ),
            SizedBox(height: 20),
            Text(
              'Active Event with QR Scan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}