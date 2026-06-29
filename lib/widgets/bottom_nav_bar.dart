import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasActiveAlerte;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasActiveAlerte = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bottom = MediaQuery.of(context).padding.bottom;
    final showLabel = width >= 360;

    final items = [
      _NavItem(Icons.home_rounded, 'Accueil'),
      _NavItem(Icons.star_rounded, 'Favoris'),
      _NavItem(Icons.map_rounded, 'Carte'),
      _NavItem(Icons.grid_view_rounded, 'Plus'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 8 + bottom),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0A1628),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == currentIndex;

              return GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  width: isSelected && showLabel ? 72 : 48,
                  padding: isSelected
                      ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                      : const EdgeInsets.all(8),
                  decoration: isSelected
                      ? BoxDecoration(
                          color: AppTheme.accentBlue.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: AppTheme.accentBlue.withValues(alpha: 0.20), width: 0.5),
                        )
                      : null,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            size: isSelected ? 20 : 18,
                            color: isSelected
                                ? AppTheme.accentBlue
                                : Colors.white.withValues(alpha: 0.35),
                          ),
                          if (isSelected && showLabel) ...[
                            const SizedBox(width: 6),
                            Text(
                              item.label,
                              style: AppTheme.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.accentBlue,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (i == 3 && hasActiveAlerte)
                        Positioned(
                          top: -3,
                          right: -3,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.accentRed,
                              border: Border.all(
                                  color: const Color(0xFF0A1628), width: 1.5),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem(this.icon, this.label);
}
