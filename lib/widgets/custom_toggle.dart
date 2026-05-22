import 'package:flutter/material.dart';
import 'package:meteomada/theme/app_theme.dart';

class CustomToggle extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const CustomToggle({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(options.length, (i) {
        final isActive = i == selectedIndex;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: EdgeInsets.only(
                  left: i > 0 ? 4 : 0, right: i < options.length - 1 ? 4 : 0),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: isActive
                  ? BoxDecoration(
                      color: AppTheme.accentBlue.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.accentBlue.withOpacity(0.40),
                          width: 0.8),
                    )
                  : BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(10),
                    ),
              child: Text(
                options[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isActive ? AppTheme.accentBlue : AppTheme.textSecondary,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
