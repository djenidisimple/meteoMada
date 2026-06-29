import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class HourlyCard extends StatelessWidget {
  final String heure;
  final IconData icone;
  final String temp;
  final bool isActive;
  final Color? iconColor;

  const HourlyCard({
    super.key,
    required this.heure,
    required this.icone,
    required this.temp,
    this.isActive = false,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? (isActive ? Colors.white : AppTheme.textSecondary);
    return Container(
      width: 72,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: isActive ? 0.08 : 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: isActive ? 0.12 : 0.04),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            heure,
            style: AppTheme.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isActive ? Colors.white : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Icon(icone, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            temp,
            style: AppTheme.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
