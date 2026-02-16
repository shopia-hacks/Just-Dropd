import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

void main() {
  usePathUrlStrategy();
  //entry point of every flutter app here
  //runApp tells Flutter what widget to display first
  runApp(MaterialApp(
    initialRoute: '/', //first route (screen) shown
    //named routes for navigation
    routes: {
      '/': (context) => const HomeRoute(), //home page
      '/login': (context) => const LoginRoute(), //login page
      '/createProfile': (context) => const CreateProfileRoute(), //profile page?
    },
    debugShowCheckedModeBanner: false,
  )); //MaterialApp
}

final Uri spotifyLoginUrl = Uri.parse("http://localhost:3000/login");

// -------------------- HOME PAGE ---------------------
class HomeRoute extends StatelessWidget {
  const HomeRoute({Key? key}) : super(key: key);

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
                await launchUrl(spotifyLoginUrl, mode: LaunchMode.externalApplication);
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
  const LoginRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // read URL parameters that the backend sent back
    final uri = Uri.base;
    final userId = uri.queryParameters['userId'];
    final name = uri.queryParameters['name'];
    
    // if userId exists in the URL, login was successful
    // If userId exists in the URL, login was successful
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
                  color: Colors.grey,
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
                  Navigator.pushNamed(context, '/createProfile');
                },
              ),
            ],
          ),
        ),
      );
    }

    // if no userId in URL, something went wrong
    
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

//------------------- CREATE PROFILE PAGE------------------
class CreateProfileRoute extends StatelessWidget {
  const CreateProfileRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Profile Page"),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text("Welcome to JustDropd! 🎵"),
      ), // AppBar
    ); // Scaffold
  }
}