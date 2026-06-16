enum PatternClassification {
  splitPattern('Split Pattern'),
  coreBox('Core Box'),
  matchPlate('Match-Plate'),
  moldingSlick('Molding Slick'),
  shrinkageRule('Shrinkage Rule');

  const PatternClassification(this.label);
  final String label;

  String get codeAbbrev {
    switch (this) {
      case PatternClassification.splitPattern:
        return 'SPLIT';
      case PatternClassification.coreBox:
        return 'CORE';
      case PatternClassification.matchPlate:
        return 'MATCH';
      case PatternClassification.moldingSlick:
        return 'SLICK';
      case PatternClassification.shrinkageRule:
        return 'RULE';
    }
  }
}

enum CastMetalType {
  greyIron('Grey Iron'),
  malleableIron('Malleable Iron'),
  bronze('Bronze'),
  brass('Brass'),
  aluminium('Aluminium'),
  steel('Steel');

  const CastMetalType(this.label);
  final String label;

  String get shrinkageDefault {
    switch (this) {
      case CastMetalType.greyIron:
        return '3/16" per foot';
      case CastMetalType.malleableIron:
        return '3/16" per foot';
      case CastMetalType.bronze:
        return '3/32" per foot';
      case CastMetalType.brass:
        return '3/32" per foot';
      case CastMetalType.aluminium:
        return '1/8" per foot';
      case CastMetalType.steel:
        return '1/4" per foot';
    }
  }

  String get codeAbbrev {
    switch (this) {
      case CastMetalType.greyIron:
        return 'IRON';
      case CastMetalType.malleableIron:
        return 'MALL';
      case CastMetalType.bronze:
        return 'BRNZ';
      case CastMetalType.brass:
        return 'BRSS';
      case CastMetalType.aluminium:
        return 'ALUM';
      case CastMetalType.steel:
        return 'STEL';
    }
  }
}

enum DraftAngleProfile {
  shallowTaper('1° shallow taper'),
  standardTaper('2° positive taper'),
  moderateBevel('3° moderate bevel'),
  deepBevel('Deep bevel profile'),
  compoundDraft('Compound draft surfaces');

  const DraftAngleProfile(this.label);
  final String label;
}

enum PreservationSoundness {
  operational('Operational — Ready to cast'),
  woodWarpingTolerance('Wood warping tolerance'),
  sandAbrasionScoring('Sand abrasion scoring'),
  shellacFlaking('Shellac flaking percentage'),
  displayOnly('Display only — case specimen'),
  degraded('Degraded — dimensional drift'),
  unknown('Unknown condition');

  const PreservationSoundness(this.label);
  final String label;
}

enum FoundryEra {
  pre1850('Pre-1850'),
  s1850s('1850s'),
  s1860s('1860s'),
  s1870s('1870s'),
  s1880s('1880s'),
  s1890s('1890s'),
  s1900s('1900s'),
  s1910s('1910s'),
  s1920s('1920s'),
  s1930s('1930s'),
  s1940s('1940s'),
  postwar('Post-War');

  const FoundryEra(this.label);
  final String label;
}
