import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';
import 'package:flutter/material.dart';

const Color kBackground = Color(0xFFF5F0E8);
const Color kPrimaryText = Color(0xFF1A1410);
const Color kPanelBg = Color(0xFFFFFFFF);
const Color kSecondaryText = Color(0xFF7A7060);
const Color kAccent = Color(0xFF8B4513);
const Color kOutline = Color(0xFFE6DFD2);
const Color kCoreBoxGreen = Color(0xFF4A6741);
const Color kError = Color(0xFFC0392B);

const Color kAccentSurface = Color(0xFFF5EDE0);
const Color kGlassBg = Color(0x99F5F0E8);

const double kSpacingXXS = 4.0;
const double kSpacingXS = 8.0;
const double kSpacingS = 12.0;
const double kSpacingM = 16.0;
const double kSpacingL = 20.0;
const double kSpacingXL = 24.0;
const double kSpacingXXL = 32.0;
const double kSpacingXXXL = 48.0;

const double kRadiusCard = 10.0;
const double kRadiusMedium = 14.0;
const double kRadiusLarge = 20.0;
const double kRadiusPill = 999.0;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 2),
  blurRadius: 8,
  spreadRadius: -1,
  color: Color(0x10000000),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -4,
  color: Color(0x15000000),
);

const BoxShadow kShadowAccent = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: -2,
  color: Color(0x208B4513),
);

const double kStrokeWeight = 1.0;
const double kStrokeWeightMedium = 1.5;

Color getPatternColor(PatternClassification cat) {
  switch (cat) {
    case PatternClassification.splitPattern:
      return kAccent;
    case PatternClassification.coreBox:
      return kCoreBoxGreen;
    case PatternClassification.matchPlate:
      return const Color(0xFF6B5B4A);
    case PatternClassification.moldingSlick:
      return const Color(0xFF7A6A50);
    case PatternClassification.shrinkageRule:
      return const Color(0xFF5A4A3A);
  }
}

Color getMetalColor(CastMetalType metal) {
  switch (metal) {
    case CastMetalType.greyIron:
      return const Color(0xFF4A4A4A);
    case CastMetalType.malleableIron:
      return const Color(0xFF5A5048);
    case CastMetalType.bronze:
      return const Color(0xFF8B6914);
    case CastMetalType.brass:
      return const Color(0xFFB5A642);
    case CastMetalType.aluminium:
      return const Color(0xFF9A9A9A);
    case CastMetalType.steel:
      return const Color(0xFF3A3A48);
  }
}

Color getSoundnessColor(PreservationSoundness state) {
  switch (state) {
    case PreservationSoundness.operational:
      return kAccent;
    case PreservationSoundness.woodWarpingTolerance:
      return const Color(0xFFB07D2A);
    case PreservationSoundness.sandAbrasionScoring:
      return const Color(0xFF8C6B3A);
    case PreservationSoundness.shellacFlaking:
      return const Color(0xFFA0522D);
    case PreservationSoundness.displayOnly:
      return kCoreBoxGreen;
    case PreservationSoundness.degraded:
      return kError;
    case PreservationSoundness.unknown:
      return kSecondaryText;
  }
}

bool isDisplayOnly(PreservationSoundness state) =>
    state == PreservationSoundness.displayOnly;
