import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fincontrol/core/theme/app_colors.dart';
import 'package:fincontrol/l10n/app_localizations.dart';

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const GlassBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final glassColor = isDarkMode 
        ? const Color(0x99192134) 
        : const Color(0xCCFFFFFF);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha:0.1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: glassColor,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, Icons.home_rounded, 0, AppLocalizations.of(context)!.home),
                _buildNavItem(context, Icons.pie_chart_rounded, 1, AppLocalizations.of(context)!.wealth),
                _buildNavItem(context, Icons.add_circle, 2, 'Add', isCenter: true),
                _buildNavItem(context, Icons.history_rounded, 3, AppLocalizations.of(context)!.activity),
                _buildNavItem(context, Icons.person_rounded, 4, AppLocalizations.of(context)!.profile),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index, String label, {bool isCenter = false}) {
    final isSelected = currentIndex == index;
    final color = isSelected ? AppColors.accent : Theme.of(context).iconTheme.color!.withValues(alpha:0.5);

    if (isCenter) {
      return GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
