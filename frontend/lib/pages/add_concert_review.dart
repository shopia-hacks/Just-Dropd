import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';

class AddConcertReview extends StatelessWidget {
  final String? userId;
  const AddConcertReview({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CustomNavBar(userId: userId,), // nav bar
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          "Add a Concert Review",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}