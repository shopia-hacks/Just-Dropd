import 'package:flutter/material.dart';
import 'package:just_dropd/shared/nav_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

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
          return MaterialPageRoute(builder: (_) => const CreateProfileRoute());

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
                  Navigator.pushNamed(context, '/createProfile');
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

//------------------- CREATE PROFILE PAGE------------------
class CreateProfileRoute extends StatelessWidget {
  const CreateProfileRoute({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: 551,
        height: 225,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: Colors.white),
        child: Stack(
            children: [
                Positioned(
                    left: 248,
                    top: 152,
                    child: SizedBox(
                        width: 283,
                        height: 30,
                        child: Text(
                            'Hi I’m Gabi! This is my bio',
                            style: TextStyle(
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
                            '@gabisusername',
                            style: TextStyle(
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
                            'Gabi',
                            style: TextStyle(
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
                                image: NetworkImage("https://placehold.co/156x158"),
                                fit: BoxFit.cover,
                            ),
                            shape: OvalBorder(),
                        ),
                    ),
                ),
            ],
        ),
      ),
      bottomNavigationBar: CustomNavBar(),
    );
  }

  
}