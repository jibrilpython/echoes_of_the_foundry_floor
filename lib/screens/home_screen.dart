import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';
import 'package:echoes_of_the_foundry_floor/models/foundry_artifact_model.dart';
import 'package:echoes_of_the_foundry_floor/providers/image_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/input_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/project_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/search_provider.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';
import 'package:echoes_of_the_foundry_floor/utils/layout.dart';
import 'package:echoes_of_the_foundry_floor/widgets/pattern_cross_section.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  CastMetalType? _selectedMetalFilter;
  PatternClassification? _selectedPatternFilter;
  int? _selectedCardIndex;
  bool _searchOpen = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _searchOpen = !_searchOpen;
      if (!_searchOpen) {
        _searchController.clear();
        ref.read(searchProvider.notifier).clearSearchQuery();
      } else {
        _searchFocusNode.requestFocus();
      }
    });
  }

  List<FoundryArtifactModel> _applyFilters(List<FoundryArtifactModel> all) {
    var filtered = all;
    if (_selectedMetalFilter != null) {
      filtered = filtered
          .where((e) => e.castMetalType == _selectedMetalFilter)
          .toList();
    }
    if (_selectedPatternFilter != null) {
      filtered = filtered
          .where((e) => e.patternClassification == _selectedPatternFilter)
          .toList();
    }
    return ref.watch(searchProvider).filteredList(filtered);
  }

  String _collectionLine(int count) {
    if (count == 0) return 'No patterns yet';
    if (count == 1) return '1 pattern in this foundry';
    return '$count patterns in this foundry';
  }

  String _shrinkageLabel(FoundryArtifactModel entry) {
    final allowance = entry.shrinkageAllowanceFactor.isNotEmpty
        ? entry.shrinkageAllowanceFactor
        : entry.castMetalType.shrinkageDefault;
    return '${entry.castMetalType.label} · $allowance';
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(projectProvider).entries;
    final entries = _applyFilters(allEntries);
    final top = MediaQuery.of(context).padding.top;
    final fabBottom = homeFabBottomInset(context);
    final scrollBottom = homeScrollBottomInset(context);

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Column(
            children: [
              _buildAppBar(top, allEntries.length),
              _buildFilterStrip(),
              Expanded(
                child: entries.isEmpty
                    ? _buildEmptyState()
                    : MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16.h,
                        crossAxisSpacing: 16.w,
                        padding: EdgeInsets.fromLTRB(
                          20.w,
                          4.h,
                          20.w,
                          scrollBottom,
                        ),
                        physics: const BouncingScrollPhysics(),
                        itemCount: entries.length,
                        itemBuilder: (context, i) {
                          final entry = entries[i];
                          final mainIdx = ref
                              .read(projectProvider)
                              .entries
                              .indexOf(entry);
                          return _buildStaggeredCard(
                            context,
                            entry,
                            mainIdx,
                            i,
                          );
                        },
                      ),
              ),
            ],
          ),
          Positioned(
            right: 20.w,
            bottom: fabBottom,
            child: _buildAddButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: () {
        ref.read(inputProvider).clearAll();
        ref.read(imageProvider).clearImage();
        Navigator.pushNamed(context, '/add_screen');
      },
      child: Container(
        width: kHomeFabSize.w,
        height: kHomeFabSize.w,
        decoration: BoxDecoration(
          color: kAccent,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: kAccent.withAlpha(80),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(Icons.add, color: kPanelBg, size: 26.sp),
      ),
    );
  }

  Widget _buildAppBar(double top, int count) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, top + 20.h, 20.w, 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ECHOES OF THE',
                  style: GoogleFonts.bitter(
                    color: kPrimaryText,
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.08,
                    letterSpacing: 0.2,
                  ),
                ),
                SizedBox(height: 2.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        'FOUNDRY FLOOR',
                        style: GoogleFonts.bitter(
                          color: kAccent,
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w700,
                          height: 1.08,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: kAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Container(
                      width: 24.w,
                      height: 2.h,
                      color: kAccent,
                    ),
                    SizedBox(width: 10.w),
                    Flexible(
                      child: Text(
                        _collectionLine(count),
                        style: GoogleFonts.ibmPlexSans(
                          color: kSecondaryText,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _toggleSearch,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: _searchOpen ? kAccent : kPanelBg,
                borderRadius: BorderRadius.circular(kRadiusMedium),
                border: Border.all(
                  color: _searchOpen ? kAccent : kOutline,
                  width: kStrokeWeight,
                ),
                boxShadow: _searchOpen
                    ? const [kShadowAccent]
                    : const [kShadowSubtle],
              ),
              child: Icon(
                _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                color: _searchOpen ? kPanelBg : kPrimaryText,
                size: 22.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: _searchOpen ? 70.h : 0,
          child: _searchOpen
              ? Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.h),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    onChanged: (v) =>
                        ref.read(searchProvider.notifier).setSearchQuery(v),
                    style: GoogleFonts.ibmPlexSans(
                      color: kPrimaryText,
                      fontSize: 14.sp,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Search matrix codes, hallmarks, foundries…',
                      hintStyle: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText.withAlpha(90),
                        fontSize: 13.sp,
                      ),
                      filled: true,
                      fillColor: kPanelBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        borderSide: const BorderSide(
                          color: kOutline,
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        borderSide: const BorderSide(
                          color: kOutline,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(kRadiusMedium),
                        borderSide: const BorderSide(
                          color: kAccent,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 13.h,
                      ),
                      isDense: true,
                      prefixIcon: Icon(
                        Icons.search,
                        color: kSecondaryText,
                        size: 18.sp,
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        SizedBox(
          height: 38.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              _metalFilterChip('All', null),
              ...CastMetalType.values.map(
                (t) => _metalFilterChip(t.label, t),
              ),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 32.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            children: [
              _patternFilterChip('All types', null),
              ...PatternClassification.values.map(
                (t) => _patternFilterChip(t.label, t),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(height: 1, color: kOutline.withAlpha(90)),
      ],
    );
  }

  Widget _metalFilterChip(String label, CastMetalType? type) {
    final isSel = _selectedMetalFilter == type;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedMetalFilter = type;
        _selectedCardIndex = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: EdgeInsets.only(right: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: isSel ? kAccent : kPanelBg,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(color: isSel ? kAccent : kOutline, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          label.toUpperCase(),
          style: GoogleFonts.ibmPlexSans(
            color: isSel ? kPanelBg : kSecondaryText,
            fontSize: 10.sp,
            fontWeight: isSel ? FontWeight.w600 : FontWeight.w500,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  Widget _patternFilterChip(String label, PatternClassification? type) {
    final isSel = _selectedPatternFilter == type;
    final accentColor =
        type != null ? getPatternColor(type) : kSecondaryText;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedPatternFilter = type;
        _selectedCardIndex = null;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        margin: EdgeInsets.only(right: 6.w),
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSel ? accentColor.withAlpha(20) : Colors.transparent,
          borderRadius: BorderRadius.circular(kRadiusPill),
          border: Border.all(
            color: isSel ? accentColor : kOutline.withAlpha(160),
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.ibmPlexMono(
            color: isSel ? accentColor : kSecondaryText,
            fontSize: 8.sp,
            fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildStaggeredCard(
    BuildContext context,
    FoundryArtifactModel entry,
    int idx,
    int listPos,
  ) {
    final imageProv = ref.watch(imageProvider);
    final imagePath = imageProv.getImagePath(entry.photoPath);
    final hasImage = entry.photoPath.isNotEmpty &&
        imagePath != null &&
        File(imagePath).existsSync();
    final isSelected = _selectedCardIndex == idx;
    final metalColor = getMetalColor(entry.castMetalType);

    return GestureDetector(
      onTap: () {
        setState(() => _selectedCardIndex = idx);
        Navigator.pushNamed(
          context,
          '/info_screen',
          arguments: {'index': idx},
        ).then((_) {
          if (mounted) setState(() => _selectedCardIndex = null);
        });
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: isSelected ? kAccentSurface : kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusCard),
              border: Border.all(color: kOutline, width: kStrokeWeight),
              boxShadow: const [kShadowSubtle],
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasImage)
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(kRadiusCard),
                      topRight: Radius.circular(kRadiusCard),
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 180.h),
                      child: SizedBox(
                        width: double.infinity,
                        child: Image.file(File(imagePath), fit: BoxFit.cover),
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 80.h,
                    color: kBackground.withAlpha(100),
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: kSecondaryText.withAlpha(80),
                      size: 24.sp,
                    ),
                  ),
                _buildCrossSectionStrip(entry),
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${(listPos + 1).toString().padLeft(2, '0')}',
                            style: GoogleFonts.ibmPlexMono(
                              color: kAccent,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Flexible(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: metalColor.withAlpha(25),
                                borderRadius:
                                    BorderRadius.circular(kRadiusPill),
                                border: Border.all(
                                  color: kOutline.withAlpha(180),
                                  width: 0.8,
                                ),
                              ),
                              child: Text(
                                _shrinkageLabel(entry),
                                style: GoogleFonts.ibmPlexMono(
                                  color: metalColor,
                                  fontSize: 7.5.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                  SizedBox(height: 8.h),
                  Text(
                    entry.artisanHallmark.isNotEmpty
                        ? entry.artisanHallmark.toUpperCase()
                        : 'UNKNOWN HALLMARK',
                    style: GoogleFonts.ibmPlexSans(
                      color: kPrimaryText,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (entry.moldMatrixCode.isNotEmpty) ...[
                    SizedBox(height: 4.h),
                    Text(
                      entry.moldMatrixCode.toUpperCase(),
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  SizedBox(height: 8.h),
                  if (entry.smeltingGroundZero.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: kAccent.withAlpha(30),
                        borderRadius: BorderRadius.circular(kRadiusPill),
                      ),
                      child: Text(
                        entry.smeltingGroundZero,
                        style: GoogleFonts.ibmPlexMono(
                          color: kAccent,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
          ],
            ),
          ),
          if (isSelected)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(kRadiusCard),
                    bottomLeft: Radius.circular(kRadiusCard),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCrossSectionStrip(FoundryArtifactModel entry) {
    return Container(
      height: 36.h,
      width: double.infinity,
      color: kBackground.withAlpha(60),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          patternCrossSectionIcon(
            classification: entry.patternClassification,
            soundness: entry.preservationSoundness,
            size: 28.w,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              entry.patternClassification.label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: getPatternColor(entry.patternClassification)
                    .withAlpha(180),
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.6,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 12.w),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NO PATTERNS IN THIS FOUNDRY YET.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w400,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              'Tap + to catalog your first sand-casting pattern.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText.withAlpha(180),
                fontSize: 13.sp,
                fontWeight: FontWeight.w300,
                height: 1.65,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
