import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  late Future<List<dynamic>> _receivedMixtapesFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUser();
    _receivedMixtapesFuture = _fetchReceivedMixtapes();
  }

  Future<List<dynamic>> _fetchReceivedMixtapes() async {
    final id = widget.userId;

    if (id == null || id.isEmpty) {
      throw Exception("Missing userId in route");
    }

    final uri = Uri.parse("http://localhost:3000/mixtapes/shelf/$id");

    final resp = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    if (resp.statusCode != 200) {
      throw Exception("Failed to load mixtapes: ${resp.statusCode} ${resp.body}");
    }

    final data = jsonDecode(resp.body);

    if (data is List) {
      return data;
    } else {
      throw Exception("Expected a list of mixtapes");
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
                  : const NetworkImage("https://placehold.co/156x158.png");

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
                          FutureBuilder<List<dynamic>>(
                            future: _receivedMixtapesFuture,
                            builder: (context, mixtapeSnapshot) {
                              if (mixtapeSnapshot.connectionState != ConnectionState.done) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: CircularProgressIndicator(),
                                );
                              }

                              if (mixtapeSnapshot.hasError) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "Error loading mixtapes: ${mixtapeSnapshot.error}",
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }

                              final acceptedMixtapes = mixtapeSnapshot.data ?? [];

                              if (acceptedMixtapes.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Text(
                                    "No accepted mixtapes yet.",
                                    style: TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                );
                              }

                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: acceptedMixtapes.map((mixtape) {
                                    final title = mixtape['title'] ?? 'Untitled Mixtape';

                                    final senderName =
                                        mixtape['creatorId'] is Map<String, dynamic>
                                            ? (mixtape['creatorId']['username'] ??
                                                mixtape['creatorId']['name'] ??
                                                'Unknown sender')
                                            : 'Unknown sender';

                                    final imageUrl =
                                        mixtape['cover_image_url'] != null &&
                                                mixtape['cover_image_url'].toString().isNotEmpty
                                            ? mixtape['cover_image_url']
                                            : 'https://placehold.co/136x136.png';

                                    final playlistUrl = mixtape['spotify_playlist_url'] ?? '';

                                    return Padding(
                                      padding: const EdgeInsets.only(right: 16),
                                      child: _MixtapeShelfCard(
                                        title: title,
                                        sender: '@$senderName',
                                        imageUrl: imageUrl,
                                        playlistUrl: playlistUrl,
                                      ),
                                    );
                                  }).toList(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
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
  final String playlistUrl;

  const _MixtapeShelfCard({
    required this.title,
    required this.sender,
    required this.imageUrl,
    required this.playlistUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        if (playlistUrl.isEmpty) return;

        final uri = Uri.parse(playlistUrl);
        await launchUrl(
          uri,
          mode: LaunchMode.platformDefault,
          webOnlyWindowName: '_blank',
        );
      },
      child: Container(
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
      ),
    );
  }
}