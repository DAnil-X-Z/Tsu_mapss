import 'package:flutter/material.dart';

class Dbscan {
  const Dbscan();

  List<int> run({
    required List<Offset> points,
    required double eps,
    required int minPts,
  }) {
    const unvisited = -99;
    const noise = -1;

    final labels = List<int>.filled(points.length, unvisited);
    final visited = List<bool>.filled(points.length, false);
    var clusterId = 0;

    for (var i = 0; i < points.length; i++) {
      if (visited[i]) continue;
      visited[i] = true;

      final neighbors = _regionQuery(points, i, eps);
      if (neighbors.length < minPts) {
        labels[i] = noise;
        continue;
      }

      _expandCluster(
        points: points,
        pointIndex: i,
        neighbors: neighbors,
        clusterId: clusterId,
        eps: eps,
        minPts: minPts,
        visited: visited,
        labels: labels,
      );
      clusterId++;
    }

    for (var i = 0; i < labels.length; i++) {
      if (labels[i] == unvisited) labels[i] = noise;
    }
    return labels;
  }

  void _expandCluster({
    required List<Offset> points,
    required int pointIndex,
    required List<int> neighbors,
    required int clusterId,
    required double eps,
    required int minPts,
    required List<bool> visited,
    required List<int> labels,
  }) {
    labels[pointIndex] = clusterId;
    final queue = List<int>.from(neighbors);
    var cursor = 0;

    while (cursor < queue.length) {
      final n = queue[cursor];
      cursor++;

      if (!visited[n]) {
        visited[n] = true;
        final nNeighbors = _regionQuery(points, n, eps);
        if (nNeighbors.length >= minPts) {
          for (final idx in nNeighbors) {
            if (!queue.contains(idx)) queue.add(idx);
          }
        }
      }

      if (labels[n] < 0) labels[n] = clusterId;
    }
  }

  List<int> _regionQuery(List<Offset> points, int index, double eps) {
    final neighbors = <int>[];
    final p = points[index];
    final eps2 = eps * eps;

    for (var i = 0; i < points.length; i++) {
      final dx = p.dx - points[i].dx;
      final dy = p.dy - points[i].dy;
      if (dx * dx + dy * dy <= eps2) {
        neighbors.add(i);
      }
    }
    return neighbors;
  }
}
