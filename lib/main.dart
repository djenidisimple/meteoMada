import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:meteomada/router/app_router.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/providers/favoris_provider.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/providers/calendrier_provider.dart';
import 'package:meteomada/providers/utilisateur_provider.dart';
import 'package:meteomada/providers/marine_provider.dart';
import 'package:meteomada/l10n/app_localizations.dart';
import 'package:meteomada/database/database_helper.dart';
import 'package:meteomada/services/notification_service.dart';
import 'package:meteomada/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    await DatabaseHelper().database;
    await NotificationService().initialiser();
  } catch (_) {
    runApp(_ErrorApp());
    return;
  }
  runApp(const MeteoMadaApp());
}

class _ErrorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: AppTheme.backgroundDark,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('⚠️', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 16),
                Text(
                  'Erreur au démarrage',
                  style: AppTheme.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'Veuillez redémarrer l\'application.',
                  style: AppTheme.poppins(
                      fontSize: 13, color: AppTheme.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MeteoMadaApp extends StatelessWidget {
  const MeteoMadaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()..initialiser()),
        ChangeNotifierProvider(create: (_) => AlerteProvider()..initialiser()),
        ChangeNotifierProvider(create: (_) => CalendrierProvider()),
        ChangeNotifierProvider(
            create: (_) => UtilisateurProvider()..initialiser()),
        ChangeNotifierProvider(create: (_) => MarineProvider()),
        ChangeNotifierProvider(
            create: (ctx) =>
                FavorisProvider()..initialiser(ctx.read<UtilisateurProvider>().userId)),
      ],
      child: const _ToeranaApp(),
    );
  }
}

class _ToeranaApp extends StatelessWidget {
  const _ToeranaApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Toerana',
      locale: const Locale('fr'),
      supportedLocales: const [
        Locale('fr'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter,
    );
  }
}
