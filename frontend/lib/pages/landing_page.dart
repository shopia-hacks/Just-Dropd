import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme.dart';

final Uri _spotifyLoginUrl = Uri.parse("https://api.justdropd.com/login");

Future<void> _launchSpotifyLogin() async {
  await launchUrl(
    _spotifyLoginUrl,
    mode: LaunchMode.platformDefault,
    webOnlyWindowName: '_self',
  );
}

// ─── Feature data ─────────────────────────────────────────────────────────────
// Icons come from Flutter's built-in Material Icons — no extra package needed.
// Browse every available icon at: https://fonts.google.com/icons
// Usage is always: Icon(Icons.icon_name_here)

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final Color bg;
  final Color fg;

  const _Feature({
    required this.icon,
    required this.title,
    required this.description,
    required this.bg,
    required this.fg,
  });
}

const List<_Feature> _features = [
  _Feature(
    icon: Icons.queue_music_rounded,   // browse more at fonts.google.com/icons
    title: 'Mixes',
    description:
        'Build a personalized playlist for a friend, design a custom cover, '
        'and send it their way. It lands directly on Spotify.',
    bg: AppTheme.green,
    fg: AppTheme.pink,
  ),
  _Feature(
    icon: Icons.library_music_rounded,
    title: 'The Shelf',
    description:
        'Every mix you receive lives on your shelf — a public collection of '
        'playlists people have made just for you.',
    bg: AppTheme.yellow,
    fg: AppTheme.orange,
  ),
  _Feature(
    icon: Icons.timer_rounded,
    title: 'Countdowns',
    description:
        'Set a clock ticking toward the album or single you\'re most '
        'hyped about. Bond with friends over the same release.',
    bg: AppTheme.red,
    fg: AppTheme.pink,
  ),
  _Feature(
    icon: Icons.star_rounded,
    title: 'Reviews',
    description:
        'Rate albums you\'ve listened to and concerts you\'ve attended. '
        'Your reviews show up on your shelf for friends to explore.',
    bg: AppTheme.blue,
    fg: AppTheme.yellow,
  ),
];

// ─── Team data ────────────────────────────────────────────────────────────────
// Photos: add your images to assets/images/ in your project root, then declare
// them in pubspec.yaml like so:
//
//   flutter:
//     assets:
//       - assets/images/kenzie.jpg
//       - assets/images/sophia.jpg
//       - assets/images/gabi.jpg
//
// Then set imagePath below to the matching string, e.g. 'assets/images/kenzie.jpg'
// If the file doesn't exist yet, the card will show a colored circle placeholder.

class _TeamMember {
  final String name;
  final String role;
  final String? imagePath; // set to e.g. 'assets/images/kenzie.jpg' when ready
  final Color bg;
  final Color fg;

  const _TeamMember({
    required this.name,
    required this.role,
    this.imagePath,
    required this.bg,
    required this.fg,
  });
}

const List<_TeamMember> _team = [
  _TeamMember(
    name: 'Kenzie Mcallister',
    role: 'Backend & API Integration',
    imagePath: 'assets/photos/kenzie.jpg', 
    bg: AppTheme.blue,
    fg: AppTheme.green,
  ),
  _TeamMember(
    name: 'Sophia Martin',
    role: 'Frontend, UI & Marketing',
    imagePath: 'assets/photos/sophia.jpg', // replace with 'assets/images/sophia.jpg'
    bg: AppTheme.pink,
    fg: AppTheme.red,
  ),
  _TeamMember(
    name: 'Jessica Xie',
    role: 'Backend & Usability Testing',
    imagePath: 'assets/photos/jessica.jpg', // replace with 'assets/images/gabi.jpg'
    bg: AppTheme.green,
    fg: AppTheme.blue,
  ),
  _TeamMember(
    name: 'Gabi Ramirez',
    role: 'Frontend & Usability Testing',
    imagePath: 'assets/photos/gabi.jpeg', // replace with 'assets/images/gabi.jpg'
    bg: AppTheme.yellow,
    fg: AppTheme.orange,
  ),
];

// ─── HomeRoute ────────────────────────────────────────────────────────────────

class HomeRoute extends StatelessWidget {
  const HomeRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _NavBar(),
            _HeroSection(),
            _FeaturesSection(),   // horizontal scroll
            _LoginCTASection(),   // big login button
            _TeamSection(),
            _Footer(),
          ],
        ),
      ),
    );
  }
}

// ─── Nav Bar ──────────────────────────────────────────────────────────────────

class _NavBar extends StatelessWidget {
  const _NavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.orange.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'JUST DROPD',
            style: GoogleFonts.rubikDirt(
              fontSize: 24,
              color: AppTheme.red,
            ),
          ),
          ElevatedButton(
            onPressed: _launchSpotifyLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.yellow,
              foregroundColor: AppTheme.orange,
            ),
            child: const Text('Login with Spotify'),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 650;

    return Container(
      width: double.infinity,
      // Solid brand color background to make the hero pop
      color: AppTheme.pink,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 24 : 64,
        vertical: isNarrow ? 56 : 80,
      ),
      child: Column(
        children: [
          Text(
            'JUST DROPD',
            style: GoogleFonts.rubikDirt(
              fontSize: isNarrow ? 56 : 88,
              color: AppTheme.red,
              height: 1.0,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Mix. Cue. Connect.',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.blue,
                  fontSize: isNarrow ? 20 : 26,
                  letterSpacing: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Text(
              'Music used to be personal... burned CDs, mixtapes for your crush, '
              'friendships forged over tracklists. Just Dropd brings that back. '
              'No follower counts. No anxiety. Just good music, shared with the '
              'people who matter.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.green,
                    fontWeight: FontWeight.w500,
                    height: 1.7,
                    fontSize: isNarrow ? 15 : 17,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _launchSpotifyLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 18),
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              backgroundColor: AppTheme.orange,
              foregroundColor: AppTheme.pink,
            ),
            child: const Text('Login with Spotify'),
          ),
        ],
      ),
    );
  }
}

