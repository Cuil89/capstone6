import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'home_view.dart';
import '../../profile/view/profile_view.dart';
import '../../scan/view/scan_view.dart';
import '../../symptom/view/symptom_view.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _currentIndex = 0;

  final _screens = const [HomeView(), SymptomView(), ScanView(), ProfileView()];

  void _onDestinationSelected(int index) {
    if (_currentIndex == index) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavBarItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'Beranda',
                isActive: _currentIndex == 0,
                onTap: () => _onDestinationSelected(0),
              ),
              _NavBarItem(
                icon: Icons.health_and_safety_outlined,
                activeIcon: Icons.health_and_safety_rounded,
                label: 'Gejala',
                isActive: _currentIndex == 1,
                onTap: () => _onDestinationSelected(1),
              ),
              _NavBarItem(
                icon: Icons.document_scanner_outlined,
                activeIcon: Icons.document_scanner_rounded,
                label: 'Scan',
                isActive: _currentIndex == 2,
                onTap: () => _onDestinationSelected(2),
              ),
              _NavBarItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
                isActive: _currentIndex == 3,
                onTap: () => _onDestinationSelected(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Note: since we aren't changing app_theme colors, we use AppColors.primary
    // To access AppColors, we might need to import it if it's not already.
    // Wait, let's just use Theme.of(context).primaryColor since AppColors isn't imported here yet.
    final primaryColor = Theme.of(context).primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? primaryColor : Colors.grey.shade400,
              size: 24,
            ),
            if (isActive) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
