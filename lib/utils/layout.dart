import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Keep in sync with [MainNavigation] bottom bar dimensions.
const double kBottomNavBarHeight = 72;
const double kBottomNavBarMargin = 12;
const double kFabSpacingAboveNav = 16;
const double kHomeFabSize = 58;

/// Total vertical space occupied by the floating bottom nav overlay.
double bottomNavOccupiedHeight(BuildContext context) {
  final safeBottom = MediaQuery.paddingOf(context).bottom;
  return safeBottom + kBottomNavBarMargin.h + kBottomNavBarHeight.h;
}

/// Bottom inset for the home screen add button — sits above the nav bar.
double homeFabBottomInset(BuildContext context) {
  return bottomNavOccupiedHeight(context) + kFabSpacingAboveNav.h;
}

/// List/grid bottom padding so content clears the FAB and nav bar.
double homeScrollBottomInset(BuildContext context) {
  return bottomNavOccupiedHeight(context) +
      kHomeFabSize.h +
      kFabSpacingAboveNav.h +
      12.h;
}

/// Scroll bottom padding for tabs without a FAB.
double tabScrollBottomInset(BuildContext context) {
  return bottomNavOccupiedHeight(context) + 16.h;
}
