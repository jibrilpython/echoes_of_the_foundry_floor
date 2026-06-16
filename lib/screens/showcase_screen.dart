import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';
import 'package:echoes_of_the_foundry_floor/models/foundry_artifact_model.dart';
import 'package:echoes_of_the_foundry_floor/providers/image_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/project_provider.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';
import 'package:echoes_of_the_foundry_floor/utils/layout.dart';
import 'package:echoes_of_the_foundry_floor/widgets/pattern_cross_section.dart';

class _LoftBlock {
  final FoundryArtifactModel item;
  final int globalIndex;

  double x, y;
  double vx = 0, vy = 0;
  double homeX, homeY;
  final double size;

  bool isDragging = false;
  double lift = 0;

  _LoftBlock({
    required this.item,
    required this.globalIndex,
    required this.x,
    required this.y,
    required this.homeX,
    required this.homeY,
    required this.size,
  });

  bool contains(Offset p) => (Offset(x, y) - p).distance < size * 0.95;

  bool intersectsPlane(double planeX) => (x - planeX).abs() < size * 1.05;
}

class ShowcaseScreen extends ConsumerStatefulWidget {
  const ShowcaseScreen({super.key});

  @override
  ConsumerState<ShowcaseScreen> createState() => _ShowcaseScreenState();
}

