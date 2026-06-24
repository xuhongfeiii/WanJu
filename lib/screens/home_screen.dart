import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/theme.dart';
import 'discovery_screen.dart';
import 'privacy_screen.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static int _savedIndex = 0;
  int _currentIndex = _savedIndex;

  final List<Widget> _pages = const [
    DiscoveryScreen(),
    PrivacyScreen(),
    FavoritesScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppTheme.backgroundDark : AppTheme.background;
    final surfaceColor = isDark ? AppTheme.surfaceDark : AppTheme.surface;
    final onSurfaceColor = isDark ? AppTheme.onSurfaceDark : AppTheme.onSurface;

    final navBottom = MediaQuery.of(context).viewPadding.bottom + 16;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            RepaintBoundary(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                color: bgColor,
              ),
            ),
          Positioned.fill(
            child: RepaintBoundary(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  isDark ? 'assets/bg_black.png' : 'assets/bg.png',
                  width: screenWidth,
                  fit: BoxFit.fitWidth,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
            Positioned.fill(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
            Positioned(
              left: AppTheme.containerMargin,
              right: AppTheme.containerMargin,
              bottom: navBottom,
              child: _buildNavBar(surfaceColor, onSurfaceColor, isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavBar(Color surfaceColor, Color onSurfaceColor, bool isDark) {
    final overlayColor = isDark
        ? surfaceColor.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.3);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.15)
        : Colors.black.withValues(alpha: 0.08);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: overlayColor,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            border: Border.all(
              color: borderColor,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.explore_outlined, Icons.explore, onSurfaceColor),
              _buildNavItem(1, Icons.shield_outlined, Icons.shield, onSurfaceColor),
              _buildNavItem(2, Icons.bookmark_border, Icons.bookmark, onSurfaceColor),
              _buildNavItem(3, Icons.settings_outlined, Icons.settings, onSurfaceColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, Color onSurfaceColor) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
          _savedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? onSurfaceColor : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? filledIcon : outlinedIcon,
          color: isSelected
              ? (Theme.of(context).brightness == Brightness.dark
                  ? AppTheme.backgroundDark
                  : AppTheme.background)
              : onSurfaceColor.withValues(alpha: 0.5),
          size: 22,
        ),
      ),
    );
  }
}
