import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echoes_of_the_foundry_floor/models/foundry_artifact_model.dart';

class SearchNotifier extends ChangeNotifier {
  String searchQuery = '';

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearSearchQuery() {
    searchQuery = '';
    notifyListeners();
  }

  List<FoundryArtifactModel> filteredList(List<FoundryArtifactModel> list) {
    if (searchQuery.isEmpty) return list;

    final query = searchQuery.toLowerCase();
    return list
        .where(
          (item) =>
              item.moldMatrixCode.toLowerCase().contains(query) ||
              item.artisanHallmark.toLowerCase().contains(query) ||
              item.patternClassification.label.toLowerCase().contains(query) ||
              item.castMetalType.label.toLowerCase().contains(query) ||
              item.shrinkageAllowanceFactor.toLowerCase().contains(query) ||
              item.smeltingGroundZero.toLowerCase().contains(query) ||
              item.materialJoinerySeal.toLowerCase().contains(query) ||
              item.tags.any((tag) => tag.toLowerCase().contains(query)),
        )
        .toList();
  }
}

final searchProvider = ChangeNotifierProvider((ref) => SearchNotifier());
