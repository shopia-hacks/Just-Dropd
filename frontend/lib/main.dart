import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import '../pages/profile_page.dart';

void main() {
  usePathUrlStrategy();

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateRoute: (settings) {
      final uri = Uri.parse(settings.name ?? '/');

      switch (uri.path) {
        case '/':
          return MaterialPageRoute(builder: (_) => const HomeRoute());

        case '/profile':
          return MaterialPageRoute(
            builder: (_) => CreateProfileRoute(
              userId: uri.queryParameters['userId'] ?? '',
            ),
          );

        case '/createProfile':
          return MaterialPageRoute(
            builder: (_) => CreateProfileRoute(
              userId: uri.queryParameters['userId'],
            ),
          );

        default:
          return MaterialPageRoute(builder: (_) => const HomeRoute());
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('JustDropd'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(Colors.green),
            foregroundColor: WidgetStateProperty.all(Colors.white),
          ),
          child: const Text('Login with Spotify'),
          onPressed: () async {
            await launchUrl(
              spotifyLoginUrl,
              mode: LaunchMode.platformDefault,
              webOnlyWindowName: '_self',
            );
          },
        ),
      ),
    );
  }
}