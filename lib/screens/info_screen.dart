import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echoes_of_the_foundry_floor/models/foundry_artifact_model.dart';
import 'package:echoes_of_the_foundry_floor/providers/image_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/project_provider.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';

class InfoScreen extends ConsumerWidget {
  final int index;
  const InfoScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectProv = ref.watch(projectProvider);
    if (index < 0 || index >= projectProv.entries.length) {
      return Scaffold(
        backgroundColor: kBackground,
        body: Center(
          child: Text(
            'PATTERN NOT FOUND',
            style: GoogleFonts.ibmPlexMono(color: kAccent),
          ),
        ),
      );
    }
    final entry = projectProv.entries[index];
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final hasImage =
        entry.photoPath.isNotEmpty &&
        imagePath != null &&
        File(imagePath).existsSync();

    final size = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: hasImage
                ? Image.file(File(imagePath), fit: BoxFit.cover)
                : Container(
                    color: kPanelBg,
                    child: Center(
                      child: Icon(
                        Icons.dashboard_customize_outlined,
                        size: 80.sp,
                        color: kOutline,
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.55,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    kBackground.withAlpha(200),
                    Colors.transparent,
                    kBackground.withAlpha(100),
                  ],
                ),
              ),
            ),
          ),

          Positioned.fill(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                SizedBox(height: size.height * 0.40),

                Container(
                  decoration: BoxDecoration(
                    color: kBackground,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: kAccent.withAlpha(150),
                        width: kStrokeWeightMedium,
                      ),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(40),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(28.w, 40.h, 28.w, 120.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 10.w,
                                  vertical: 4.h,
                                ),
                                decoration: BoxDecoration(
                                  color: kAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'SPECIMEN',
                                  style: GoogleFonts.ibmPlexMono(
                                    color: kPanelBg,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Text(
                                  entry.moldMatrixCode.isNotEmpty
                                      ? entry.moldMatrixCode.toUpperCase()
                                      : 'UNREGISTERED',
                                  style: GoogleFonts.ibmPlexMono(
                                    color: kAccent,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            entry.artisanHallmark.isNotEmpty
                                ? entry.artisanHallmark.toUpperCase()
                                : 'UNKNOWN HALLMARK',
                            style: GoogleFonts.bitter(
                              color: kPrimaryText,
                              fontSize: 38.sp,
                              fontWeight: FontWeight.w700,
                              height: 1.05,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),

                          SizedBox(height: 24.h),
                          Wrap(
                            spacing: 12.w,
                            runSpacing: 12.h,
                            children: [
                              _editorialTag(
                                entry.patternClassification.label
                                    .toUpperCase(),
                                getPatternColor(entry.patternClassification),
                                true,
                              ),
                              _editorialTag(
                                entry.castMetalType.label.toUpperCase(),
                                getMetalColor(entry.castMetalType),
                                false,
                              ),
                              _editorialTag(
                                entry.preservationSoundness.label
                                    .split('—')
                                    .first
                                    .trim()
                                    .toUpperCase(),
                                getSoundnessColor(entry.preservationSoundness),
                                false,
                              ),
                            ],
                          ),

                          SizedBox(height: 48.h),
                          if (_hasSpecs(entry)) ...[
                            _sectionHeader('TECHNICAL DATA'),
                            _buildModernTable(entry),
                            SizedBox(height: 48.h),
                          ],

                          if (entry.archivalNotes.isNotEmpty) ...[
                            _sectionHeader('ARCHIVAL NOTES'),
                            Padding(
                              padding: EdgeInsets.only(bottom: 40.h),
                              child: Text(
                                entry.archivalNotes,
                                style: GoogleFonts.ibmPlexSans(
                                  color: kPrimaryText,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w300,
                                  height: 1.8,
                                ),
                              ),
                            ),
                          ],

                          if (entry.tags.isNotEmpty) ...[
                            _sectionHeader('INDEX TAGS'),
                            Wrap(
                              spacing: 8.w,
                              runSpacing: 8.h,
                              children: entry.tags
                                  .map(
                                    (t) => Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 5.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: kPanelBg,
                                        borderRadius: BorderRadius.circular(
                                          kRadiusCard,
                                        ),
                                        border: Border.all(color: kOutline),
                                      ),
                                      child: Text(
                                        '#${t.toUpperCase()}',
                                        style: GoogleFonts.ibmPlexMono(
                                          color: kSecondaryText,
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            top: topPadding + 10.h,
            left: 20.w,
            right: 20.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _glassButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _glassButton(
                      icon: Icons.edit_outlined,
                      onTap: () {
                        projectProv.fillInput(ref, index);
                        Navigator.pushNamed(
                          context,
                          '/add_screen',
                          arguments: {'isEdit': true, 'currentIndex': index},
                        );
                      },
                    ),
                    SizedBox(width: 12.w),
                    _glassButton(
                      icon: Icons.delete_outline,
                      iconColor: kError,
                      onTap: () => _confirmDelete(context, projectProv, index),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _editorialTag(String text, Color color, bool filled) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: kStrokeWeightMedium),
        borderRadius: BorderRadius.circular(kRadiusPill),
      ),
      child: Text(
        text,
        style: GoogleFonts.ibmPlexMono(
          color: filled ? kPanelBg : color,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          Container(
            width: 12.w,
            height: 12.w,
            decoration: const BoxDecoration(color: kAccent),
          ),
          SizedBox(width: 10.w),
          Text(
            title,
            style: GoogleFonts.bitter(
              color: kPrimaryText,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  bool _hasSpecs(FoundryArtifactModel e) =>
      e.shrinkageAllowanceFactor.isNotEmpty ||
      e.draftAngleGeometry.isNotEmpty ||
      e.materialJoinerySeal.isNotEmpty ||
      e.volumetricFootprint.isNotEmpty ||
      e.temperatureRange.isNotEmpty ||
      e.smeltingGroundZero.isNotEmpty;

  Widget _buildModernTable(FoundryArtifactModel e) {
    final rows = <_SpecRow>[];
    if (e.shrinkageAllowanceFactor.isNotEmpty) {
      rows.add(_SpecRow('Shrinkage', e.shrinkageAllowanceFactor));
    }
    if (e.draftAngleGeometry.isNotEmpty) {
      rows.add(_SpecRow('Draft Angle', e.draftAngleGeometry));
    }
    if (e.materialJoinerySeal.isNotEmpty) {
      rows.add(_SpecRow('Materials', e.materialJoinerySeal));
    }
    if (e.volumetricFootprint.isNotEmpty) {
      rows.add(_SpecRow('Volumetric Footprint', e.volumetricFootprint));
    }
    if (e.temperatureRange.isNotEmpty) {
      rows.add(_SpecRow('Temperature', e.temperatureRange));
    }
    rows.add(_SpecRow('Era', e.era.label));
    if (e.smeltingGroundZero.isNotEmpty) {
      rows.add(_SpecRow('Smelting Ground Zero', e.smeltingGroundZero));
    }

    return Column(
      children: rows.map((row) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: kPanelBg,
            borderRadius: BorderRadius.circular(kRadiusCard),
            border: Border.all(color: kOutline, width: kStrokeWeight),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 120.w,
                child: Text(
                  row.label.toUpperCase(),
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  row.value,
                  style: GoogleFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    Color iconColor = kPrimaryText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusMedium),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: kGlassBg,
              borderRadius: BorderRadius.circular(kRadiusMedium),
              border: Border.all(
                color: kOutline.withAlpha(100),
                width: kStrokeWeightMedium,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    ProjectNotifier projectProv,
    int idx,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.fromLTRB(
          20.w,
          20.h,
          20.w,
          MediaQuery.of(ctx).padding.bottom + 20.h,
        ),
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(kRadiusMedium),
          ),
          border: const Border(top: BorderSide(color: kOutline, width: 1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 3.h,
                margin: EdgeInsets.only(bottom: 20.h),
                decoration: BoxDecoration(
                  color: kOutline,
                  borderRadius: BorderRadius.circular(kRadiusPill),
                ),
              ),
            ),
            Text(
              'SCRAP THIS PATTERN?',
              style: GoogleFonts.bitter(
                color: kError,
                fontSize: 24.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'This will permanently remove this pattern record from the foundry archive — shrinkage data, draft angles, and all provenance notes will be lost. This cannot be undone.',
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 15.sp,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 52.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        border: Border.all(color: kOutline),
                      ),
                      child: Text(
                        'Keep Pattern',
                        style: GoogleFonts.ibmPlexSans(
                          color: kPrimaryText,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      projectProv.deleteEntry(idx);
                      Navigator.pop(ctx);
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 52.h,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: kError,
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                      ),
                      child: Text(
                        'Scrap Record',
                        style: GoogleFonts.ibmPlexSans(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow {
  final String label;
  final String value;
  _SpecRow(this.label, this.value);
}
