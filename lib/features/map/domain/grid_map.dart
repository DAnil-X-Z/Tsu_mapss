class GridMap {
  const GridMap({
    required this.width,
    required this.height,
    required this.cells,
  });

  final int width;
  final int height;
  final List<List<int>> cells;

  bool isWalkable(int x, int y) {
    if (x < 0 || y < 0 || x >= width || y >= height) return false;
    return cells[y][x] == 1;
  }
}

class Cell {
  const Cell(this.x, this.y);

  final int x;
  final int y;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cell && other.x == x && other.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}
