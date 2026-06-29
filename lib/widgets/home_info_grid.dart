import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/shimmer_block.dart';
import 'package:meteomada/providers/home_state.dart';
import 'package:meteomada/providers/weather_provider.dart';
import 'package:meteomada/providers/marine_provider.dart';
import 'package:meteomada/providers/calendrier_provider.dart';
import 'package:meteomada/providers/alerte_provider.dart';
import 'package:meteomada/utils/weather_helper.dart';

/// Grille 2×2 affichée sur le HomeScreen entre le MetricStrip et le Hourly Forecast.
///
/// Affiche 4 blocs d'informations complémentaires :
/// - ☀️ Éphémérides (lever/coucher du soleil)
/// - 📊 Indice UV détaillé
/// - 🌀 Alertes cycloniques actives
/// - 🌊 Conditions marines (côtière) OU 🌱 Calendrier cultural (intérieur)
///
/// Chaque bloc réagit à l'état de son provider via [Consumer] :
/// - [HomeDataState.loading] → Shimmer animé
/// - [HomeDataState.success] → Vraies données
/// - [HomeDataState.error] → Message d'erreur clair
class HomeInfoGrid extends StatelessWidget {
  const HomeInfoGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Consumer3<WeatherProvider, AlerteProvider, MarineProvider>(
        builder: (context, weather, alerte, marine, _) {
          final ville = weather.villeActuelle;
          final estCotiere = ville?.estCotiere ?? false;

          return Column(
            children: [
              // ─── LIGNE 1 : Éphémérides + Indice UV ─────────────
              Row(
                children: [
                  Expanded(child: _buildEphemerideCard(weather)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildUVCard(weather)),
                ],
              ),
              const SizedBox(height: 10),
              // ─── LIGNE 2 : Alertes + Marine/Calendrier ─────────
              Row(
                children: [
                  Expanded(child: _buildAlerteCard(alerte)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: estCotiere
                        ? _buildMarineCard(marine)
                        : _buildCalendrierCard(context),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BLOC 1 : ÉPHÉMÉRIDES (Lever / Coucher du soleil)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildEphemerideCard(WeatherProvider weather) {
    final etat = weather.etat;
    final p = weather.previsionActuelle;

    return _InfoCard(
      etat: etat,
      erreurMessage: weather.erreur,
      accentColor: AppTheme.accentYellow,
      icon: Icons.wb_twilight_rounded,
      titre: 'Éphémérides',
      buildContent: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dataRow(
            Icons.wb_sunny_outlined,
            AppTheme.accentYellow,
            p?.leverSoleil.isNotEmpty == true ? p!.leverSoleil : '—',
            'Lever',
          ),
          const SizedBox(height: 6),
          _dataRow(
            Icons.nightlight_round_outlined,
            AppTheme.accentOrange,
            p?.coucherSoleil.isNotEmpty == true ? p!.coucherSoleil : '—',
            'Coucher',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BLOC 2 : INDICE UV DÉTAILLÉ
  // ═══════════════════════════════════════════════════════════════
  Widget _buildUVCard(WeatherProvider weather) {
    final etat = weather.etat;
    final p = weather.previsionActuelle;
    final uv = p?.indiceUV ?? 0;

    return _InfoCard(
      etat: etat,
      erreurMessage: weather.erreur,
      accentColor: WeatherHelper.uvColor(uv),
      icon: Icons.wb_sunny_outlined,
      titre: 'Indice UV',
      buildContent: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                uv.toStringAsFixed(1),
                style: AppTheme.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: WeatherHelper.uvColor(uv),
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  WeatherHelper.uvLabel(uv),
                  style: AppTheme.poppins(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Barre de progression UV
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: (uv / 11).clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation(WeatherHelper.uvColor(uv)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BLOC 3 : ALERTES CYCLONIQUES
  // ═══════════════════════════════════════════════════════════════
  Widget _buildAlerteCard(AlerteProvider alerte) {
    final etat = alerte.etat;
    final nbActives = alerte.countActives;

    return _InfoCard(
      etat: etat,
      erreurMessage: alerte.erreur,
      accentColor: nbActives > 0 ? AppTheme.accentRed : AppTheme.accentGreen,
      icon: nbActives > 0
          ? Icons.warning_amber_rounded
          : Icons.check_circle_outline_rounded,
      titre: 'Alertes',
      buildContent: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (nbActives > 0) ...[
            Text(
              '$nbActives active${nbActives > 1 ? 's' : ''}',
              style: AppTheme.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentRed,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              alerte.actives.first.nomCyclone,
              style: AppTheme.poppins(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ] else ...[
            Text(
              'RAS',
              style: AppTheme.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.accentGreen,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Aucune alerte active',
              style: AppTheme.poppins(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BLOC 4A : CONDITIONS MARINES (villes côtières)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildMarineCard(MarineProvider marine) {
    final etat = marine.etat;
    final c = marine.condition;

    return _InfoCard(
      etat: etat,
      erreurMessage: marine.erreur,
      accentColor: AppTheme.accentCyan,
      icon: Icons.water,
      titre: 'Marine',
      buildContent: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _dataRow(
            Icons.waves_outlined,
            AppTheme.accentCyan,
            '${c?.hauteurVagues.toStringAsFixed(1) ?? '—'}m',
            'Vagues',
          ),
          const SizedBox(height: 6),
          _dataRow(
            Icons.thermostat_outlined,
            AppTheme.accentBlue,
            '${c?.temperatureEau.toStringAsFixed(0) ?? '—'}°C',
            'Eau',
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BLOC 4B : CALENDRIER CULTURAL (villes intérieures)
  // ═══════════════════════════════════════════════════════════════
  Widget _buildCalendrierCard(BuildContext context) {
    return Consumer<CalendrierProvider>(
      builder: (context, calendrier, _) {
        final etat = calendrier.etat;
        final donnees = calendrier.donnees;

        return _InfoCard(
          etat: etat,
          erreurMessage: calendrier.erreur,
          accentColor: AppTheme.accentGreen,
          icon: Icons.eco_outlined,
          titre: 'Cultures',
          buildContent: () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (donnees.isNotEmpty) ...[
                Text(
                  '${donnees.length} culture${donnees.length > 1 ? 's' : ''}',
                  style: AppTheme.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.accentGreen,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  donnees.first.typeCultureLabel,
                  style: AppTheme.poppins(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ] else ...[
                Text(
                  'Aucune',
                  style: AppTheme.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Pas de culture active',
                  style: AppTheme.poppins(
                    fontSize: 10,
                    color: AppTheme.textDim,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  Widget _dataRow(IconData icon, Color color, String valeur, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 6),
        Flexible(
          child: RichText(
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: valeur,
                  style: AppTheme.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                TextSpan(
                  text: '  $label',
                  style: AppTheme.poppins(
                    fontSize: 10,
                    color: AppTheme.textDim,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// WIDGET PRIVÉ : Carte d'info générique avec gestion d'état
// ═══════════════════════════════════════════════════════════════════

/// Carte glassmorphism réutilisable qui gère les 3 états d'affichage :
/// - [HomeDataState.loading] / [HomeDataState.initial] → Shimmer animé
/// - [HomeDataState.success] → Contenu via [buildContent]
/// - [HomeDataState.error] → Message d'erreur avec icône warning
class _InfoCard extends StatelessWidget {
  final HomeDataState etat;
  final String? erreurMessage;
  final Color accentColor;
  final IconData icon;
  final String titre;
  final Widget Function() buildContent;

  const _InfoCard({
    required this.etat,
    this.erreurMessage,
    required this.accentColor,
    required this.icon,
    required this.titre,
    required this.buildContent,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      borderRadius: 20,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── EN-TÊTE : icône + titre ─────────────────────────
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 15, color: accentColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  titre,
                  style: AppTheme.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ─── CONTENU : selon l'état du provider ──────────────
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (etat) {
      // ─── CHARGEMENT → Shimmer animé ──────────────────────
      case HomeDataState.initial:
      case HomeDataState.loading:
        return const ShimmerCardContent();

      // ─── SUCCÈS → Vraies données ─────────────────────────
      case HomeDataState.success:
        return buildContent();

      // ─── ERREUR → Message clair avec icône warning ───────
      case HomeDataState.error:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 16,
                  color: AppTheme.accentOrange,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Indisponible',
                    style: AppTheme.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ),
              ],
            ),
            if (erreurMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                erreurMessage!,
                style: AppTheme.poppins(
                  fontSize: 9,
                  color: AppTheme.textDim,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        );
    }
  }
}
