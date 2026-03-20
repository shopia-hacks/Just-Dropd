import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_dropd/services/api_service.dart';

void main() {
  usePathUrlStrategy();
  //entry point of every flutter app here
  //runApp tells Flutter what widget to display
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,

    onGenerateRoute: (settings) {
      final uri = Uri.parse(settings.name ?? '/');

      switch (uri.path) { //switch statement to pass in userid, name, etc to the pages
        case '/':
          return MaterialPageRoute(builder: (_) => const HomeRoute()); //regular home page w/ spotify login

        case '/login': //login page is for after logging in/authorization
          return MaterialPageRoute(
            builder: (_) => LoginRoute( //passing in params to the page
              userId: uri.queryParameters['userId'],
              name: uri.queryParameters['name'],
              isNew: uri.queryParameters['isNew'],
            ),
          );

        case '/createProfile': //create profile page (after you are logged in/inserted into MongoDB)
          return MaterialPageRoute(
            builder: (_) => CreateProfileRoute(
              userId: uri.queryParameters['userId'],
            ),
          );

        case '/profile': //profile page (after you are logged in/inserted into MongoDB)
          return MaterialPageRoute(
            builder: (_) => CreateProfileRoute(
              userId: uri.queryParameters['userId'],
            ),
          );

        default:
          return MaterialPageRoute(builder: (_) => const HomeRoute()); //default is the home page
      }
    },
  ));
}

final Uri spotifyLoginUrl = Uri.parse("http://localhost:3000/login");

// -------------------- HOME PAGE ---------------------
class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( //Scaffold gives a basic page layout, app bar, body, buttons, etc
      appBar: AppBar(
        title: const Text('JustDropd'), //app bar title
        backgroundColor: Colors.green, //app bar background
        foregroundColor: Colors.white, //text and icon colors
      ), // AppBar

      
      body: Center( //centers the buttons on the screen
        child: 
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green), //custom background color
                  foregroundColor: WidgetStateProperty.all(Colors.white)), //custom text color
              
              //text shown on the button
              child: const Text('Login with Spotify'),

              //what happens when the button is pressed
              onPressed: () async {
                //pushes a new screen onto the navigation stack
                //uses the route name defined in MaterialApp above
                await launchUrl(spotifyLoginUrl, mode: LaunchMode.platformDefault, webOnlyWindowName: '_self');
              },
            )
          )// ElevatedButton
    );
  }
}

// ---------------------- LOGIN PAGE ---------------------
// page is what spotify redirects back to after login
// url will look like: localhost"5500/login?userId=123&name=Jon
class LoginRoute extends StatelessWidget {

  final String? userId;
  final String? name;
  final String? isNew;

  const LoginRoute({super.key, this.userId, this.name, this.isNew});

