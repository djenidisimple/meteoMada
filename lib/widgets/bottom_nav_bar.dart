import 'package:flutter/cupertino.dart';
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
    final bottom = MediaQuery.of(context).padding.bottom;
    final items = [
      _NavItem(CupertinoIcons.house_alt, 'Météo'),
      _NavItem(CupertinoIcons.search, 'Recherche'),
      _NavItem(CupertinoIcons.bell, 'Alertes'),
      _NavItem(CupertinoIcons.map, 'Carte'),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottom),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isSelected = i == currentIndex;

            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: 48,
                    height: 48,
                    decoration: isSelected
                        ? BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(16),
                          )
                        : null,
                    child: Icon(
                      item.icon,
                      size: 24,
                      color: isSelected
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                  if (i == 2 && hasActiveAlerte)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentRed,
                          border: Border.all(
                            color: AppTheme.homeDarkBottom,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
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
