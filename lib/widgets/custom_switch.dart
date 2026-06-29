import 'package:flutter/material.dart';

class CustomSwitch extends StatelessWidget {
  final bool value;
  final Color activeColor;
  final VoidCallback onChanged;

  const CustomSwitch({
    super.key,
    required this.value,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onChanged,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 38,
        height: 22,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          color: value ? activeColor : Colors.white.withValues(alpha: 0.14),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? Colors.white : Colors.white.withValues(alpha: 0.40),
            ),
          ),
        ),
      ),
    );
  }
}
