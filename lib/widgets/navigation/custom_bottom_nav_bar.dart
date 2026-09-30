import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.fitness_center_rounded, label: 'Workout'),
      _NavItem(icon: Icons.restaurant_rounded, label: 'Nutrition'),
      _NavItem(icon: Icons.show_chart_rounded, label: 'Progress'),
      _NavItem(icon: Icons.person_rounded, label: 'Profile'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder.withOpacity(0.4) : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isSelected = currentIndex == index;
            final item = items[index];

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: isSelected ? 22 : 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark
                          ? AppColors.electricCyan
                          : const Color(0xFF111827))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  item.icon,
                  size: 22,
                  color: isSelected
                      ? (isDark ? const Color(0xFF0B1216) : Colors.white)
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextMuted),
                ),
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

  const _NavItem({required this.icon, required this.label});
}
