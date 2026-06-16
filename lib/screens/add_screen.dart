import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:echoes_of_the_foundry_floor/common/photo_bottom_sheet.dart';
import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';
import 'package:echoes_of_the_foundry_floor/providers/image_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/input_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/project_provider.dart';
import 'package:echoes_of_the_foundry_floor/utils/code_generator.dart';
import 'package:echoes_of_the_foundry_floor/utils/const.dart';

class AddScreen extends ConsumerStatefulWidget {
  final bool isEdit;
  final int currentIndex;

  const AddScreen({super.key, this.isEdit = false, this.currentIndex = 0});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen>
    with SingleTickerProviderStateMixin {
  static const _stepCount = 4;
  static const _stepTitles = [
    'Identification',
    'Dimensional Logic',
    'Materials & Condition',
    'Archive',
  ];

  late PageController _pageController;
  late AnimationController _errorShakeController;

  int _currentStep = 0;
  bool _showErrorBanner = false;
  bool _hallmarkError = false;
  String _codePreview = '';

  late TextEditingController _hallmarkCtrl;
  late TextEditingController _shrinkageCtrl;
  late TextEditingController _draftCtrl;
  late TextEditingController _volumeCtrl;
  late TextEditingController _tempCtrl;
  late TextEditingController _materialCtrl;
  late TextEditingController _smeltingCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _tagsCtrl;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _errorShakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    final p = ref.read(inputProvider);
    _hallmarkCtrl = TextEditingController(text: p.artisanHallmark);
    _shrinkageCtrl = TextEditingController(text: p.shrinkageAllowanceFactor);
    final matchedDraft = _matchingDraftProfile(p.draftAngleGeometry);
    _draftCtrl = TextEditingController(
      text: matchedDraft == null ? p.draftAngleGeometry : '',
    );
    _volumeCtrl = TextEditingController(text: p.volumetricFootprint);
    _tempCtrl = TextEditingController(text: p.temperatureRange);
    _materialCtrl = TextEditingController(text: p.materialJoinerySeal);
    _smeltingCtrl = TextEditingController(text: p.smeltingGroundZero);
    _notesCtrl = TextEditingController(text: p.archivalNotes);
    _tagsCtrl = TextEditingController(text: p.tags.join(', '));

    _refreshCodePreview();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _errorShakeController.dispose();
    for (final c in [
      _hallmarkCtrl,
      _shrinkageCtrl,
      _draftCtrl,
      _volumeCtrl,
      _tempCtrl,
      _materialCtrl,
      _smeltingCtrl,
      _notesCtrl,
      _tagsCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _refreshCodePreview() {
    final p = ref.read(inputProvider);
    if (p.moldMatrixCode.isNotEmpty) {
      _codePreview = p.moldMatrixCode;
    } else {
      _codePreview = generateMoldMatrixCode(
        classification: p.patternClassification,
        metal: p.castMetalType,
      );
    }
  }

  DraftAngleProfile? _matchingDraftProfile(String value) {
    for (final profile in DraftAngleProfile.values) {
      if (profile.label == value.trim()) return profile;
    }
    return null;
  }

  void _goToStep(int step) {
    final clamped = step.clamp(0, _stepCount - 1);
    setState(() => _currentStep = clamped);
    _pageController.animateToPage(
      clamped,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _triggerValidation() {
    final hallmarkEmpty = _hallmarkCtrl.text.trim().isEmpty;
    setState(() {
      _hallmarkError = hallmarkEmpty;
      _showErrorBanner = hallmarkEmpty;
    });
    if (hallmarkEmpty) {
      _errorShakeController.forward(from: 0);
      _goToStep(0);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showErrorBanner = false);
      });
    }
  }

  Future<void> _save() async {
    _triggerValidation();
    if (_hallmarkError) return;

    final input = ref.read(inputProvider);
    if (input.moldMatrixCode.isEmpty) {
      input.moldMatrixCode = generateMoldMatrixCode(
        classification: input.patternClassification,
        metal: input.castMetalType,
      );
    }

    if (widget.isEdit) {
      ref.read(projectProvider).editEntry(ref, widget.currentIndex);
    } else {
      ref.read(projectProvider).addEntry(ref);
    }

    if (mounted) {
      Navigator.pop(context);
      ref.read(inputProvider).clearAll();
      ref.read(imageProvider).clearImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    final bottom = MediaQuery.of(context).padding.bottom;
    final input = ref.watch(inputProvider);

    return Scaffold(
      backgroundColor: kBackground,
      body: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: _showErrorBanner ? 32.h : 0,
            child: _showErrorBanner
                ? Container(
                    color: kError.withAlpha(30),
                    child: Center(
                      child: Text(
                        '·  ARTISAN HALLMARK REQUIRED  ·',
                        style: GoogleFonts.ibmPlexMono(
                          color: kError,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  )
                : null,
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, top + 12.h, 20.w, 8.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: kOutline),
                      borderRadius: BorderRadius.circular(kRadiusCard),
                    ),
                    child: Icon(Icons.close, color: kPrimaryText, size: 16.sp),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.isEdit ? 'EDIT PATTERN' : 'NEW PATTERN',
                        style: GoogleFonts.bitter(
                          color: kPrimaryText,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _stepTitles[_currentStep],
                        style: GoogleFonts.ibmPlexSans(
                          color: kSecondaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${_currentStep + 1}/$_stepCount',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_stepCount, (i) {
                final isActive = i == _currentStep;
                return GestureDetector(
                  onTap: () => _goToStep(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOut,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: isActive ? 20.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: isActive ? kAccent : kOutline,
                      borderRadius: BorderRadius.circular(kRadiusPill),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: AnimatedBuilder(
              animation: _errorShakeController,
              builder: (context, _) {
                final shake = _errorShakeController.isAnimating
                    ? math.sin(_errorShakeController.value * math.pi * 4) * 4
                    : 0.0;
                return Transform.translate(
                  offset: Offset(shake, 0),
                  child: PageView(
                    controller: _pageController,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (i) => setState(() => _currentStep = i),
                    children: [
                      _buildStepIdentification(input),
                      _buildStepDimensional(input),
                      _buildStepMaterials(input),
                      _buildStepArchive(input),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, bottom + 8.h),
            decoration: const BoxDecoration(
              color: kBackground,
              border: Border(top: BorderSide(color: kOutline, width: 1)),
            ),
            child: Row(
              children: [
                if (_currentStep > 0)
                  GestureDetector(
                    onTap: () => _goToStep(_currentStep - 1),
                    child: Container(
                      height: 50.h,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: kOutline),
                        borderRadius: BorderRadius.circular(kRadiusCard),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'BACK',
                        style: GoogleFonts.ibmPlexMono(
                          color: kSecondaryText,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                if (_currentStep > 0) SizedBox(width: 10.w),
                Expanded(
                  child: GestureDetector(
                    onTap: _currentStep < _stepCount - 1
                        ? () => _goToStep(_currentStep + 1)
                        : _save,
                    child: Container(
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(kRadiusCard),
                        boxShadow: const [kShadowAccent],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _currentStep < _stepCount - 1
                            ? 'CONTINUE'
                            : widget.isEdit
                                ? 'UPDATE RECORD'
                                : 'COMMIT TO ARCHIVE',
                        style: GoogleFonts.ibmPlexMono(
                          color: kPanelBg,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIdentification(InputNotifier input) {
    final displayCode =
        input.moldMatrixCode.isNotEmpty ? input.moldMatrixCode : _codePreview;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      children: [
        _stepCard(
          tabLabel: 'ID',
          tabColor: kAccent,
          children: [
            _codePreviewField(displayCode),
            _field(
              'Artisan Hallmark',
              _hallmarkCtrl,
              hint: 'Pattern maker stamp, shop mark…',
              hasError: _hallmarkError,
              onChanged: (v) {
                ref.read(inputProvider).artisanHallmark = v;
                if (_hallmarkError && v.trim().isNotEmpty) {
                  setState(() => _hallmarkError = false);
                }
              },
            ),
            _inlineChips<PatternClassification>(
              label: 'Pattern Classification',
              values: PatternClassification.values,
              current: input.patternClassification,
              labelFn: (v) => v.label,
              onSelect: (v) {
                ref.read(inputProvider).patternClassification = v;
                setState(_refreshCodePreview);
              },
              colorFn: getPatternColor,
            ),
            _inlineChips<CastMetalType>(
              label: 'Cast Metal',
              values: CastMetalType.values,
              current: input.castMetalType,
              labelFn: (v) => v.label,
              onSelect: (v) {
                ref.read(inputProvider).castMetalType = v;
                setState(_refreshCodePreview);
              },
              colorFn: getMetalColor,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepDimensional(InputNotifier input) {
    final selectedDraft = _matchingDraftProfile(input.draftAngleGeometry);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      children: [
        _stepCard(
          tabLabel: 'DIM',
          tabColor: kCoreBoxGreen,
          children: [
            _field(
              'Shrinkage Allowance Factor',
              _shrinkageCtrl,
              hint: input.castMetalType.shrinkageDefault,
              mono: true,
              onChanged: (v) =>
                  ref.read(inputProvider).shrinkageAllowanceFactor = v,
            ),
            _inlineChips<DraftAngleProfile>(
              label: 'Draft Angle Geometry',
              values: DraftAngleProfile.values,
              current: selectedDraft,
              labelFn: (v) => v.label,
              onSelect: (v) {
                ref.read(inputProvider).draftAngleGeometry = v.label;
                _draftCtrl.clear();
              },
            ),
            _field(
              'Custom Draft Angle',
              _draftCtrl,
              hint: 'e.g. 1.5° compound taper on parting face',
              mono: true,
              onChanged: (v) =>
                  ref.read(inputProvider).draftAngleGeometry = v,
            ),
            _field(
              'Volumetric Footprint',
              _volumeCtrl,
              hint: 'Length × width × height, board thickness…',
              maxLines: 2,
              onChanged: (v) =>
                  ref.read(inputProvider).volumetricFootprint = v,
            ),
            _field(
              'Temperature Range',
              _tempCtrl,
              hint: 'Pouring temperature band, season notes…',
              mono: true,
              onChanged: (v) => ref.read(inputProvider).temperatureRange = v,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepMaterials(InputNotifier input) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      children: [
        _stepCard(
          tabLabel: 'MAT',
          tabColor: const Color(0xFF6B5B4A),
          children: [
            _field(
              'Material & Joinery Seal',
              _materialCtrl,
              hint: 'Mahogany, cherry, dowel joints, shellac finish…',
              maxLines: 3,
              onChanged: (v) =>
                  ref.read(inputProvider).materialJoinerySeal = v,
            ),
            _inlineChips<PreservationSoundness>(
              label: 'Preservation Soundness',
              values: PreservationSoundness.values,
              current: input.preservationSoundness,
              labelFn: (v) => v.label.split('—').first.trim(),
              onSelect: (v) =>
                  ref.read(inputProvider).preservationSoundness = v,
              colorFn: getSoundnessColor,
            ),
            _inlineChips<FoundryEra>(
              label: 'Foundry Era',
              values: FoundryEra.values,
              current: input.era,
              labelFn: (v) => v.label,
              onSelect: (v) => ref.read(inputProvider).era = v,
              colorFn: (_) => kCoreBoxGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepArchive(InputNotifier input) {
    final imgPath = ref
        .watch(imageProvider)
        .getImagePath(ref.watch(imageProvider).resultImage);

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
      children: [
        _stepCard(
          tabLabel: 'AR',
          tabColor: kSecondaryText,
          children: [
            _field(
              'Smelting Ground Zero',
              _smeltingCtrl,
              hint: 'Originating foundry, casting house, city…',
              maxLines: 2,
              onChanged: (v) => ref.read(inputProvider).smeltingGroundZero = v,
            ),
            _field(
              'Archival Notes',
              _notesCtrl,
              hint: 'Historical context, dimensional observations…',
              maxLines: 4,
              onChanged: (v) => ref.read(inputProvider).archivalNotes = v,
            ),
            _field(
              'Tags',
              _tagsCtrl,
              hint: 'gear, split-pattern, birmingham…',
              onChanged: (v) => ref.read(inputProvider).tags = v
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
            ),
            SizedBox(height: 8.h),
            _buildPhotoPlate(imgPath),
          ],
        ),
      ],
    );
  }

  Widget _codePreviewField(String code) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              'MOLD MATRIX CODE',
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: kAccentSurface,
              borderRadius: BorderRadius.circular(kRadiusCard),
              border: Border.all(color: kAccent.withAlpha(60)),
            ),
            child: Row(
              children: [
                Icon(Icons.qr_code_2_outlined, color: kAccent, size: 18.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    code,
                    style: GoogleFonts.ibmPlexMono(
                      color: kAccent,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 6.h),
            child: Text(
              'Auto-assigned on archive if blank',
              style: GoogleFonts.ibmPlexSans(
                color: kSecondaryText,
                fontSize: 10.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoPlate(String? imgPath) {
    final hasImage = imgPath != null && File(imgPath).existsSync();

    return GestureDetector(
      onTap: () => photoBottomSheet(context, ref.read(imageProvider), 0, ref),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: kBackground,
          borderRadius: BorderRadius.circular(kRadiusCard),
          border: Border.all(color: kOutline),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: const BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'PATTERN PHOTO PLATE',
                  style: GoogleFonts.ibmPlexMono(
                    color: kSecondaryText,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  width: 4.w,
                  height: 4.w,
                  decoration: const BoxDecoration(
                    color: kAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(kRadiusCard),
                    child: SizedBox(
                      height: 200.h,
                      width: double.infinity,
                      child: Image.file(File(imgPath), fit: BoxFit.cover),
                    ),
                  )
                : Container(
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: kPanelBg,
                      borderRadius: BorderRadius.circular(kRadiusCard),
                      border: Border.all(color: kOutline),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.camera_alt_outlined,
                            color: kSecondaryText.withAlpha(60),
                            size: 28.sp,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'TAP TO DOCUMENT',
                            style: GoogleFonts.ibmPlexMono(
                              color: kSecondaryText.withAlpha(80),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _stepCard({
    required String tabLabel,
    required Color tabColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: kPanelBg,
        borderRadius: BorderRadius.circular(kRadiusCard),
        border: Border.all(color: kOutline),
        boxShadow: const [kShadowSubtle],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: tabColor.withAlpha(20),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                tabLabel,
                style: GoogleFonts.ibmPlexMono(
                  color: tabColor,
                  fontSize: 8.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inlineChips<T>({
    required String label,
    required List<T> values,
    T? current,
    required String Function(T) labelFn,
    required Function(T) onSelect,
    Color Function(T)? colorFn,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: kSecondaryText,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          Wrap(
            spacing: 6.w,
            runSpacing: 8.h,
            children: values.map((v) {
              final isSel = current != null && v == current;
              final color = colorFn != null ? colorFn(v) : kAccent;
              return GestureDetector(
                onTap: () => onSelect(v),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSel ? color.withAlpha(20) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4.r),
                    border: Border.all(
                      color: isSel ? color : kOutline,
                      width: isSel ? 1.2 : 0.8,
                    ),
                  ),
                  child: Text(
                    labelFn(v),
                    style: GoogleFonts.ibmPlexSans(
                      color: isSel ? color : kSecondaryText,
                      fontSize: 11.sp,
                      fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController ctrl, {
    String? hint,
    int maxLines = 1,
    bool hasError = false,
    bool mono = false,
    required Function(String) onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.ibmPlexMono(
                color: hasError ? kError : kSecondaryText,
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              ),
            ),
          ),
          TextField(
            controller: ctrl,
            onChanged: onChanged,
            maxLines: maxLines,
            style: mono
                ? GoogleFonts.ibmPlexMono(
                    color: kPrimaryText,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  )
                : GoogleFonts.ibmPlexSans(
                    color: kPrimaryText,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                  ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.ibmPlexSans(
                color: kSecondaryText.withAlpha(50),
                fontSize: 12.sp,
                fontWeight: FontWeight.w300,
              ),
              filled: true,
              fillColor: kBackground,
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusCard),
                borderSide: BorderSide(
                  color: hasError ? kError : kOutline,
                  width: hasError ? 1.2 : 0.8,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusCard),
                borderSide: BorderSide(
                  color: hasError ? kError : kOutline,
                  width: hasError ? 1.2 : 0.8,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(kRadiusCard),
                borderSide: BorderSide(
                  color: hasError ? kError : kAccent,
                  width: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
