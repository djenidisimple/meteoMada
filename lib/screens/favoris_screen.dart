import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/weather_gradient_bg.dart';
import 'package:meteomada/widgets/city_favori_card.dart';
import 'package:meteomada/widgets/custom_switch.dart';
import 'package:meteomada/providers/favoris_provider.dart';
import 'package:meteomada/widgets/loading_view.dart';

class FavorisScreen extends StatelessWidget {
  const FavorisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WeatherGradientBg(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push('/favoris/search'),
          backgroundColor: AppTheme.accentBlue,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
        body: Consumer<FavorisProvider>(
            builder: (context, fp, _) {
              final favoris = fp.favoris;
              if (fp.chargement) {
                return const LoadingView(message: "Chargement des favoris...");
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mes Favoris',
                                style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white)),
                            Text('${favoris.length} · Glisser',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: AppTheme.textSecondary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (favoris.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppTheme.accentBlue.withOpacity(0.10),
                                border: Border.all(
                                    color: AppTheme.accentBlue.withOpacity(0.20)),
                              ),
                              child: const Center(
                                  child: Text('⭐', style: TextStyle(fontSize: 26))),
                            ),
                            const SizedBox(height: 16),
                            Text('Aucun favori',
                                style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                            const SizedBox(height: 6),
                            Text('Ajoutez des villes en favori\npour les retrouver rapidement',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: AppTheme.textSecondary)),
                            const SizedBox(height: 20),
                            InkWell(
                              onTap: () => context.push('/favoris/search'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22, vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: [
                                        AppTheme.accentBlue,
                                        AppTheme.accentBlueLight
                                      ]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text('🔍 Ajouter une ville',
                                    style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: favoris.length,
                        onReorder: (oldIndex, newIndex) {
                          if (newIndex > oldIndex) newIndex--;
                          fp.reordonner(oldIndex, newIndex);
                        },
                        itemBuilder: (context, index) {
                          final item = favoris[index];
                          return Dismissible(
                            key: ValueKey(item.favori.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.accentRed.withOpacity(0.20),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              child: const Icon(Icons.delete_outline_rounded,
                                  color: AppTheme.accentRed, size: 22),
                            ),
                            confirmDismiss: (_) async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: AppTheme.backgroundDark,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  title: Text('Retirer des favoris ?',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: Text('Annuler',
                                          style:
                                              TextStyle(color: AppTheme.textSecondary)),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: Text('Retirer',
                                          style: TextStyle(color: AppTheme.accentRed)),
                                    ),
                                  ],
                                ),
                              );
                              if (confirmed == true) {
                                fp.supprimer(item.favori.id);
                              }
                              return false;
                            },
                            child: ReorderableDragStartListener(
                              index: index,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: InkWell(
                                      onTap: () =>
                                          context.push('/detail/${item.ville.id}'),
                                      child: CityFavoriCard(
                                        ville: item.ville,
                                        favori: item.favori,
                                        temperature:
                                            item.prevision?.temperature ?? 27,
                                        condition: item.prevision?.condition ??
                                            'Partiellement nuageux',
                                        isDefault: index == 0,
                                        trailing: Padding(
                                          padding: const EdgeInsets.only(left: 8),
                                          child: CustomSwitch(
                                            value: item.favori.notificationsActives,
                                            activeColor: AppTheme.accentBlue,
                                            onChanged: () => fp.basculerNotifications(item.favori.id),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  if (favoris.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                                color: Colors.white.withOpacity(0.06), height: 1),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text('⠿ Maintenir pour réordonner',
                                style: TextStyle(
                                    fontSize: 10, color: AppTheme.textDim)),
                          ),
                          Expanded(
                            child: Divider(
                                color: Colors.white.withOpacity(0.06), height: 1),
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
    );
  }
}
