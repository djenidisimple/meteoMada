import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class HourlyCard extends StatelessWidget {
  final String heure;
  final IconData icone;
  final String temp;
  final bool isActive;

  const HourlyCard({
    super.key,
    required this.heure,
    required this.icone,
    required this.temp,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: isActive
          ? AppTheme.activeCard
          : AppTheme.glassCard,
      child: Column(
        children: [
          Text(heure,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive
                      ? AppTheme.accentBlue
                      : AppTheme.textSecondary)),
          const SizedBox(height: 6),
          Icon(icone, size: 22, color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary),
          const SizedBox(height: 4),
          Text(temp,
              style: AppTheme.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
        ],
      ),
    );
  }
}
