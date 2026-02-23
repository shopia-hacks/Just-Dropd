import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';

class ActivityFeed extends StatelessWidget {
  final String? userId;
  const ActivityFeed({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(userId: userId,), //putting in nav bar
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "Activity Feed",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}