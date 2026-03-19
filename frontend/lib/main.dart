import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
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

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'JustDropd',
              style: GoogleFonts.pacifico(
                fontSize: 44,
                color: const Color(0xFFFF8AD2),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xFFFF8AD2),
                ),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                padding: WidgetStateProperty.all(
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                ),
              ),
              child: const Text(
                'Login with Spotify',
                style: TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                await launchUrl(
                  spotifyLoginUrl,
                  mode: LaunchMode.platformDefault,
                  webOnlyWindowName: '_self',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}