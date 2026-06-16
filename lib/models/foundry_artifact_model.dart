import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';

class FoundryArtifactModel {
  String id;
  String moldMatrixCode;
  PatternClassification patternClassification;
  CastMetalType castMetalType;
  String artisanHallmark;
  String shrinkageAllowanceFactor;
  String draftAngleGeometry;
  String materialJoinerySeal;
  String volumetricFootprint;
  PreservationSoundness preservationSoundness;
  String smeltingGroundZero;
  String temperatureRange;
  FoundryEra era;
  String archivalNotes;
  String photoPath;
  List<String> tags;
  DateTime dateAdded;

  FoundryArtifactModel({
    required this.id,
    required this.moldMatrixCode,
    required this.patternClassification,
    required this.castMetalType,
    required this.artisanHallmark,
    required this.shrinkageAllowanceFactor,
    required this.draftAngleGeometry,
    required this.materialJoinerySeal,
    required this.volumetricFootprint,
    required this.preservationSoundness,
    required this.smeltingGroundZero,
    required this.temperatureRange,
    required this.era,
    required this.archivalNotes,
    required this.photoPath,
    required this.tags,
    required this.dateAdded,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'moldMatrixCode': moldMatrixCode,
        'patternClassification': patternClassification.name,
        'castMetalType': castMetalType.name,
        'artisanHallmark': artisanHallmark,
        'shrinkageAllowanceFactor': shrinkageAllowanceFactor,
        'draftAngleGeometry': draftAngleGeometry,
        'materialJoinerySeal': materialJoinerySeal,
        'volumetricFootprint': volumetricFootprint,
        'preservationSoundness': preservationSoundness.name,
        'smeltingGroundZero': smeltingGroundZero,
        'temperatureRange': temperatureRange,
        'era': era.name,
        'archivalNotes': archivalNotes,
        'photoPath': photoPath,
        'tags': tags,
        'dateAdded': dateAdded.toIso8601String(),
      };

  factory FoundryArtifactModel.fromJson(Map<String, dynamic> json) =>
      FoundryArtifactModel(
        id: json['id'] ?? '',
        moldMatrixCode: json['moldMatrixCode'] ?? '',
        patternClassification: PatternClassification.values
                .asNameMap()[json['patternClassification']] ??
            PatternClassification.splitPattern,
        castMetalType:
            CastMetalType.values.asNameMap()[json['castMetalType']] ??
                CastMetalType.greyIron,
        artisanHallmark: json['artisanHallmark'] ?? '',
        shrinkageAllowanceFactor: json['shrinkageAllowanceFactor'] ?? '',
        draftAngleGeometry: json['draftAngleGeometry'] ?? '',
        materialJoinerySeal: json['materialJoinerySeal'] ?? '',
        volumetricFootprint: json['volumetricFootprint'] ?? '',
        preservationSoundness: PreservationSoundness.values
                .asNameMap()[json['preservationSoundness']] ??
            PreservationSoundness.unknown,
        smeltingGroundZero: json['smeltingGroundZero'] ?? '',
        temperatureRange: json['temperatureRange'] ?? '',
        era: FoundryEra.values.asNameMap()[json['era']] ?? FoundryEra.s1890s,
        archivalNotes: json['archivalNotes'] ?? '',
        photoPath: json['photoPath'] ?? '',
        tags: List<String>.from(json['tags'] ?? []),
        dateAdded:
            DateTime.tryParse(json['dateAdded'] ?? '') ?? DateTime.now(),
      );
}
