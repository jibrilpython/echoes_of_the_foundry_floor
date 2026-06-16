import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';
import 'package:echoes_of_the_foundry_floor/models/foundry_artifact_model.dart';
import 'package:echoes_of_the_foundry_floor/providers/project_provider.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';
import 'package:echoes_of_the_foundry_floor/utils/layout.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with TickerProviderStateMixin {
  int _selectedEraIndex = -1;
  String? _selectedPatternSegment;
  String? _selectedHallmark;

  late AnimationController _pulseController;

  static final _eras = FoundryEra.values;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  List<FoundryArtifactModel> _filterByEra(
    List<FoundryArtifactModel> entries,
    FoundryEra? era,
  ) {
    if (era == null) return entries;
    return entries.where((e) => e.era == era).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allEntries = ref.watch(projectProvider).entries;
    final top = MediaQuery.of(context).padding.top;

    final selectedEra =
        _selectedEraIndex >= 0 ? _eras[_selectedEraIndex] : null;
    final timelineEntries = _filterByEra(allEntries, selectedEra);

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, top + 16.h, 20.w, 8.h),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOGBOOK',
                      style: GoogleFonts.bitter(
                        color: kPrimaryText,
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    Text(
                      'FOUNDRY ANALYSIS',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (allEntries.isNotEmpty)
                  Text(
                    allEntries.length.toString().padLeft(2, '0'),
                    style: GoogleFonts.bitter(
                      color: kAccent,
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: allEntries.isEmpty
                ? _buildEmpty()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      0,
                      4.h,
                      0,
                      tabScrollBottomInset(context),
                    ),
                    children: [
                      _buildTimelineScrubber(allEntries),
                      _buildPatternRadialChart(timelineEntries),
                      _buildHallmarkBars(timelineEntries),
                      _buildMetalTiles(timelineEntries),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (_, _) => CustomPaint(
              size: Size(72.w, 72.h),
              painter: _EmptyFoundryPainter(
                progress: _pulseController.value,
                color: kAccent.withAlpha(70),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'EMPTY MOULDING FLOOR',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Catalog patterns to populate\nthe foundry analysis logbook.',
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText.withAlpha(150),
              fontSize: 12.sp,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineScrubber(List<FoundryArtifactModel> entries) {
    final eraCounts = <FoundryEra, int>{};
    for (final e in entries) {
      eraCounts[e.era] = (eraCounts[e.era] ?? 0) + 1;
    }
    if (eraCounts.isEmpty) return const SizedBox.shrink();

    final maxCount = eraCounts.values.reduce(math.max);
    final activeEra =
        _selectedEraIndex >= 0 ? _eras[_selectedEraIndex] : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'ERA TIMELINE',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              if (activeEra != null) ...[
                SizedBox(width: 8.w),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: kAccent.withAlpha(20),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    activeEra.label,
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 8.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                GestureDetector(
                  onTap: () => setState(() => _selectedEraIndex = -1),
                  child: Icon(Icons.close, size: 12.sp, color: kSecondaryText),
                ),
              ],
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 56.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: _eras.map((era) {
                final count = eraCounts[era] ?? 0;
                final idx = _eras.indexOf(era);
                final isActive = _selectedEraIndex == idx;
                final barH = count == 0 ? 2.h : (count / maxCount) * 28.h;

                return GestureDetector(
                  onTap: () {
                    if (count == 0) return;
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedEraIndex = isActive ? -1 : idx;
                    });
                  },
                  child: Container(
                    width: 44.w,
                    margin: EdgeInsets.only(right: 4.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (count > 0)
                          Text(
                            '$count',
                            style: GoogleFonts.ibmPlexMono(
                              color: isActive ? kAccent : kSecondaryText,
                              fontSize: 7.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        SizedBox(height: 2.h),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 22.w,
                          height: math.max(barH, 2.h),
                          decoration: BoxDecoration(
                            color: isActive
                                ? kAccent
                                : (count > 0
                                      ? kAccent.withAlpha(50)
                                      : kOutline.withAlpha(40)),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          era.label,
                          style: GoogleFonts.ibmPlexMono(
                            color: isActive
                                ? kAccent
                                : kSecondaryText.withAlpha(80),
                            fontSize: 6.sp,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternRadialChart(List<FoundryArtifactModel> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final counts = <PatternClassification, int>{};
    for (final e in entries) {
      counts[e.patternClassification] =
          (counts[e.patternClassification] ?? 0) + 1;
    }
    final total = counts.values.fold(0, (a, b) => a + b);
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'PATTERN CLASSIFICATION',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              const Spacer(),
              if (_selectedPatternSegment != null)
                GestureDetector(
                  onTap: () =>
                      setState(() => _selectedPatternSegment = null),
                  child: Text(
                    '· clear',
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 120.h,
            child: Row(
              children: [
                SizedBox(
                  width: 120.w,
                  height: 120.h,
                  child: GestureDetector(
                    onTap: () {
                      if (sorted.isEmpty) return;
                      final currentIdx = sorted.indexWhere(
                        (e) => e.key.label == _selectedPatternSegment,
                      );
                      final nextIdx = (currentIdx + 1) % sorted.length;
                      setState(() {
                        _selectedPatternSegment = sorted[nextIdx].key.label;
                      });
                      HapticFeedback.selectionClick();
                    },
                    child: CustomPaint(
                      size: Size(120.w, 120.h),
                      painter: _PatternRadialPainter(
                        entries: sorted,
                        total: total,
                        selectedLabel: _selectedPatternSegment,
                        pulse: _pulseController.value,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: sorted.map((entry) {
                      final isSelected =
                          entry.key.label == _selectedPatternSegment;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedPatternSegment = isSelected
                                ? null
                                : entry.key.label;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 5.h,
                          ),
                          margin: EdgeInsets.only(bottom: 4.h),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? getPatternColor(entry.key).withAlpha(15)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: BoxDecoration(
                                  color: getPatternColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  entry.key.label,
                                  style: GoogleFonts.ibmPlexSans(
                                    color: isSelected
                                        ? kPrimaryText
                                        : kSecondaryText,
                                    fontSize: 11.sp,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${((entry.value / total) * 100).round()}%',
                                style: GoogleFonts.ibmPlexMono(
                                  color: isSelected
                                      ? getPatternColor(entry.key)
                                      : kSecondaryText,
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: kOutline.withAlpha(80)),
        ],
      ),
    );
  }

  Widget _buildHallmarkBars(List<FoundryArtifactModel> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final hallmarkCounts = <String, int>{};
    for (final e in entries) {
      if (e.artisanHallmark.isNotEmpty) {
        hallmarkCounts[e.artisanHallmark] =
            (hallmarkCounts[e.artisanHallmark] ?? 0) + 1;
      }
    }
    final sorted = hallmarkCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    const maxShown = 5;
    final topHallmarks = sorted.take(maxShown).toList();
    final otherHallmarks = sorted.skip(maxShown).toList();
    if (topHallmarks.isEmpty) return const SizedBox.shrink();

    final maxVal = topHallmarks.first.value;
    final othersPatternCount =
        otherHallmarks.fold<int>(0, (sum, e) => sum + e.value);

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'TOP ARTISAN HALLMARKS',
                style: GoogleFonts.ibmPlexMono(
                  color: kAccent,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
              if (_selectedHallmark != null) ...[
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => setState(() => _selectedHallmark = null),
                  child: Text(
                    '· clear',
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          ...topHallmarks.map((entry) {
            final frac = entry.value / maxVal;
            final isSelected = entry.key == _selectedHallmark;
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedHallmark = isSelected ? null : entry.key;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(bottom: 6.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? kAccent.withAlpha(10) : kPanelBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected ? kAccent : kOutline,
                    width: isSelected ? 1.2 : 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: GoogleFonts.bitter(
                              color: isSelected ? kAccent : kPrimaryText,
                              fontSize: 13.sp,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${entry.value}',
                          style: GoogleFonts.ibmPlexMono(
                            color: isSelected ? kAccent : kSecondaryText,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final barWidth = isSelected
                            ? constraints.maxWidth
                            : constraints.maxWidth *
                                math.max(frac, 0.04);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: barWidth,
                          height: 3.h,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kAccent
                                : kAccent.withAlpha(50),
                            borderRadius: BorderRadius.circular(1),
                          ),
                        );
                      },
                    ),
                    if (isSelected) ...[
                      SizedBox(height: 8.h),
                      _buildHallmarkDetail(entry.key, entries),
                    ],
                  ],
                ),
              ),
            );
          }),
          if (otherHallmarks.isNotEmpty)
            Container(
              margin: EdgeInsets.only(bottom: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: kOutline.withAlpha(120), width: 0.8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Others…',
                      style: GoogleFonts.ibmPlexSans(
                        color: kSecondaryText,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  Text(
                    '${otherHallmarks.length} hallmarks · $othersPatternCount',
                    style: GoogleFonts.ibmPlexMono(
                      color: kSecondaryText,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          Container(height: 1, color: kOutline.withAlpha(80)),
        ],
      ),
    );
  }

  Widget _buildHallmarkDetail(
    String hallmark,
    List<FoundryArtifactModel> all,
  ) {
    final items = all.where((e) => e.artisanHallmark == hallmark).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(height: 1, color: kAccent.withAlpha(30)),
        SizedBox(height: 8.h),
        ...items.take(3).map((e) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 4.w,
                    decoration: BoxDecoration(
                      color: getPatternColor(e.patternClassification),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      e.moldMatrixCode.isNotEmpty
                          ? e.moldMatrixCode
                          : 'Uncoded',
                      style: GoogleFonts.ibmPlexMono(
                        color: kSecondaryText,
                        fontSize: 9.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    e.patternClassification.label,
                    style: GoogleFonts.ibmPlexSans(
                      color: kSecondaryText.withAlpha(150),
                      fontSize: 9.sp,
                    ),
                  ),
                ],
              ),
            )),
        if (items.length > 3)
          Text(
            '+${items.length - 3} more',
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText.withAlpha(100),
              fontSize: 8.sp,
            ),
          ),
      ],
    );
  }

  Widget _buildMetalTiles(List<FoundryArtifactModel> entries) {
    if (entries.isEmpty) return const SizedBox.shrink();

    final metalCounts = <CastMetalType, int>{};
    for (final e in entries) {
      metalCounts[e.castMetalType] =
          (metalCounts[e.castMetalType] ?? 0) + 1;
    }
    final sorted = metalCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CAST METAL DISTRIBUTION',
            style: GoogleFonts.ibmPlexMono(
              color: kAccent,
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          SizedBox(height: 12.h),
          ...sorted.map((entry) {
            final color = getMetalColor(entry.key);
            final shrinkage = entry.key.shrinkageDefault;
            final avgCustom = _avgShrinkageForMetal(entries, entry.key);
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${entry.key.label}: ${entry.value} pattern${entry.value == 1 ? '' : 's'} · shrinkage $shrinkage',
                      style: GoogleFonts.ibmPlexSans(
                        color: kPanelBg,
                        fontSize: 12.sp,
                      ),
                    ),
                    backgroundColor: color,
                    behavior: SnackBarBehavior.floating,
                    margin: EdgeInsets.all(16.w),
                    duration: const Duration(seconds: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: 6.h),
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: kPanelBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: kOutline),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.label,
                            style: GoogleFonts.ibmPlexSans(
                              color: kPrimaryText,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Std. shrinkage: $shrinkage'
                            '${avgCustom != null ? ' · logged: $avgCustom' : ''}',
                            style: GoogleFonts.ibmPlexMono(
                              color: kSecondaryText,
                              fontSize: 9.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${entry.value}',
                      style: GoogleFonts.ibmPlexMono(
                        color: color,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(
                      Icons.chevron_right,
                      color: kSecondaryText,
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  String? _avgShrinkageForMetal(
    List<FoundryArtifactModel> entries,
    CastMetalType metal,
  ) {
    final factors = entries
        .where((e) =>
            e.castMetalType == metal && e.shrinkageAllowanceFactor.isNotEmpty)
        .map((e) => e.shrinkageAllowanceFactor)
        .toList();
    if (factors.isEmpty) return null;
    if (factors.length == 1) return factors.first;
    return '${factors.first} (+${factors.length - 1})';
  }
}

class _PatternRadialPainter extends CustomPainter {
  final List<MapEntry<PatternClassification, int>> entries;
  final int total;
  final String? selectedLabel;
  final double pulse;

  _PatternRadialPainter({
    required this.entries,
    required this.total,
    required this.selectedLabel,
    required this.pulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0 || entries.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    double startAngle = -math.pi / 2;

    for (final entry in entries) {
      final sweepAngle = (entry.value / total) * 2 * math.pi;
      final color = getPatternColor(entry.key);
      final isSelected = entry.key.label == selectedLabel;

      final paint = Paint()
        ..color = isSelected ? color : color.withAlpha(120)
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      if (isSelected) {
        final ringPaint = Paint()
          ..color = color.withAlpha((80 + (pulse * 80)).round())
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        canvas.drawCircle(center, radius + 4, ringPaint);
      }

      startAngle += sweepAngle;
    }

    final centerPaint = Paint()
      ..color = kBackground
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.4, centerPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: '$total',
        style: TextStyle(
          color: kPrimaryText,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PatternRadialPainter old) =>
      old.total != total ||
      old.selectedLabel != selectedLabel ||
      old.pulse != pulse;
}

class _EmptyFoundryPainter extends CustomPainter {
  final double progress;
  final Color color;

  _EmptyFoundryPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final flaskPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final flaskW = size.width * 0.55;
    final flaskH = size.height * 0.65;
    final flaskRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(cx, cy + 4),
        width: flaskW,
        height: flaskH,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(flaskRect, flaskPaint);

    final sandPaint = Paint()
      ..color = color.withAlpha((80 + progress * 60).round())
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(
        cx - flaskW / 2 + 4,
        cy + flaskH * 0.15,
        flaskW - 8,
        flaskH * 0.35 + progress * 6,
      ),
      sandPaint,
    );

    final ripplePaint = Paint()
      ..color = color.withAlpha((40 + progress * 40).round())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(
      Offset(cx, cy + flaskH * 0.3),
      8 + progress * 10,
      ripplePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _EmptyFoundryPainter old) =>
      old.progress != progress;
}
