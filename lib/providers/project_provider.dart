import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:echoes_of_the_foundry_floor/models/foundry_artifact_model.dart';
import 'package:echoes_of_the_foundry_floor/providers/image_provider.dart';
import 'package:echoes_of_the_foundry_floor/providers/input_provider.dart';
import 'package:echoes_of_the_foundry_floor/utils/code_generator.dart';

class ProjectNotifier extends ChangeNotifier {
  ProjectNotifier() {
    loadEntries();
  }

  List<FoundryArtifactModel> entries = [];
  bool isLoading = true;
  int stateVersion = 0;
  static const String _storageKey = 'eff_entries_v1';
  final _uuid = const Uuid();

  Future<void> loadEntries() async {
    isLoading = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(_storageKey);
      if (jsonString != null) {
        final List<dynamic> decodedList = jsonDecode(jsonString);
        entries = decodedList
            .map((item) => FoundryArtifactModel.fromJson(item))
            .toList();
      }
    } catch (e) {
      debugPrint('Error loading entries: $e');
      entries = [];
    } finally {
      isLoading = false;
      stateVersion++;
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedList = jsonEncode(
      entries.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, encodedList);
  }

  FoundryArtifactModel _buildFromInput(WidgetRef ref, {String? existingId}) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final code = p.moldMatrixCode.isNotEmpty
        ? p.moldMatrixCode
        : generateMoldMatrixCode(
            classification: p.patternClassification,
            metal: p.castMetalType,
          );

    return FoundryArtifactModel(
      id: existingId ?? _uuid.v4(),
      moldMatrixCode: code,
      patternClassification: p.patternClassification,
      castMetalType: p.castMetalType,
      artisanHallmark: p.artisanHallmark,
      shrinkageAllowanceFactor: p.shrinkageAllowanceFactor,
      draftAngleGeometry: p.draftAngleGeometry,
      materialJoinerySeal: p.materialJoinerySeal,
      volumetricFootprint: p.volumetricFootprint,
      preservationSoundness: p.preservationSoundness,
      smeltingGroundZero: p.smeltingGroundZero,
      temperatureRange: p.temperatureRange,
      era: p.era,
      archivalNotes: p.archivalNotes,
      photoPath:
          imgProv.resultImage.isNotEmpty ? imgProv.resultImage : p.photoPath,
      tags: List<String>.from(p.tags),
      dateAdded: p.dateAdded,
    );
  }

  void addEntry(WidgetRef ref) {
    entries.add(_buildFromInput(ref));
    _save();
    stateVersion++;
    notifyListeners();
  }

  void editEntry(WidgetRef ref, int index) {
    final existing = entries[index];
    entries[index] = _buildFromInput(ref, existingId: existing.id)
      ..dateAdded = existing.dateAdded
      ..photoPath = ref.read(imageProvider).resultImage.isNotEmpty
          ? ref.read(imageProvider).resultImage
          : existing.photoPath;
    _save();
    stateVersion++;
    notifyListeners();
  }

  void deleteEntry(int index) {
    entries.removeAt(index);
    _save();
    stateVersion++;
    notifyListeners();
  }

  void fillInput(WidgetRef ref, int index) {
    final p = ref.read(inputProvider);
    final imgProv = ref.read(imageProvider);
    final entry = entries[index];

    p.moldMatrixCode = entry.moldMatrixCode;
    p.patternClassification = entry.patternClassification;
    p.castMetalType = entry.castMetalType;
    p.artisanHallmark = entry.artisanHallmark;
    p.shrinkageAllowanceFactor = entry.shrinkageAllowanceFactor;
    p.draftAngleGeometry = entry.draftAngleGeometry;
    p.materialJoinerySeal = entry.materialJoinerySeal;
    p.volumetricFootprint = entry.volumetricFootprint;
    p.preservationSoundness = entry.preservationSoundness;
    p.smeltingGroundZero = entry.smeltingGroundZero;
    p.temperatureRange = entry.temperatureRange;
    p.era = entry.era;
    p.archivalNotes = entry.archivalNotes;
    p.photoPath = entry.photoPath;
    p.tags = List<String>.from(entry.tags);
    p.dateAdded = entry.dateAdded;

    imgProv.resultImage = entry.photoPath;
    notifyListeners();
  }
}

final projectProvider = ChangeNotifierProvider<ProjectNotifier>(
  (ref) => ProjectNotifier(),
);
