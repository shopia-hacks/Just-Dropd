import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
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
              onPressed: () {
                //pushes a new screen onto the navigation stack
                //uses the route name defined in MaterialApp above
                Navigator.pushNamed(context, '/login');
              },
            )
          )// ElevatedButton
    );
  }
}

// ---------------------- LOGIN PAGE ---------------------
class LoginRoute extends StatelessWidget {
  const LoginRoute({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
      ), // AppBar
    ); // Scaffold
  }
}