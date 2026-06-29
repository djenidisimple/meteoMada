import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:meteomada/theme/app_theme.dart';
import 'package:meteomada/widgets/glass_card.dart';
import 'package:meteomada/widgets/custom_switch.dart';
import 'package:meteomada/providers/utilisateur_provider.dart';
import 'package:meteomada/widgets/loading_view.dart';

class ParametresScreen extends StatelessWidget {
  const ParametresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.homeScreenGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          title: Text('Paramètres',
              style: AppTheme.poppins(
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
        ),
        body: Consumer<UtilisateurProvider>(
          builder: (_, up, __) {
            final user = up.utilisateur;
            if (up.chargement) {
              return const LoadingView(message: "Chargement des paramètres...");
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _profileCard(user?.pseudo ?? 'Utilisateur', user?.typeUtilisateur ?? 'citoyen'),
                  const SizedBox(height: 16),
                  _typeUtilisateurSection(up, user?.typeUtilisateur ?? 'citoyen'),
                  const SizedBox(height: 12),
                  _affichageSection(),
                  const SizedBox(height: 12),
                  _notificationsSection(up, user),
                  const SizedBox(height: 12),
                  _aboutSection(context),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _profileCard(String pseudo, String type) {
    final color = _typeColor(type);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.35), width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [AppTheme.accentBlue, AppTheme.accentBlueLight]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(CupertinoIcons.person_alt, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(pseudo,
                  style: AppTheme.poppins(
                      fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color.withValues(alpha: 0.35), width: 0.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_typeIcon(type), size: 10, color: color),
                    const SizedBox(width: 4),
                    Text(_typeLabel(type),
                        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeUtilisateurSection(UtilisateurProvider up, String current) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.people_outlined, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('Type d\'utilisateur',
                  style: AppTheme.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _typeChip(CupertinoIcons.sun_max, 'Agriculteur', 'agriculteur', AppTheme.accentYellow, current, up),
              _typeChip(CupertinoIcons.drop, 'Pêcheur', 'pecheur', AppTheme.accentGreen, current, up),
              _typeChip(CupertinoIcons.person, 'Citoyen', 'citoyen', AppTheme.accentBlue, current, up),
              _typeChip(Icons.directions_boat_outlined, 'Marin', 'marin', AppTheme.accentOrange, current, up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _typeChip(IconData icon, String label, String type, Color color,
      String current, UtilisateurProvider up) {
    final isActive = current == type;
    return GestureDetector(
      onTap: () => up.updateTypeUtilisateur(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: isActive
            ? BoxDecoration(
                color: color.withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.40), width: 0.8),
              )
            : BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.5),
              ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: isActive ? color : AppTheme.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTheme.poppins(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: isActive ? color : AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _affichageSection() {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('Affichage',
                  style: AppTheme.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.thermostat_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text('Température',
                      style: AppTheme.poppins(fontSize: 12, color: Colors.white)),
                ],
              ),
              Row(
                children: [
                  _tempToggle('°C', true),
                  const SizedBox(width: 6),
                  _tempToggle('°F', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.dark_mode_outlined, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text('Thème sombre',
                      style: AppTheme.poppins(fontSize: 12, color: Colors.white)),
                ],
              ),
              CustomSwitch(value: true, activeColor: AppTheme.accentBlue, onChanged: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tempToggle(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: isActive
          ? BoxDecoration(
              color: AppTheme.accentBlue.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.40), width: 0.8),
            )
          : BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
            ),
      child: Text(label,
          style: AppTheme.poppins(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary)),
    );
  }

  Widget _notificationsSection(UtilisateurProvider up, dynamic user) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.bell, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('Notifications',
                  style: AppTheme.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          _notifRow(Icons.cyclone_outlined, 'Alertes cycloniques',
              user?.alertesCycloneActivees ?? true, AppTheme.accentRed, () {
            up.updateAlertesCyclone(!(user?.alertesCycloneActivees ?? true));
          }),
          Divider(height: 16, color: Colors.white.withValues(alpha: 0.06)),
          _notifRow(Icons.water_drop_outlined, 'Alertes de pluie',
              user?.alertesPluieActivees ?? false, AppTheme.accentBlue, () {
            up.updateAlertesPluie(!(user?.alertesPluieActivees ?? false));
          }),
          if (user?.typeUtilisateur == 'agriculteur') ...[
            Divider(height: 16, color: Colors.white.withValues(alpha: 0.06)),
            _notifRow(Icons.eco_outlined, 'Conseils culturaux', true, AppTheme.accentYellow, () {}),
          ],
        ],
      ),
    );
  }

  Widget _notifRow(IconData icon, String label, bool value, Color color, VoidCallback onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label,
                style: AppTheme.poppins(fontSize: 12, color: Colors.white)),
          ],
        ),
        CustomSwitch(value: value, activeColor: color, onChanged: onChanged),
      ],
    );
  }

  Widget _aboutSection(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(CupertinoIcons.info, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text('À propos',
                  style: AppTheme.poppins(
                      fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 10),
          _infoRow('Source données', 'DGM Madagascar'),
          const SizedBox(height: 4),
          _infoRow('Version', '1.0.0'),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Support: contact@toerana.mg'),
                  backgroundColor: AppTheme.backgroundDark,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.accentBlue.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.20)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(CupertinoIcons.mail, size: 14, color: AppTheme.accentBlue),
                  const SizedBox(width: 6),
                  Text('Contacter le support',
                      textAlign: TextAlign.center,
                      style: AppTheme.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentBlue)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        Text(value,
            style: AppTheme.poppins(
                fontSize: 11, fontWeight: FontWeight.w500, color: Colors.white)),
      ],
    );
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'agriculteur': return AppTheme.accentYellow;
      case 'pecheur': return AppTheme.accentGreen;
      case 'marin': return AppTheme.accentOrange;
      default: return AppTheme.accentBlue;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'agriculteur': return CupertinoIcons.sun_max;
      case 'pecheur': return CupertinoIcons.drop;
      case 'marin': return Icons.directions_boat_outlined;
      default: return CupertinoIcons.person;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'agriculteur': return 'Agriculteur';
      case 'pecheur': return 'Pêcheur';
      case 'marin': return 'Marin';
      default: return 'Citoyen';
    }
  }
}
