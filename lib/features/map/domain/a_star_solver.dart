import 'dart:math';

import 'package:app/features/map/domain/grid_map.dart';
import 'package:flutter/material.dart';

class AStarSolver {
  const AStarSolver();

  List<Offset> findPath({
    required GridMap grid,
    required Offset startNormalized,
    required Offset finishNormalized,
  }) {
    final startCell = toCell(startNormalized, grid.width, grid.height);
    final finishCell = toCell(finishNormalized, grid.width, grid.height);

    if (!grid.isWalkable(startCell.x, startCell.y) ||
        !grid.isWalkable(finishCell.x, finishCell.y)) {
      return const [];
    }

    final open = <Cell>{startCell};
    final cameFrom = <Cell, Cell>{};
    final gScore = <Cell, int>{startCell: 0};
    final fScore = <Cell, int>{startCell: _manhattan(startCell, finishCell)};

    while (open.isNotEmpty) {
      final current = open.reduce(
        (a, b) => (fScore[a] ?? 1 << 30) <= (fScore[b] ?? 1 << 30) ? a : b,
      );

      if (current == finishCell) {
        final cells = <Cell>[current];
        var cursor = current;
        while (cameFrom.containsKey(cursor)) {
          cursor = cameFrom[cursor]!;
          cells.add(cursor);
        }
        return cells.reversed
            .map((cell) => toNormalizedCenter(cell, grid.width, grid.height))
            .toList(growable: false);
      }

      open.remove(current);
      for (final next in _neighbors(current, grid)) {
        final tentative = (gScore[current] ?? 1 << 30) + 1;
        if (tentative < (gScore[next] ?? 1 << 30)) {
          cameFrom[next] = current;
          gScore[next] = tentative;
          fScore[next] = tentative + _manhattan(next, finishCell);
          open.add(next);
        }
      }
    }

    return const [];
  }

  Cell toCell(Offset point, int width, int height) {
    final x = min(width - 1, max(0, (point.dx * width).floor()));
    final y = min(height - 1, max(0, (point.dy * height).floor()));
    return Cell(x, y);
  }

  Offset toNormalizedCenter(Cell cell, int width, int height) {
    return Offset((cell.x + 0.5) / width, (cell.y + 0.5) / height);
  }

  int _manhattan(Cell a, Cell b) {
    return (a.x - b.x).abs() + (a.y - b.y).abs();
  }

  Iterable<Cell> _neighbors(Cell cell, GridMap grid) sync* {
    const directions = <Offset>[
      Offset(1, 0),
      Offset(-1, 0),
      Offset(0, 1),
      Offset(0, -1),
    ];

    for (final direction in directions) {
      final nx = cell.x + direction.dx.toInt();
      final ny = cell.y + direction.dy.toInt();
      if (grid.isWalkable(nx, ny)) {
        yield Cell(nx, ny);
      }
    }
  }
}
