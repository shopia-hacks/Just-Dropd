import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomNavBar extends StatelessWidget {
  const CustomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 92,
      padding: const EdgeInsets.symmetric(horizontal: 300),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: Colors.black.withValues(alpha: 0.10),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () {
              print("Home tapped"); // DEBUGGING ONLY
            },
            icon: SvgPicture.asset('assets/home_btn.svg', width: 40),
          ),
          IconButton(
            onPressed: () {
              print("Countdown tapped"); // DEBUGGING ONLY
            },
            icon: SvgPicture.asset('assets/countdown_btn.svg', width: 40),
          ),
          IconButton(
            onPressed: () {
              print("Add tapped"); // DEBUGGING ONLY
            },
            icon: SvgPicture.asset('assets/add_btn.svg', width: 40),
          ),
          IconButton(
            onPressed: () {
              print("Profile tapped"); // DEBUGGING ONLY
            },
            icon: SvgPicture.asset('assets/profile_btn.svg', width: 40),
          ),
        ],
      ),
    );
  }
}