  @override
  Widget build(BuildContext context) {
    // read URL parameters that the backend sent back
    final uri = Uri.base;
    final userId = uri.queryParameters['userId'];
    final name = uri.queryParameters['name'];
    
    // if userId exists in the URL, login was successful
    if (userId != null) {
      // Login worked! Show success and go to profile
      return Scaffold(
        appBar: AppBar(
          title: const Text("Login Page"),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Welcome, ${name ?? 'User'}! ✅",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 8),
              Text(
                "MongoDB ID: $userId",
                style: const TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 255, 255, 255),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.green),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: const Text('Go to Profile'),
                onPressed: () {
                  Navigator.pushNamed(context, '/createProfile?userId=$userId');
                },
              ),
            ],
          ),
        ),
      );
    }
    
    // If no userId in URL, something went wrong
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Login incomplete. Please try again."),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.green),
                foregroundColor: WidgetStateProperty.all(Colors.white),
              ),
              child: const Text('Back to Home'),
              onPressed: () {
                Navigator.pushNamed(context, '/');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/*
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login Page"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ), // AppBar
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.green),
              foregroundColor: WidgetStateProperty.all(Colors.white)),
          child: const Text('Create Profile'), 
          onPressed: () {
            Navigator.pushNamed(context, '/createProfile');
          },
        ), // ElevatedButton
      ), // Center
    ); // Scaffold
  }
}
*/

//------------------- CREATE PROFILE PAGE (Profile Page)------------------
class CreateProfileRoute extends StatefulWidget {
  final String? userId;

  const CreateProfileRoute({super.key, this.userId});

  @override
  State<CreateProfileRoute> createState() => _CreateProfileRouteState();
}

class _CreateProfileRouteState extends State<CreateProfileRoute> {
  late Future<Map<String, dynamic>> _userFuture;
  List<dynamic> concertReviews = [];

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
    _loadConcertReviews();
  }

  Future<void> _loadConcertReviews() async {
    if (widget.userId == null) return;
    try {
      final reviews = await ApiService.fetchConcertReviews(widget.userId!);
      setState(() {
        concertReviews = reviews;
      });
    } catch (e) {
      print("Error fetching concert reviews: $e");
    }
  }

  Future<Map<String, dynamic>> _fetchUser() async {
    final id = widget.userId;

    if (id == null || id.isEmpty) {
      throw Exception("Missing userId in route");
    }

    final uri = Uri.parse("http://localhost:3000/users/$id");

    final resp = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    if (resp.statusCode != 200) {
      throw Exception("Failed to load user: ${resp.statusCode} ${resp.body}");
    }

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavBar(userId: widget.userId),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final user = snapshot.data!;
          final name = (user['name'] ?? 'User') as String;
          final username = (user['username'] ?? '') as String;
          final bio = (user['bio'] ?? "Hi I’m $name! This is my bio") as String;
          final profileImageUrl = user['profile_photo_url'] as String?;

          final imageProvider =
              (profileImageUrl != null && profileImageUrl.isNotEmpty)
                  ? NetworkImage(profileImageUrl)
                  : const NetworkImage("https://placehold.co/156x158");

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ================= PROFILE HEADER CARD =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 156,
                            height: 158,
                            decoration: ShapeDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                              shape: const OvalBorder(),
                            ),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 36,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '@$username',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  bio,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ================= RECEIVED MIXTAPES SECTION =================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFD9D9D9)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Received Mixtapes",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 24,
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                        
                          // placeholder shelf row for now
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Text(
                              "No accepted mixtapes yet.",
                              style: TextStyle(color: Colors.black54, fontSize: 16),
                            ),
                          ),

                        ],
                      ),
                    ),

                    // ================= MY CONCERT REVIEWS SECTION =================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text("My Concert Reviews",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w400),
                      ),
                    ),

                    concertReviews.isEmpty
                      ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text("No concert reviews yet."),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: concertReviews.length,
                      itemBuilder: (context, index) {
                        final review = concertReviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          child: Padding(padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start, 
                              children: [
                                Text(review['artist_name'] ?? '', 
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(review['title'] ?? '',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text("Location: ${review['location'] ?? ''}"), 
                                Text("Date: ${review['date']?.toString().substring(0,10) ?? ''}"),
                                Text("${review['rating'] ?? ''}"),
                                const SizedBox(height: 8),
                                Text(review['review_text'] ?? ''),

                                if ((review['image_urls'] as List?)?.isNotEmpty ?? false)
                                  SizedBox(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: (review['image_urls'] as List).length,
                                      itemBuilder: (context, imgIndex) {
                                        final imageUrl = "http://localhost:3000/${review['image_urls'][imgIndex]}";
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 8),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              imageUrl,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.broken_image, size: 40),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ), 
    );
  }
}

// reusable little card for the shelf section
class _MixtapeShelfCard extends StatelessWidget {
  final String title;
  final String sender;
  final String imageUrl;

  const _MixtapeShelfCard({
    required this.title,
    required this.sender,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        border: Border.all(color: const Color(0xFFD9D9D9)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              imageUrl,
              width: 136,
              height: 136,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sender,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
