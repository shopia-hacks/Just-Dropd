import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/profile_page.dart';

// theme
import 'theme/theme.dart';

void main() {
  usePathUrlStrategy();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    onGenerateRoute: (settings) {
      final uri = Uri.parse(settings.name ?? '/');

      switch (uri.path) {
        case '/':
          return MaterialPageRoute(builder: (_) => const HomeRoute());

        case '/profile':
          return MaterialPageRoute(
            builder: (_) => CreateProfileRoute(
              userId: uri.queryParameters['userId'],
            ),
          );

        case '/createProfile': //profile page (after you are logged in/inserted into MongoDB)
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

final Uri spotifyLoginUrl = Uri.parse("https://api.justdropd.com/login");

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
              onPressed: () async {
                await launchUrl(
                  spotifyLoginUrl,
                  mode: LaunchMode.platformDefault,
                  webOnlyWindowName: '_self',
                );
              },
              child: const Text('Login with Spotify'),
            ),
          ],
        ),
      ),
    );
  }
}