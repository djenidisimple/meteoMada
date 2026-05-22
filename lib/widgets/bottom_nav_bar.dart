import 'dart:ui';
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
    final items = [
      _NavItem(Icons.home_rounded, 'Accueil'),
      _NavItem(Icons.star_rounded, 'Favoris'),
      _NavItem(Icons.map_rounded, 'Carte'),
      _NavItem(Icons.grid_view_rounded, 'Plus'),
    ];

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF06121C).withOpacity(0.92),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.06)),
            ),
          ),
          child: SafeArea(
            bottom: true,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
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
                      width: isSelected ? 72 : 56,
                      padding: isSelected
                          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                          : const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: isSelected
                          ? BoxDecoration(
                              color: AppTheme.accentBlue.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppTheme.accentBlue.withOpacity(0.20), width: 0.5),
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
                                size: isSelected ? 22 : 20,
                                color: isSelected
                                    ? AppTheme.accentBlue
                                    : Colors.white.withOpacity(0.28),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 6),
                                Text(
                                  item.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentBlue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (i == 3 && hasActiveAlerte)
                            Positioned(
                              top: -2,
                              right: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.accentRed,
                                  border: Border.all(
                                      color: const Color(0xFF06121C), width: 1.5),
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
