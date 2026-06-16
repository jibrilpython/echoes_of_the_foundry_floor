import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echoes_of_the_foundry_floor/screens/home_screen.dart';
import 'package:echoes_of_the_foundry_floor/screens/stats_screen.dart';
import 'package:echoes_of_the_foundry_floor/screens/showcase_screen.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';
import 'package:echoes_of_the_foundry_floor/utils/layout.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    StatsScreen(),
    ShowcaseScreen(),
  ];

  static const _tabs = [
    _NavTab(icon: Icons.grid_view_rounded, label: 'Foundry'),
    _NavTab(icon: Icons.menu_book_rounded, label: 'Logbook'),
    _NavTab(icon: Icons.map_outlined, label: 'Pattern Map'),
  ];

  void _setIndex(int i) {
    if (i == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = i);
  }

  Alignment _indicatorAlignment(int index) {
    switch (index) {
      case 0:
        return Alignment.centerLeft;
      case 1:
        return Alignment.center;
      case 2:
        return Alignment.centerRight;
      default:
        return Alignment.center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: kBackground,
      extendBody: true,
      body: Stack(
        children: [
          IndexedStack(index: _currentIndex, children: _screens),
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: bottom + kBottomNavBarMargin.h,
            child: _buildNavBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          height: kBottomNavBarHeight.h,
          decoration: BoxDecoration(
            color: kPanelBg.withAlpha(168),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: kOutline.withAlpha(140),
              width: kStrokeWeight,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x12000000),
                blurRadius: 28,
                offset: Offset(0, 10),
                spreadRadius: -4,
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(6.h),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  alignment: _indicatorAlignment(_currentIndex),
                  child: FractionallySizedBox(
                    widthFactor: 1 / _tabs.length,
                    heightFactor: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: kAccentSurface,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: kAccent.withAlpha(45),
                          width: kStrokeWeight,
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: List.generate(_tabs.length, (i) {
                    return Expanded(
                      child: _NavBarItem(
                        tab: _tabs[i],
                        isActive: _currentIndex == i,
                        onTap: () => _setIndex(i),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final _NavTab tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.tab,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        splashColor: kAccent.withAlpha(25),
        highlightColor: kAccent.withAlpha(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(vertical: 8.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isActive ? 1.0 : 0.92,
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                child: Icon(
                  tab.icon,
                  color: isActive ? kAccent : kSecondaryText.withAlpha(200),
                  size: 22.sp,
                ),
              ),
              SizedBox(height: 5.h),
              Text(
                tab.label,
                style: GoogleFonts.ibmPlexSans(
                  color: isActive ? kAccent : kSecondaryText,
                  fontSize: 10.sp,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  letterSpacing: isActive ? 0.2 : 0,
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavTab {
  final IconData icon;
  final String label;
  const _NavTab({required this.icon, required this.label});
}
