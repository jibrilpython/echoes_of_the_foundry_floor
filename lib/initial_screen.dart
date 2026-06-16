import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echoes_of_the_foundry_floor/providers/user_provider.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';
import 'package:echoes_of_the_foundry_floor/widgets/pattern_cross_section.dart';
import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';

class InitialScreen extends ConsumerStatefulWidget {
  const InitialScreen({super.key});

  @override
  ConsumerState<InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<InitialScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _draftController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _draftController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    _fadeIn = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));
    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _draftController.dispose();
    super.dispose();
  }

  void _enterFoundry() {
    ref.read(userProvider).setFirstTimeUser(false);
    Navigator.pushReplacementNamed(context, '/home');
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _DrawingGridPainter())),
          Positioned.fill(
            child: SafeArea(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        EdgeInsets.fromLTRB(24.w, 20.h, 24.w, bottom + 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 24.h),
                        _buildDraftCard(),
                        SizedBox(height: 32.h),
                        _buildTitleBlock(),
                        SizedBox(height: 20.h),
                        _buildDescriptionCard(),
                        SizedBox(height: 24.h),
                        _buildCapabilitiesSection(),
                        SizedBox(height: 32.h),
                        _buildEnterButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: kAccent.withAlpha(20),
              borderRadius: BorderRadius.circular(kRadiusPill),
              border: Border.all(color: kAccent.withAlpha(50)),
            ),
            child: Text(
              'Pattern archive',
              style: GoogleFonts.ibmPlexMono(
                color: kAccent,
                fontSize: 9.sp,
                letterSpacing: 0.6,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Text(
            '',
            textAlign: TextAlign.end,
            style: GoogleFonts.ibmPlexMono(
              color: kSecondaryText.withAlpha(140),
              fontSize: 8.sp,
              letterSpacing: 0.4,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDraftCard() {
    return Container(
      height: 148.h,
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kOutline, width: kStrokeWeight),
        boxShadow: const [kShadowSubtle],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: _SectionGridPainter()),
          ),
          Positioned(
            left: 20.w,
            top: 20.h,
            child: patternCrossSectionIcon(
              classification: PatternClassification.splitPattern,
              soundness: PreservationSoundness.operational,
              size: 48.w,
            ),
          ),
          Positioned(
            right: 20.w,
            bottom: 20.h,
            child: patternCrossSectionIcon(
              classification: PatternClassification.coreBox,
              soundness: PreservationSoundness.operational,
              size: 40.w,
            ),
          ),
          Positioned.fill(
            child: AnimatedBuilder(
              animation: Listenable.merge([_draftController, _entranceController]),
              builder: (_, _) => CustomPaint(
                painter: _DraftAnglePainter(
                  progress: _draftController.value,
                  drawProgress: _fadeIn.value,
                ),
              ),
            ),
          ),
          Positioned(
            left: 14.w,
            top: 12.h,
            child: Text(
              'Section view',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 7.5.sp,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            'Echoes of the',
            style: GoogleFonts.bitter(
              color: kPrimaryText,
              fontSize: 34.sp,
              fontWeight: FontWeight.w700,
              height: 1.05,
              letterSpacing: -0.5,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Row(
          children: [
            Container(width: 28.w, height: 2.h, color: kAccent),
            SizedBox(width: 10.w),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Foundry Floor',
                  style: GoogleFonts.bitter(
                    color: kAccent,
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kOutline, width: kStrokeWeight),
      ),
      child: Text(
        'A digital archive for collectors of vintage sand-casting patterns — wooden masters, shrinkage rulers, and molding tools that shaped the iron skeleton of early machinery.',
        style: GoogleFonts.ibmPlexSans(
          color: kSecondaryText,
          fontSize: 13.sp,
          fontWeight: FontWeight.w300,
          height: 1.65,
        ),
      ),
    );
  }

  Widget _buildCapabilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What you can do',
          style: GoogleFonts.ibmPlexSans(
            color: kSecondaryText,
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _capabilityTile(
                icon: Icons.inventory_2_outlined,
                title: 'Catalog',
                subtitle: 'Log patterns you own',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _capabilityTile(
                icon: Icons.photo_outlined,
                title: 'Document',
                subtitle: 'Attach photos & specs',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _capabilityTile(
                icon: Icons.map_outlined,
                title: 'Map',
                subtitle: 'Explore your archive',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _capabilityTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kOutline, width: kStrokeWeight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: kAccent, size: 18.sp),
          SizedBox(height: 8.h),
          Text(
            title,
            style: GoogleFonts.bitter(
              color: kPrimaryText,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: GoogleFonts.ibmPlexSans(
              color: kSecondaryText,
              fontSize: 9.sp,
              fontWeight: FontWeight.w300,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEnterButton() {
    return GestureDetector(
      onTap: _enterFoundry,
      child: Container(
        height: 54.h,
        decoration: BoxDecoration(
          color: kAccent,
          borderRadius: BorderRadius.circular(kRadiusPill),
          boxShadow: const [kShadowAccent],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Enter the Foundry',
                style: GoogleFonts.bitter(
                  color: kPanelBg,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
              SizedBox(width: 10.w),
              Icon(Icons.arrow_forward_rounded, color: kPanelBg, size: 18.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawingGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = kOutline.withAlpha(40)
      ..strokeWidth = 0.5;
    const spacing = 28.0;
    for (double y = spacing; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SectionGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = kOutline.withAlpha(60)
      ..strokeWidth = 0.5;
    const divisions = 8;
    final dx = size.width / divisions;
    final dy = size.height / divisions;
    for (int i = 1; i < divisions; i++) {
      canvas.drawLine(Offset(dx * i, 0), Offset(dx * i, size.height), gridPaint);
      canvas.drawLine(Offset(0, dy * i), Offset(size.width, dy * i), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DraftAnglePainter extends CustomPainter {
  final double progress;
  final double drawProgress;

  _DraftAnglePainter({required this.progress, required this.drawProgress});

  @override
  void paint(Canvas canvas, Size size) {
    if (drawProgress <= 0) return;
    final paint = Paint()
      ..color = kAccent.withAlpha((160 * drawProgress).round())
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final left = size.width * 0.55;
    final top = size.height * 0.15;
    final bottom = size.height * 0.85;
    final taper = 12 + math.sin(progress * 2 * math.pi) * 2;

    final path = Path()
      ..moveTo(left - taper, top)
      ..lineTo(left + taper, top)
      ..lineTo(left + taper * 0.6, bottom)
      ..lineTo(left - taper * 0.6, bottom)
      ..close();
    canvas.drawPath(path, paint);

    final dimPaint = Paint()
      ..color = kError.withAlpha((120 * drawProgress).round())
      ..strokeWidth = 0.8;
    canvas.drawLine(
      Offset(left + taper + 8, top),
      Offset(left + taper + 8, bottom),
      dimPaint,
    );
    canvas.drawLine(
      Offset(left + taper + 4, top),
      Offset(left + taper + 12, top),
      dimPaint,
    );
    canvas.drawLine(
      Offset(left + taper * 0.6 + 4, bottom),
      Offset(left + taper * 0.6 + 12, bottom),
      dimPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _DraftAnglePainter old) =>
      old.progress != progress || old.drawProgress != drawProgress;
}
