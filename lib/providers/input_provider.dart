import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';

class InputNotifier extends ChangeNotifier {
  String _moldMatrixCode = '';
  PatternClassification _patternClassification =
      PatternClassification.splitPattern;
  CastMetalType _castMetalType = CastMetalType.greyIron;
  String _artisanHallmark = '';
  String _shrinkageAllowanceFactor = '';
  String _draftAngleGeometry = '';
  String _materialJoinerySeal = '';
  String _volumetricFootprint = '';
  PreservationSoundness _preservationSoundness =
      PreservationSoundness.unknown;
  String _smeltingGroundZero = '';
  String _temperatureRange = '';
  FoundryEra _era = FoundryEra.s1890s;
  String _archivalNotes = '';
  String _photoPath = '';
  List<String> _tags = [];
  DateTime _dateAdded = DateTime.now();

  String get moldMatrixCode => _moldMatrixCode;
  PatternClassification get patternClassification => _patternClassification;
  CastMetalType get castMetalType => _castMetalType;
  String get artisanHallmark => _artisanHallmark;
  String get shrinkageAllowanceFactor => _shrinkageAllowanceFactor;
  String get draftAngleGeometry => _draftAngleGeometry;
  String get materialJoinerySeal => _materialJoinerySeal;
  String get volumetricFootprint => _volumetricFootprint;
  PreservationSoundness get preservationSoundness => _preservationSoundness;
  String get smeltingGroundZero => _smeltingGroundZero;
  String get temperatureRange => _temperatureRange;
  FoundryEra get era => _era;
  String get archivalNotes => _archivalNotes;
  String get photoPath => _photoPath;
  List<String> get tags => _tags;
  DateTime get dateAdded => _dateAdded;

  set moldMatrixCode(String v) {
    _moldMatrixCode = v;
    notifyListeners();
  }

  set patternClassification(PatternClassification v) {
    _patternClassification = v;
    notifyListeners();
  }

  set castMetalType(CastMetalType v) {
    _castMetalType = v;
    notifyListeners();
  }

  set artisanHallmark(String v) {
    _artisanHallmark = v;
    notifyListeners();
  }

  set shrinkageAllowanceFactor(String v) {
    _shrinkageAllowanceFactor = v;
    notifyListeners();
  }

  set draftAngleGeometry(String v) {
    _draftAngleGeometry = v;
    notifyListeners();
  }

  set materialJoinerySeal(String v) {
    _materialJoinerySeal = v;
    notifyListeners();
  }

  set volumetricFootprint(String v) {
    _volumetricFootprint = v;
    notifyListeners();
  }

  set preservationSoundness(PreservationSoundness v) {
    _preservationSoundness = v;
    notifyListeners();
  }

  set smeltingGroundZero(String v) {
    _smeltingGroundZero = v;
    notifyListeners();
  }

  set temperatureRange(String v) {
    _temperatureRange = v;
    notifyListeners();
  }

  set era(FoundryEra v) {
    _era = v;
    notifyListeners();
  }

  set archivalNotes(String v) {
    _archivalNotes = v;
    notifyListeners();
  }

  set photoPath(String v) {
    _photoPath = v;
    notifyListeners();
  }

  set tags(List<String> v) {
    _tags = v;
    notifyListeners();
  }

  set dateAdded(DateTime v) {
    _dateAdded = v;
    notifyListeners();
  }

  void clearAll() {
    _moldMatrixCode = '';
    _patternClassification = PatternClassification.splitPattern;
    _castMetalType = CastMetalType.greyIron;
    _artisanHallmark = '';
    _shrinkageAllowanceFactor = '';
    _draftAngleGeometry = '';
    _materialJoinerySeal = '';
    _volumetricFootprint = '';
    _preservationSoundness = PreservationSoundness.unknown;
    _smeltingGroundZero = '';
    _temperatureRange = '';
    _era = FoundryEra.s1890s;
    _archivalNotes = '';
    _photoPath = '';
    _tags = [];
    _dateAdded = DateTime.now();
    notifyListeners();
  }
}

final inputProvider = ChangeNotifierProvider<InputNotifier>(
  (ref) => InputNotifier(),
);
