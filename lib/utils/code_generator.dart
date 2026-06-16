import 'dart:math';

import 'package:echoes_of_the_foundry_floor/enum/foundry_enums.dart';

String generateMoldMatrixCode({
  required PatternClassification classification,
  required CastMetalType metal,
}) {
  final random = Random();
  final serial = (1000 + random.nextInt(9000)).toString();
  return 'EFF-${classification.codeAbbrev}-$serial-${metal.codeAbbrev}-P';
}