// ─── Features Section — horizontal scroll ─────────────────────────────────────

class _FeaturesSection extends StatelessWidget {
  const _FeaturesSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      // Distinct background: dark blue strip so cards really pop
      color: AppTheme.blue.withOpacity(0.15),
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              'What you can do',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.green,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          // Horizontally scrolling row of cards
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 28),
              itemCount: _features.length,
              separatorBuilder: (_, __) => const SizedBox(width: 16),
              itemBuilder: (context, index) =>
                  _FeatureCard(feature: _features[index]),
            ),
          ),
          const SizedBox(height: 12),
          // Scroll hint
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              children: [
                Icon(Icons.swipe_rounded, size: 16, color: AppTheme.green.withOpacity(0.7)),
                const SizedBox(width: 6),
                Text(
                  'Scroll to explore',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.green.withOpacity(0.7),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final _Feature feature;

  const _FeatureCard({super.key, required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        color: feature.bg,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: feature.fg.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppLayout.radiusSm),
            ),
            child: Icon(feature.icon, color: feature.fg, size: 26),
          ),
          const SizedBox(height: 14),
          Text(
            feature.title,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: feature.fg,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              feature.description,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: feature.fg.withOpacity(0.85),
                height: 1.5,
              ),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Login CTA Section ────────────────────────────────────────────────────────

class _LoginCTASection extends StatelessWidget {
  const _LoginCTASection();

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 650;

    return Container(
      // Bright green background — visually distinct from the blue above and
      // cream below, draws the eye to the CTA
      color: AppTheme.green,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 24 : 64,
        vertical: 56,
      ),
      child: Column(
        children: [
          Text(
            'Ready to drop some music?',
            style: GoogleFonts.rubikDirt(
              fontSize: isNarrow ? 28 : 40,
              color: AppTheme.blue,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Connect your Spotify account and start sharing music the way it was meant to be.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.blue.withOpacity(0.85),
                  fontSize: isNarrow ? 14 : 16,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _launchSpotifyLogin,
            icon: const Icon(Icons.music_note_rounded, size: 22),
            label: const Text('Login with Spotify'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.blue,
              foregroundColor: AppTheme.green,
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 28 : 48,
                vertical: isNarrow ? 16 : 20,
              ),
              textStyle: TextStyle(
                fontSize: isNarrow ? 16 : 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Team Section ─────────────────────────────────────────────────────────────

class _TeamSection extends StatelessWidget {
  const _TeamSection();

  @override
  Widget build(BuildContext context) {
    final isNarrow = MediaQuery.of(context).size.width < 650;

    return Container(
      // Cream background — softer, feels like a profile/personal section
      color: AppTheme.yellow.withOpacity(0.5),
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 24 : 64,
        vertical: 64,
      ),
      child: Column(
        children: [
          Text(
            'Meet the Disk Jockeys',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Four Mizzou CS students who believe music is meant to be shared.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.blue,
                  fontSize: 15,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          LayoutBuilder(
            builder: (context, constraints) {
              double cardWidth = 260;
              // Prevent overflow on super small screens
              if (constraints.maxWidth < cardWidth) {
                cardWidth = constraints.maxWidth;
              }
              return Wrap(
                spacing: AppLayout.itemGap,
                runSpacing: AppLayout.itemGap,
                alignment: WrapAlignment.center,
                children: _team.map((m) {
                  return SizedBox(
                    width: cardWidth,
                    child: _TeamCard(member: m),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final _TeamMember member;

  const _TeamCard({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppLayout.cardPadding),
      decoration: BoxDecoration(
        // withOpacity(0.5) gives the 50% tint you asked for
        color: member.bg,
        borderRadius: BorderRadius.circular(AppLayout.radiusLg),
      ),
      child: Column(
        children: [
          // Photo circle — shows image if imagePath is set, otherwise a
          // colored placeholder. To add a photo:
          //   1. Put the file in assets/images/ in your project root
          //   2. Add it to pubspec.yaml under flutter > assets
          //   3. Change imagePath: null → imagePath: 'assets/images/name.jpg'
          ClipOval(
            child: member.imagePath != null
                ? Image.asset(
                    member.imagePath!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 120,
                    height: 120,
                    color: member.bg,
                    child: Icon(
                      Icons.person_rounded,
                      color: member.fg,
                      size: 40,
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Text(
            member.name,
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: member.fg,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            member.role,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: member.fg.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Footer ───────────────────────────────────────────────────────────────────

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.red,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Text(
            'JUST DROPD',
            style: GoogleFonts.rubikDirt(
              fontSize: 32,
              color: AppTheme.pink,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mix. Cue. Connect.',
            style: TextStyle(
              fontFamily: 'Georgia',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.pink,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _launchSpotifyLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.pink,
              foregroundColor: AppTheme.red,
            ),
            child: const Text('Login with Spotify'),
          ),
          const SizedBox(height: 24),
          const Text(
            '© 2026 Just Dropd · Disk Jockeys · Made at Mizzou',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.pink,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}