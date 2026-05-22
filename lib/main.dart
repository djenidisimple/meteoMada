import 'package:flutter/material.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ToeranaApp());
}

class ToeranaApp extends StatelessWidget {
  const ToeranaApp({super.key});

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
      child: Consumer<UtilisateurProvider>(
        builder: (context, up, _) {
          Locale locale;
          switch (up.utilisateur?.languePreferee) {
            case 'en': locale = const Locale('en'); break;
            case 'mg': locale = const Locale('mg'); break;
            default: locale = const Locale('fr');
          }
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Toerana',
            locale: locale,
            supportedLocales: const [
              Locale('fr'),
              Locale('en'),
              Locale('mg'),
            ],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: appRouter,
          );
        },
      ),
    );
  }
}
