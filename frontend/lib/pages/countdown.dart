import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';

class CountdownPage extends StatelessWidget {
  final String? userId;
  const CountdownPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(userId: userId,), //putting in nav bar
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "Countdown Page",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}