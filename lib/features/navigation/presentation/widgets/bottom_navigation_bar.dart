import 'package:fincontrol/features/transaction/presentation/pages/activity_page.dart';
import 'package:fincontrol/features/home/presentation/pages/home_page.dart';
import 'package:fincontrol/features/navigation/presentation/widgets/create_action_menu.dart';
import 'package:fincontrol/features/profile/presentation/pages/profile_page.dart';
import 'package:fincontrol/features/wealth/presentation/pages/wealth_page.dart';
import 'package:flutter/material.dart';
import 'package:fincontrol/core/widgets/glass_bottom_nav.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0; // 0: Home, 1: Wealth, 3: Activity, 4: Profile

  // lazy late final — initialized on first access (guaranteed after widget is mounted)
  late final List<Widget> _pages = [
    HomePage(
      onSeeAllActivity: () => _onItemTapped(3),
      onGoToWealth: () => _onItemTapped(1),
    ),
    const WealthPage(),
    const SizedBox.shrink(), // Placeholder for add button
    const ActivityPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    if (index == 2) {
      // Add button
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const CreateActionMenu(),
      );
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: isDarkMode 
          ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
            )
          : const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FAFC), Color(0xFFE0E7FF)],
            ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: Stack(
          children: [
            IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: GlassBottomNav(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
