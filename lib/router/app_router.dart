import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/bottom_nav_bar.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/screens/splash_screen.dart';
import 'package:meteomada/screens/onboarding_screen.dart';
import 'package:meteomada/screens/home_screen.dart';
import 'package:meteomada/screens/favoris_screen.dart';
import 'package:meteomada/screens/plus_screen.dart';
import 'package:meteomada/screens/detail_screen.dart';
import 'package:meteomada/screens/hourly_screen.dart';
import 'package:meteomada/screens/forecast_screen.dart';
import 'package:meteomada/screens/marine_screen.dart';
import 'package:meteomada/screens/recherche_screen.dart';
import 'package:meteomada/screens/alertes_screen.dart';
import 'package:meteomada/screens/historique_alertes_screen.dart';
import 'package:meteomada/screens/calendrier_screen.dart';
import 'package:meteomada/screens/parametres_screen.dart';
import 'package:meteomada/screens/comparaison_screen.dart';
import 'package:meteomada/screens/map_screen.dart';

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/favoris')) {
      _currentIndex = 1;
    } else if (loc.startsWith('/carte')) {
      _currentIndex = 2;
    } else if (loc.startsWith('/plus')) {
      _currentIndex = 3;
    } else {
      _currentIndex = 0;
    }
  }

  void _onTab(int index) {
    setState(() => _currentIndex = index);
    switch (index) {
      case 0: context.go('/home');
      case 1: context.go('/favoris');
      case 2: context.go('/carte');
      case 3: context.go('/plus');
    }
  }

  @override
  Widget build(BuildContext context) {
    final alerte = context.watch<AlerteProvider>();
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: Column(
        children: [
          Expanded(child: widget.child),
          BottomNavBar(
            currentIndex: _currentIndex,
            onTap: _onTab,
            hasActiveAlerte: alerte.countActives > 0,
          ),
        ],
      ),
    );
  }
}

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingScreen()),
    ShellRoute(
      builder: (_, __, child) => AppShell(child: child),
      routes: [
        GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
        GoRoute(
          path: '/favoris',
          builder: (_, __) => const FavorisScreen(),
          routes: [
            GoRoute(path: 'search', builder: (_, __) => const RechercheScreen()),
          ],
        ),
        GoRoute(path: '/carte', builder: (_, __) => const MapScreen()),
        GoRoute(
          path: '/plus',
          builder: (_, __) => const PlusScreen(),
          routes: [
            GoRoute(path: 'alertes', builder: (_, __) => const AlertesScreen()),
            GoRoute(path: 'historique', builder: (_, __) => const HistoriqueAlertesScreen()),
            GoRoute(path: 'calendrier', builder: (_, __) => const CalendrierScreen()),
            GoRoute(path: 'comparaison', builder: (_, __) => const ComparaisonScreen()),
            GoRoute(path: 'settings', builder: (_, __) => const ParametresScreen()),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/home/detail/:villeId',
      builder: (_, state) => DetailScreen(
        villeId: state.pathParameters['villeId']!,
      ),
    ),
    GoRoute(
      path: '/home/hourly/:villeId',
      builder: (_, state) => HourlyScreen(
        villeId: state.pathParameters['villeId']!,
      ),
    ),
    GoRoute(
      path: '/home/forecast/:villeId',
      builder: (_, state) => ForecastScreen(
        villeId: state.pathParameters['villeId']!,
      ),
    ),
    GoRoute(
      path: '/home/marine/:villeId',
      builder: (_, state) => MarineScreen(
        villeId: state.pathParameters['villeId']!,
      ),
    ),
    GoRoute(path: '/recherche', builder: (_, __) => const RechercheScreen()),
    GoRoute(path: '/alertes', builder: (_, __) => const AlertesScreen()),
    GoRoute(path: '/calendrier', builder: (_, __) => const CalendrierScreen()),
    GoRoute(path: '/parametres', builder: (_, __) => const ParametresScreen()),
    GoRoute(path: '/comparaison', builder: (_, __) => const ComparaisonScreen()),
  ],
);
