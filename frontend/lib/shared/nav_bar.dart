import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../pages/activity_feed.dart';
import '../pages/countdown.dart';

class CustomNavBar extends StatelessWidget {
  final String? userId;
  const CustomNavBar({super.key, required this.userId});

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ActivityFeed(userId: userId,), //reroute to activity feed once pressed
                ),
              );
            },
            icon: SvgPicture.asset('assets/home_btn.svg', width: 40),
          ),
          IconButton(
            onPressed: () {
              print("Countdown tapped"); // DEBUGGING ONLY
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CountdownPage(userId: userId), //reroute to countdown page once pressed
                ),
              );
            },
            icon: SvgPicture.asset('assets/countdown_btn.svg', width: 40),
          ),
          IconButton(
            onPressed: () {
              print("Add tapped"); // DEBUGGING ONLY
              showModalBottomSheet( context: context, backgroundColor: Colors.white, 
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                builder: (context) {
                  return SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionTile(
                            title: "Add a mixtape",
                            onTap: () {
                              Navigator.pop(context); // close the sheet
                              print("Add a mixtape");
                            },
                          ),
                          _ActionTile(
                            title: "Add a review",
                            onTap: () {
                              Navigator.pop(context);
                              print("Add a review");
                            },
                          ),
                          _ActionTile(
                            title: "Add a countdown",
                            onTap: () {
                              Navigator.pop(context);
                              print("Add a countdown");
                            },
                          ),
                          _ActionTile(
                            title: "Add friends",
                            onTap: () {
                              Navigator.pop(context);
                              print("Add friends");
                            },
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: SvgPicture.asset('assets/add_btn.svg', width: 40),
          ),
          IconButton(
            onPressed: () {
              if (userId == null || userId!.isEmpty) {
                // If they somehow got here without an id, send them back to login/home
                Navigator.pushNamed(context, '/');
                return;
              }

              Navigator.pushNamed(
                context,
                '/createProfile?userId=${Uri.encodeComponent(userId!)}',
              );
            },
            icon: SvgPicture.asset('assets/profile_btn.svg', width: 40),
          ),
        ],
      ),
    );
  }
}

//action tile for the add button on nav bar
class _ActionTile extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: onTap,
    );
  }
}