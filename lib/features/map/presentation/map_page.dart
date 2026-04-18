import 'package:app/core/theme/app_button_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/map/data/grid_map_loader.dart';
import 'package:app/features/map/domain/a_star_solver.dart';
import 'package:app/features/map/domain/grid_map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _PickMode { none, start, finish }

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  static const _gridPath = 'assets/data/grid.json';

  final _loader = const GridMapLoader();
  final _solver = const AStarSolver();

  _PickMode _pickMode = _PickMode.none;
  Offset? _start;
  Offset? _finish;
  List<Offset> _path = const [];
  bool _isBuildingRoute = false;
  bool _isGridLoading = true;
  GridMap? _grid;

  bool get _isGridReady => _grid != null;
  bool get _canBuildRoute =>
      _isGridReady && _start != null && _finish != null && !_isBuildingRoute;

  @override
  void initState() {
    super.initState();
    _loadGrid();
  }

  Future<void> _loadGrid() async {
    setState(() => _isGridLoading = true);
    try {
      final loaded = await _loader.loadFromAssets(_gridPath);
      if (!mounted) return;
      setState(() {
        _grid = loaded;
        _isGridLoading = false;
        _pickMode = _PickMode.none;
        _start = null;
        _finish = null;
        _path = const [];
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isGridLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить карту сетки')),
      );
    }
  }

  void _selectMode(_PickMode mode) {
    if (_isBuildingRoute || !_isGridReady) return;
    setState(() {
      _pickMode = _pickMode == mode ? _PickMode.none : mode;
    });
  }

  void _handleMapTap(TapDownDetails details, BoxConstraints constraints) {
    final grid = _grid;
    if (_pickMode == _PickMode.none || _isBuildingRoute || grid == null) return;

    final normalized = Offset(
      (details.localPosition.dx / constraints.maxWidth).clamp(0.0, 1.0),
      (details.localPosition.dy / constraints.maxHeight).clamp(0.0, 1.0),
    );
    final cell = _solver.toCell(normalized, grid.width, grid.height);

    if (!grid.isWalkable(cell.x, cell.y)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Эта точка находится на препятствии')),
      );
      return;
    }

    setState(() {
      if (_pickMode == _PickMode.start) {
        _start = normalized;
      } else {
        _finish = normalized;
      }
      _path = const [];
    });
  }

  Future<void> _buildRoute() async {
    final grid = _grid;
    if (!_canBuildRoute || grid == null || _start == null || _finish == null) {
      return;
    }

    setState(() {
      _isBuildingRoute = true;
      _pickMode = _PickMode.none;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    final route = _solver.findPath(
      grid: grid,
      startNormalized: _start!,
      finishNormalized: _finish!,
    );

    if (!mounted) return;
    setState(() {
      _path = route;
      _isBuildingRoute = false;
    });

    if (route.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Маршрут не существует')));
    }
  }

  void _resetAll() {
    if (_isBuildingRoute) return;
    setState(() {
      _pickMode = _PickMode.none;
      _start = null;
      _finish = null;
      _path = const [];
    });
  }

  @override
  Widget build(BuildContext context) {
    final grid = _grid;
    return SafeArea(
      top: false,
      child: Column(
        children: [
          if (_isGridLoading) const LinearProgressIndicator(minHeight: 3),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  onTapDown: (details) => _handleMapTap(details, constraints),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset('assets/map.png', fit: BoxFit.fill),
                      if (grid != null)
                        CustomPaint(
                          painter: _ObstaclePainter(
                            grid: grid.cells,
                            width: grid.width,
                            height: grid.height,
                          ),
                        ),
                      CustomPaint(
                        painter: _MapPainter(
                          start: _start,
                          finish: _finish,
                          path: _path,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            color: AppTheme.brand,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: _MapActionButton(
                    label: 'Старт',
                    iconAsset: 'assets/icons/ic_start.svg',
                    isActive: _pickMode == _PickMode.start,
                    onPressed: _isGridReady
                        ? () => _selectMode(_PickMode.start)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MapActionButton(
                    label: 'Путь',
                    iconAsset: 'assets/icons/ic_route.svg',
                    isLoading: _isBuildingRoute,
                    onPressed: _canBuildRoute ? _buildRoute : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MapActionButton(
                    label: 'Финиш',
                    iconAsset: 'assets/icons/ic_finish.svg',
                    isActive: _pickMode == _PickMode.finish,
                    onPressed: _isGridReady
                        ? () => _selectMode(_PickMode.finish)
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _MapActionButton(
                    label: 'Сброс',
                    iconAsset: 'assets/icons/ic_reset.svg',
                    onPressed: _resetAll,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ObstaclePainter extends CustomPainter {
  const _ObstaclePainter({
    required this.grid,
    required this.width,
    required this.height,
  });

  final List<List<int>> grid;
  final int width;
  final int height;

  @override
  void paint(Canvas canvas, Size size) {
    final obstaclePaint = Paint()..color = const Color(0x66000000);
    final cellW = size.width / width;
    final cellH = size.height / height;

    for (var y = 0; y < height; y++) {
      for (var x = 0; x < width; x++) {
        if (grid[y][x] == 0) {
          canvas.drawRect(
            Rect.fromLTWH(x * cellW, y * cellH, cellW, cellH),
            obstaclePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ObstaclePainter oldDelegate) {
    return oldDelegate.grid != grid ||
        oldDelegate.width != width ||
        oldDelegate.height != height;
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter({
    required this.start,
    required this.finish,
    required this.path,
  });

  final Offset? start;
  final Offset? finish;
  final List<Offset> path;

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length > 1) {
      final routePaint = Paint()
        ..color = AppTheme.brand
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final route = Path()
        ..moveTo(path.first.dx * size.width, path.first.dy * size.height);
      for (final point in path.skip(1)) {
        route.lineTo(point.dx * size.width, point.dy * size.height);
      }
      canvas.drawPath(route, routePaint);
    }

    if (start != null) {
      _drawPoint(canvas, size, start!, const Color(0xFF1B5E20), 'S');
    }
    if (finish != null) {
      _drawPoint(canvas, size, finish!, const Color(0xFFB71C1C), 'F');
    }
  }

  void _drawPoint(
    Canvas canvas,
    Size size,
    Offset normalized,
    Color color,
    String label,
  ) {
    final center = Offset(
      normalized.dx * size.width,
      normalized.dy * size.height,
    );
    canvas.drawCircle(center, 12, Paint()..color = color);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(
      canvas,
      center - Offset(textPainter.width / 2, textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.start != start ||
        oldDelegate.finish != finish ||
        oldDelegate.path != path;
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.label,
    required this.iconAsset,
    this.onPressed,
    this.isActive = false,
    this.isLoading = false,
  });

  final String label;
  final String iconAsset;
  final VoidCallback? onPressed;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final variant = isActive ? AppButtonVariant.active : AppButtonVariant.soft;

    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: AppButtonStyles.resolve(
          context,
          variant: variant,
          height: 56,
          radius: 0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            else
              SvgPicture.asset(
                iconAsset,
                width: 16,
                height: 16,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                softWrap: false,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
