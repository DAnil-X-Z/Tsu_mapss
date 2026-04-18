import 'dart:convert';

import 'package:app/features/map/domain/grid_map.dart';
import 'package:flutter/services.dart';

class GridMapLoader {
  const GridMapLoader();

  Future<GridMap> loadFromAssets(String path) async {
    final raw = await rootBundle.loadString(path);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final width = data['width'] as int;
    final height = data['height'] as int;
    final cells = (data['cells'] as List)
        .map(
          (row) =>
              (row as List).map((cell) => cell as int).toList(growable: false),
        )
        .toList(growable: false);
    return GridMap(width: width, height: height, cells: cells);
  }
}