class _ShowcaseScreenState extends ConsumerState<ShowcaseScreen>
    with TickerProviderStateMixin {
  late Ticker _ticker;

  final List<_LoftBlock> _blocks = [];
  bool _initialized = false;
  int _lastHash = -1;

  // Viewport — gesture baseline captured at onScaleStart
  double _scale = 1.0;
  Offset _pan = Offset.zero;
  double _gestureBaseScale = 1.0;
  Offset _gestureBasePan = Offset.zero;
  Offset _gestureBaseFocal = Offset.zero;

  double _planeX = 0;
  bool _draggingPlane = false;
  _LoftBlock? _dragBlock;

  _LoftBlock? _selected;
  double _selectReveal = 0;

  Size _canvasSize = Size.zero;
  double _time = 0;

  static const _minScale = 0.8;
  static const _maxScale = 1.85;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _init(List<FoundryArtifactModel> entries, Size size) {
    if (entries.isEmpty) return;
    final hash = Object.hash(
      ref.read(projectProvider).stateVersion,
      entries.length,
      size.width.toInt(),
      size.height.toInt(),
    );
    if (_initialized && _lastHash == hash) return;

    _initialized = true;
    _lastHash = hash;
    _canvasSize = size;
    _planeX = size.width * 0.5;
    _blocks.clear();

    final cx = size.width * 0.5;
    final cy = size.height * 0.46;
    const golden = 2.399963229728653;

    for (int i = 0; i < entries.length; i++) {
      final e = entries[i];
      final t = i + 1;
      final radius = 28.0 + math.sqrt(t.toDouble()) * 34;
      final angle = i * golden;
      final hx = cx + math.cos(angle) * radius;
      final hy = cy + math.sin(angle) * radius * 0.72;
      final sz = _blockSize(e.patternClassification);

      _blocks.add(_LoftBlock(
        item: e,
        globalIndex: i,
        x: hx,
        y: hy,
        homeX: hx,
        homeY: hy,
        size: sz,
      ));
    }
  }

  double _blockSize(PatternClassification c) {
    switch (c) {
      case PatternClassification.matchPlate:
        return 32;
      case PatternClassification.coreBox:
        return 28;
      case PatternClassification.splitPattern:
        return 26;
      case PatternClassification.shrinkageRule:
        return 20;
      case PatternClassification.moldingSlick:
        return 18;
    }
  }

  void _onTick(Duration _) {
    if (!mounted) return;
    _time += 0.016;

    const stiffness = 0.028;
    const damping = 0.84;

    for (final b in _blocks) {
      if (b.isDragging) {
        b.lift = math.min(b.lift + 0.1, 1.0);
        continue;
      }
      b.lift = math.max(b.lift - 0.07, 0);

      double fx = (b.homeX - b.x) * stiffness;
      double fy = (b.homeY - b.y) * stiffness;

      for (final o in _blocks) {
        if (o == b) continue;
        final dx = b.x - o.x;
        final dy = b.y - o.y;
        final d2 = dx * dx + dy * dy;
        if (d2 < 4900 && d2 > 1) {
          final d = math.sqrt(d2);
          fx += (dx / d) * 380 / d2;
          fy += (dy / d) * 380 / d2;
        }
      }

      b.vx = (b.vx + fx) * damping;
      b.vy = (b.vy + fy) * damping;
      b.x += b.vx;
      b.y += b.vy;
    }

    if (_selected != null) {
      _selectReveal = math.min(_selectReveal + 0.12, 1.0);
    } else {
      _selectReveal = math.max(_selectReveal - 0.14, 0);
    }

    setState(() {});
  }

  Offset _toWorld(Offset local) => (local - _pan) / _scale;

  _LoftBlock? _blockAt(Offset world) {
    for (final b in _blocks.reversed) {
      if (b.contains(world)) return b;
    }
    return null;
  }

  bool _nearPlane(Offset world) => (world.dx - _planeX).abs() < 22;

  void _captureGestureBaseline(Offset focal) {
    _gestureBaseScale = _scale;
    _gestureBasePan = _pan;
    _gestureBaseFocal = focal;
  }

  void _onScaleStart(ScaleStartDetails d) {
    _captureGestureBaseline(d.localFocalPoint);
    final world = _toWorld(d.localFocalPoint);

    if (_nearPlane(world)) {
      _draggingPlane = true;
      HapticFeedback.selectionClick();
      return;
    }

    final hit = _blockAt(world);
    if (hit != null) {
      hit.isDragging = true;
      _dragBlock = hit;
      HapticFeedback.lightImpact();
    }
  }

  void _onScaleUpdate(ScaleUpdateDetails d) {
    if (_draggingPlane) {
      setState(() {
        _planeX = _toWorld(d.localFocalPoint).dx.clamp(
              32.0,
              math.max(32.0, _canvasSize.width - 32),
            );
      });
      return;
    }

    if (_dragBlock != null && d.pointerCount == 1) {
      final world = _toWorld(d.localFocalPoint);
      final prev = _toWorld(_gestureBaseFocal);
      final delta = world - prev;
      _dragBlock!
        ..x += delta.dx
        ..y += delta.dy
        ..homeX = _dragBlock!.x
        ..homeY = _dragBlock!.y;
      _gestureBaseFocal = d.localFocalPoint;
      return;
    }

    // Pinch-zoom anchored to focal point; single-finger pan when scale ≈ 1
    final newScale =
        (_gestureBaseScale * d.scale).clamp(_minScale, _maxScale);
    final focal = d.localFocalPoint;
    final worldUnderFocal =
        (_gestureBaseFocal - _gestureBasePan) / _gestureBaseScale;
    final newPan = focal - worldUnderFocal * newScale;

    setState(() {
      _scale = newScale;
      _pan = newPan;
    });
  }

  void _onScaleEnd(ScaleEndDetails _) {
    for (final b in _blocks) {
      b.isDragging = false;
    }
    _draggingPlane = false;
    _dragBlock = null;
  }

  void _onTapUp(TapUpDetails d) {
    if (_draggingPlane) return;
    final world = _toWorld(d.localPosition);
    final hit = _blockAt(world);
    setState(() {
      if (hit != null) {
        HapticFeedback.selectionClick();
        _selected = hit;
      } else if (!_nearPlane(world)) {
        _selected = null;
      }
    });
  }

  void _onDoubleTap(TapDownDetails d) {
    final world = _toWorld(d.localPosition);
    final hit = _blockAt(world);
    if (hit != null) {
      Navigator.pushNamed(context, '/info_screen', arguments: hit.globalIndex);
      return;
    }
    // Reset viewport
    setState(() {
      _scale = 1.0;
      _pan = Offset.zero;
    });
  }

  List<_LoftBlock> get _sectionedBlocks {
    final list = _blocks.where((b) => b.intersectsPlane(_planeX)).toList();
    list.sort((a, b) => a.y.compareTo(b.y));
    return list.take(4).toList();
  }

  bool get _hasSection => _sectionedBlocks.isNotEmpty;

  bool get _showDock => _hasSection || (_selected != null && _selectReveal > 0);

  @override
  Widget build(BuildContext context) {
    final entries = ref.watch(projectProvider).entries;
    final top = MediaQuery.of(context).padding.top;
    final navBottom = bottomNavOccupiedHeight(context);

    return Scaffold(
      backgroundColor: kBackground,
      body: entries.isEmpty
          ? _buildEmpty(top)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(top),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final size = Size(
                        constraints.maxWidth,
                        constraints.maxHeight,
                      );
                      if (size.width > 0 && size.height > 0) {
                        _init(entries, size);
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onScaleStart: _onScaleStart,
                            onScaleUpdate: _onScaleUpdate,
                            onScaleEnd: _onScaleEnd,
                            onTapUp: _onTapUp,
                            onDoubleTapDown: _onDoubleTap,
                            child: CustomPaint(
                              painter: _LoftPainter(
                                blocks: _blocks,
                                planeX: _planeX,
                                selected: _selected,
                                scale: _scale,
                                pan: _pan,
                                time: _time,
                                draggingPlane: _draggingPlane,
                              ),
                            ),
                          ),
                          // Bottom fade so loft breathes behind dock
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            height: navBottom + (_showDock ? 200.h : 80.h),
                            child: IgnorePointer(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      kBackground.withAlpha(0),
                                      kBackground.withAlpha(200),
                                      kBackground,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            left: 0,
                            right: 0,
                            bottom: navBottom + 6.h,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _showDock ? 1 : 0,
                              child: IgnorePointer(
                                ignoring: !_showDock,
                                child: _buildUnifiedDock(),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEmpty(double top) {
    return Column(
      children: [
        _buildHeader(top),
        Expanded(
          child: Center(
            child: Text(
              'NO PATTERNS IN THIS FOUNDRY YET.',
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(double top) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, top + 10.h, 20.w, 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SECTION REGISTRY',
                  style: GoogleFonts.ibmPlexMono(
                    color: kAccent.withAlpha(130),
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2.4,
                  ),
                ),
                Text(
                  'Parting Plane',
                  style: GoogleFonts.bitter(
                    color: kPrimaryText,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: kPanelBg,
              borderRadius: BorderRadius.circular(kRadiusPill),
              border: Border.all(color: kOutline),
            ),
            child: Text(
              '${_blocks.length} patterns',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 8.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnifiedDock() {
    final sectioned = _sectionedBlocks;
    final b = _selected;
    final showDetail = b != null && _selectReveal > 0.01;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: kPanelBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: kOutline),
          boxShadow: const [kShadowFloat],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_hasSection) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 8.h),
                  child: Row(
                    children: [
                      Container(width: 10.w, height: 2.h, color: kError),
                      SizedBox(width: 8.w),
                      Text(
                        'LIVE SECTION',
                        style: GoogleFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 7.5.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.4,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${sectioned.length}',
                        style: GoogleFonts.ibmPlexMono(
                          color: kAccent,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 72.h,
                  child: Row(
                    children: sectioned.map((block) {
                      final isSel = _selected == block;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selected = block);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: EdgeInsets.fromLTRB(5.w, 0, 5.w, 10.h),
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSel ? kAccentSurface : kBackground,
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: isSel ? kAccent : kOutline,
                                width: isSel ? 1.2 : 0.8,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                patternCrossSectionIcon(
                                  classification:
                                      block.item.patternClassification,
                                  soundness: block.item.preservationSoundness,
                                  size: 30.w,
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  block.item.artisanHallmark.isNotEmpty
                                      ? block.item.artisanHallmark
                                      : '—',
                                  style: GoogleFonts.ibmPlexMono(
                                    color: kPrimaryText,
                                    fontSize: 6.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: showDetail
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_hasSection)
                            Divider(
                              height: 1,
                              color: kOutline.withAlpha(140),
                            ),
                          _buildSpecimenRow(b),
                        ],
                      )
                    : (!_hasSection
                        ? Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Text(
                              'Sweep the parting plane across a pattern',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.ibmPlexSans(
                                color: kSecondaryText,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          )
                        : const SizedBox.shrink()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecimenRow(_LoftBlock b) {
    final imgPath = ref.watch(imageProvider).getImagePath(b.item.photoPath);
    final hasImg = imgPath != null && File(imgPath).existsSync();
    final shrink = b.item.shrinkageAllowanceFactor.isNotEmpty
        ? b.item.shrinkageAllowanceFactor
        : b.item.castMetalType.shrinkageDefault;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 12.h),
      child: Row(
        children: [
          if (hasImg)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.file(
                File(imgPath),
                width: 52.w,
                height: 52.w,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: kBackground,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: kOutline),
              ),
              child: patternCrossSectionIcon(
                classification: b.item.patternClassification,
                soundness: b.item.preservationSoundness,
                size: 28.w,
              ),
            ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  b.item.artisanHallmark.isNotEmpty
                      ? b.item.artisanHallmark
                      : 'Unknown hallmark',
                  style: GoogleFonts.bitter(
                    color: kPrimaryText,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  b.item.moldMatrixCode.isNotEmpty
                      ? b.item.moldMatrixCode
                      : 'Uncatalogued',
                  style: GoogleFonts.ibmPlexMono(
                    color: kAccent,
                    fontSize: 8.5.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  '${b.item.castMetalType.label} · $shrink',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 7.5.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
              context,
              '/info_screen',
              arguments: b.globalIndex,
            ),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: kAccent,
                borderRadius: BorderRadius.circular(kRadiusPill),
              ),
              child: Text(
                'OPEN',
                style: GoogleFonts.ibmPlexMono(
                  color: kPanelBg,
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Painter ─────────────────────────────────────────────────────────────────

class _LoftPainter extends CustomPainter {
  final List<_LoftBlock> blocks;
  final double planeX;
  final _LoftBlock? selected;
  final double scale;
  final Offset pan;
  final double time;
  final bool draggingPlane;

  _LoftPainter({
    required this.blocks,
    required this.planeX,
    required this.selected,
    required this.scale,
    required this.pan,
    required this.time,
    required this.draggingPlane,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(pan.dx, pan.dy);
    canvas.scale(scale);

    _paintGrid(canvas, size);
    _paintPlane(canvas, size);

    for (final b in blocks) {
      _paintBlock(canvas, b, b == selected);
    }

    canvas.restore();
  }

  void _paintGrid(Canvas canvas, Size size) {
    final minor = Paint()
      ..color = kOutline.withAlpha(45)
      ..strokeWidth = 0.5;
    final major = Paint()
      ..color = kOutline.withAlpha(75)
      ..strokeWidth = 0.7;

    const step = 22.0;
    final ext = size.shortestSide * 1.6;
    final ox = size.width / 2 - ext / 2;
    final oy = size.height / 2 - ext / 2;

    for (double x = ox; x <= ox + ext; x += step) {
      canvas.drawLine(Offset(x, oy), Offset(x, oy + ext), minor);
    }
    for (double y = oy; y <= oy + ext; y += step) {
      canvas.drawLine(Offset(ox, y), Offset(ox + ext, y), minor);
    }
    for (double x = ox; x <= ox + ext; x += step * 4) {
      canvas.drawLine(Offset(x, oy), Offset(x, oy + ext), major);
    }
    for (double y = oy; y <= oy + ext; y += step * 4) {
      canvas.drawLine(Offset(ox, y), Offset(ox + ext, y), major);
    }

    // Center crosshair — drawing-office origin
    final origin = Offset(size.width / 2, size.height / 2);
    final cross = Paint()
      ..color = kAccent.withAlpha(35)
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(origin.dx - 12, origin.dy),
      Offset(origin.dx + 12, origin.dy),
      cross,
    );
    canvas.drawLine(
      Offset(origin.dx, origin.dy - 12),
      Offset(origin.dx, origin.dy + 12),
      cross,
    );
  }

  void _paintPlane(Canvas canvas, Size size) {
    final pulse = draggingPlane ? 1.0 : 0.65 + math.sin(time * 2.5) * 0.12;
    final paint = Paint()
      ..color = kError.withAlpha((200 * pulse).round())
      ..strokeWidth = draggingPlane ? 2.2 : 1.4;

    canvas.drawLine(
      Offset(planeX, 0),
      Offset(planeX, size.height),
      paint,
    );

    final handleH = 18.0;
    final handle = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(planeX, size.height * 0.5),
        width: 8,
        height: handleH,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(
      handle,
      Paint()..color = kError.withAlpha((220 * pulse).round()),
    );
  }

  void _paintBlock(Canvas canvas, _LoftBlock b, bool isSelected) {
    final intersects = b.intersectsPlane(planeX);
    final lift = b.lift * 10 + (isSelected ? 8 : 0);
    final cx = b.x;
    final cy = b.y - lift;
    final s = b.size * (isSelected ? 1.1 : 1.0);

    if (intersects || isSelected) {
      final glow = Paint()
        ..color = (intersects ? kError : kAccent).withAlpha(28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
      canvas.drawCircle(Offset(cx, cy), s * 1.5, glow);
    }

    _drawIsometricBlock(
      canvas,
      Offset(cx, cy),
      s,
      getMetalColor(b.item.castMetalType),
      getPatternColor(b.item.patternClassification),
      isSelected || intersects,
    );

    if (isSelected || intersects) {
      _drawDims(canvas, b, cx, cy, s);
    }

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(cx, b.y + s * 0.3),
        width: s * 1.5,
        height: s * 0.35,
      ),
      Paint()
        ..color = kPrimaryText.withAlpha(22)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
  }

  void _drawIsometricBlock(
    Canvas canvas,
    Offset c,
    double s,
    Color metal,
    Color wood,
    bool hi,
  ) {
    final h = s * 0.52;
    final w = s * 0.65;
    final iso = s * 0.32;

    final topC = Color.lerp(wood, kPanelBg, hi ? 0.1 : 0.25)!;
    final leftC = Color.lerp(wood, kPrimaryText, 0.4)!;
    final rightC = Color.lerp(wood, metal, 0.35)!;

    final top = Path()
      ..moveTo(c.dx, c.dy - h)
      ..lineTo(c.dx + w, c.dy - h + iso * 0.5)
      ..lineTo(c.dx, c.dy - h + iso)
      ..lineTo(c.dx - w, c.dy - h + iso * 0.5)
      ..close();
    final right = Path()
      ..moveTo(c.dx, c.dy - h + iso)
      ..lineTo(c.dx + w, c.dy - h + iso * 0.5)
      ..lineTo(c.dx + w, c.dy + iso * 0.45)
      ..lineTo(c.dx, c.dy + iso * 0.95)
      ..close();
    final left = Path()
      ..moveTo(c.dx, c.dy - h + iso)
      ..lineTo(c.dx - w, c.dy - h + iso * 0.5)
      ..lineTo(c.dx - w, c.dy + iso * 0.45)
      ..lineTo(c.dx, c.dy + iso * 0.95)
      ..close();

    canvas.drawPath(left, Paint()..color = leftC);
    canvas.drawPath(right, Paint()..color = rightC);
    canvas.drawPath(top, Paint()..color = topC);

    final edge = Paint()
      ..color = kPrimaryText.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;
    canvas.drawPath(top, edge);
    canvas.drawPath(right, edge);
    canvas.drawPath(left, edge);
  }

  void _drawDims(Canvas canvas, _LoftBlock b, double cx, double cy, double s) {
    final dim = Paint()
      ..color = kError.withAlpha(150)
      ..strokeWidth = 0.7;
    canvas.drawLine(
      Offset(cx - s * 0.8, cy - s - 10),
      Offset(cx + s * 0.8, cy - s - 10),
      dim,
    );
    final shrink = b.item.shrinkageAllowanceFactor.isNotEmpty
        ? b.item.shrinkageAllowanceFactor
        : b.item.castMetalType.shrinkageDefault;

    final maxLabelWidth = math.max(s * 2.6, 56.0);
    final tp = TextPainter(
      text: TextSpan(
        text: shrink,
        style: const TextStyle(
          color: Color(0xB0C0392B),
          fontSize: 6.5,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: maxLabelWidth);

    tp.paint(canvas, Offset(cx - tp.width / 2, cy - s - 20));
  }

  @override
  bool shouldRepaint(covariant _LoftPainter old) => true;
}
