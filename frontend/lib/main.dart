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

//------------------- CREATE PROFILE PAGE (Profile Page?)------------------
class CreateProfileRoute extends StatefulWidget {

  final String? userId; //using the passed in id from login route page to get this specific user from MongoDB
  
  const CreateProfileRoute({super.key, this.userId});

  @override
  State<CreateProfileRoute> createState() => _CreateProfileRouteState();
}

class _CreateProfileRouteState extends State<CreateProfileRoute> {

  //this stores future result of the api call, will eventually get user data from mongoDB
  //supposed to use FutureMap, FutureBuilder, _fetchUser, etc when we want to pull data from mongoDB
  //these methods will be good for when we add in editable things like changing bio, name, etc
  late Future<Map<String, dynamic>> _userFuture;

  @override
  void initState() {
    super.initState();
    //start fetching user on this line
    _userFuture = _fetchUser();
  }

  //calls the backend to get the user from MongoDB
  Future<Map<String, dynamic>> _fetchUser() async {
    final id = widget.userId; //passing userid to widget

    //if user id is missing something went wrong when being passed from login route
    if (id == null || id.isEmpty) {
      throw Exception("Missing userId in route");
    }

    final uri = Uri.parse("http://localhost:3000/users/$id");

    //sends a get request to the backend
    final resp = await http.get(uri, headers: {
      "Content-Type": "application/json",
    });

    //if can't get from backend then throw error
    if (resp.statusCode != 200) {
      throw Exception("Failed to load user: ${resp.statusCode} ${resp.body}");
    }
    //converting the json from what we got from the backend into dart form for UI
    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomNavBar(userId: widget.userId,), //putting in nav bar
      body: FutureBuilder<Map<String, dynamic>>( //future builder waits for _useruFture to be done
        future: _userFuture,
        builder: (context, snapshot) {

          //if the user data is still loading from database, shows a spinner
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) { //if something went wrong when loading show error
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final user = snapshot.data!; //data successfully loaded, getting user info
          final name = (user['name'] ?? 'User') as String;
          final username = (user['username'] ?? '') as String;

          final profileImageUrl = user['profile_photo_url'] as String?;

          //if user has a spotify pfp then we use it, otherwise we can use a placeholder image
          final imageProvider = (profileImageUrl != null && profileImageUrl.isNotEmpty)
              ? NetworkImage(profileImageUrl)
              : const NetworkImage("https://placehold.co/156x158");

          //building the UI using the fetched data above
          return Container(
            width: 551,
            height: 225,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(color: Colors.white),
            child: Stack(
              children: [
                Positioned(
                  left: 248,
                  top: 152,
                  child: SizedBox(
                    width: 283,
                    height: 30,
                    child: Text(
                      'Hi I’m $name! This is my bio',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 248,
                  top: 112,
                  child: SizedBox(
                    width: 306,
                    height: 27,
                    child: Text(
                      '@$username',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 248,
                  top: 60,
                  child: SizedBox(
                    width: 375,
                    height: 57,
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 55,
                  top: 38,
                  child: Container(
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}