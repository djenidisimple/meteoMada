import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/providers/utilisateur_provider.dart';

class PlusScreen extends StatelessWidget {
  const PlusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WeatherGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('Explorer',
                    style: AppTheme.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                const SizedBox(height: 4),
                Text('Fonctionnalités avancées',
                    style: AppTheme.poppins(
                        fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 24),
                Consumer2<AlerteProvider, UtilisateurProvider>(
                  builder: (context, ap, up, _) {
                    final countActives = ap.countActives;
                    final type = up.utilisateur?.typeUtilisateur ?? 'citoyen';
                    final isAgri = type == 'agriculteur';

                    final cards = <_MenuCard>[
                      _MenuCard(
                        icon: '🌀',
                        title: 'Alertes Cyclones',
                        subtitle: countActives > 0
                            ? '$countActives active(s)'
                            : 'Suivi en temps réel',
                        decoration: AppTheme.dangerCard,
                        onTap: () => context.push('/plus/alertes'),
                      ),
                      _MenuCard(
                        icon: '🌾',
                        title: 'Calendrier Cultural',
                        subtitle: 'Conseils semis & récolte',
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.accentGreen.withValues(alpha: 0.28),
                              width: 0.8),
                        ),
                        onTap: () => context.push('/plus/calendrier'),
                        priority: isAgri,
                      ),
                      _MenuCard(
                        icon: '📊',
                        title: 'Comparer Régions',
                        subtitle: 'Températures & humidité',
                        decoration: BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: AppTheme.accentBlue.withValues(alpha: 0.35),
                              width: 0.8),
                        ),
                        onTap: () => context.push('/plus/comparaison'),
                      ),
                      _MenuCard(
                        icon: '⚙️',
                        title: 'Paramètres',
                        subtitle: 'Langue, unités, profil',
                        decoration: AppTheme.glassCard,
                        onTap: () => context.push('/plus/settings'),
                      ),
                    ];

                    cards.sort((a, b) {
                      if (a.priority && !b.priority) return -1;
                      if (!a.priority && b.priority) return 1;
                      return 0;
                    });

                    return GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cards.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.95,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemBuilder: (_, i) => cards[i],
                    );
                  },
                ),
              ],
            ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;
  final BoxDecoration decoration;
  final VoidCallback onTap;
  final bool priority;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.decoration,
    required this.onTap,
    this.priority = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                  child: Text(icon, style: const TextStyle(fontSize: 18))),
            ),
            const Spacer(),
            Text(title,
                style: AppTheme.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}
