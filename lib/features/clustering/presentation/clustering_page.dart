import 'package:app/core/theme/app_button_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/clustering/domain/dbscan.dart';
import 'package:app/features/places/data/place_catalog.dart';
import 'package:app/features/places/domain/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum _PageMode { filter, clustering }

class ClusteringPage extends StatefulWidget {
  const ClusteringPage({super.key});

  @override
  State<ClusteringPage> createState() => _ClusteringPageState();
}

class _ClusteringPageState extends State<ClusteringPage> {
  final _dbscan = const Dbscan();

  static const _clusterPalette = <Color>[
    Color(0xFFE53935),
    Color(0xFF1E88E5),
    Color(0xFF43A047),
    Color(0xFFFDD835),
    Color(0xFF8E24AA),
    Color(0xFFFB8C00),
    Color(0xFF00897B),
    Color(0xFF6D4C41),
    Color(0xFFD81B60),
    Color(0xFF3949AB),
  ];

  final _places = PlaceCatalog.places;
  _PageMode _mode = _PageMode.filter;
  PlaceType? _selectedType;
  PlaceType? _clusterTypeFilter;
  double _eps = 0.12;
  int _minPts = 3;
  List<int?>? _dbscanLabels;

  List<CampusPlace> get _visibleFilterPlaces {
    if (_selectedType == null) return const [];
    return _places
        .where((p) => p.type == _selectedType)
        .toList(growable: false);
  }

  List<int> _clusterInputIndices() {
    final out = <int>[];
    for (var i = 0; i < _places.length; i++) {
      if (_clusterTypeFilter == null || _places[i].type == _clusterTypeFilter) {
        out.add(i);
      }
    }
    return out;
  }

  List<int?> _clusterPreviewLabels() {
    final labels = List<int?>.filled(_places.length, null);
    for (final idx in _clusterInputIndices()) {
      labels[idx] = -2;
    }
    return labels;
  }

  void _runDbscan() {
    final inputIndices = _clusterInputIndices();
    if (inputIndices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Нет точек для кластеризации')),
      );
      return;
    }

    final inputPoints = inputIndices
        .map((i) => _places[i].position)
        .toList(growable: false);
    final labelsSubset = _dbscan.run(
      points: inputPoints,
      eps: _eps,
      minPts: _minPts,
    );

    final labels = List<int?>.filled(_places.length, null);
    for (var i = 0; i < inputIndices.length; i++) {
      labels[inputIndices[i]] = labelsSubset[i];
    }

    setState(() => _dbscanLabels = labels);
  }

  String _buildDbscanSummary(List<int?> labels) {
    var maxCluster = -1;
    var noise = 0;
    var used = 0;
    for (final label in labels) {
      if (label == null || label == -2) continue;
      used++;
      if (label < 0) {
        noise++;
      } else if (label > maxCluster) {
        maxCluster = label;
      }
    }
    return 'Кластеров: ${maxCluster + 1}, шумовых точек: $noise, точек в расчете: $used';
  }

  ButtonStyle _chipStyle(BuildContext context, {required bool active}) {
    return AppButtonStyles.resolve(
      context,
      variant: active ? AppButtonVariant.active : AppButtonVariant.soft,
      height: 42,
      radius: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleFilterPlaces;

    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/map.png', fit: BoxFit.fill),
                if (_mode == _PageMode.filter)
                  CustomPaint(painter: _FilterPlacesPainter(places: visible)),
                if (_mode == _PageMode.clustering)
                  CustomPaint(
                    painter: _DbscanPainter(
                      places: _places,
                      labels: _dbscanLabels ?? _clusterPreviewLabels(),
                      palette: _clusterPalette,
                    ),
                  ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            decoration: const BoxDecoration(color: Color(0xFFF5F8FB)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: _chipStyle(
                          context,
                          active: _mode == _PageMode.filter,
                        ),
                        onPressed: () =>
                            setState(() => _mode = _PageMode.filter),
                        child: const Text('Фильтр по типу'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        style: _chipStyle(
                          context,
                          active: _mode == _PageMode.clustering,
                        ),
                        onPressed: () {
                          setState(() {
                            _mode = _PageMode.clustering;
                            _dbscanLabels = null;
                          });
                        },
                        child: const Text('Кластеризация'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (_mode == _PageMode.filter) ...[
                  const Text(
                    'Выберите тип заведения',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TypeDropdown(
                    value: _selectedType,
                    hint: 'Тип не выбран',
                    onChanged: (v) => setState(() => _selectedType = v),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _selectedType == null
                        ? 'На карте пока нет точек'
                        : 'Показано точек: ${visible.length}',
                    style: const TextStyle(color: AppTheme.brandDark),
                  ),
                ],
                if (_mode == _PageMode.clustering) ...[
                  const Text(
                    'Тип для кластеризации',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.brandDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _TypeDropdown(
                    value: _clusterTypeFilter,
                    hint: 'Все типы',
                    includeAll: true,
                    onChanged: (v) {
                      setState(() {
                        _clusterTypeFilter = v;
                        _dbscanLabels = null;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Радиус объединения',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.brandDark,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _eps,
                          min: 0.03,
                          max: 0.20,
                          divisions: 34,
                          label: _eps.toStringAsFixed(3),
                          onChanged: (v) => setState(() => _eps = v),
                        ),
                      ),
                      SizedBox(
                        width: 52,
                        child: Text(
                          _eps.toStringAsFixed(3),
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: AppTheme.brandDark),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text(
                        'Минимум точек в группе',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.brandDark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 48,
                        child: ElevatedButton(
                          style: _chipStyle(context, active: false),
                          onPressed: _minPts > 2
                              ? () => setState(() => _minPts--)
                              : null,
                          child: const Icon(Icons.remove, size: 18),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.softSurface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text('$_minPts'),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 48,
                        child: ElevatedButton(
                          style: _chipStyle(context, active: false),
                          onPressed: _minPts < 8
                              ? () => setState(() => _minPts++)
                              : null,
                          child: const Icon(Icons.add, size: 18),
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        style: _chipStyle(context, active: false),
                        onPressed: _runDbscan,
                        icon: const Icon(Icons.scatter_plot),
                        label: const Text('Запустить'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dbscanLabels == null
                        ? 'Выберите параметры и нажмите Запустить'
                        : _buildDbscanSummary(_dbscanLabels!),
                    style: const TextStyle(color: AppTheme.brandDark),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({
    required this.value,
    required this.hint,
    required this.onChanged,
    this.includeAll = false,
  });

  final PlaceType? value;
  final String hint;
  final bool includeAll;
  final ValueChanged<PlaceType?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.softSurface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<PlaceType?>(
          isExpanded: true,
          value: value,
          hint: Text(hint),
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: onChanged,
          items: <DropdownMenuItem<PlaceType?>>[
            if (includeAll)
              const DropdownMenuItem<PlaceType?>(
                value: null,
                child: Text('Все типы'),
              ),
            ...PlaceType.values.map((type) {
              return DropdownMenuItem<PlaceType?>(
                value: type,
                child: Row(
                  children: [
                    SvgPicture.asset(
                      type.iconAsset,
                      width: 18,
                      height: 18,
                      colorFilter: ColorFilter.mode(
                        type.color,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(type.label),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _FilterPlacesPainter extends CustomPainter {
  const _FilterPlacesPainter({required this.places});
  final List<CampusPlace> places;

  @override
  void paint(Canvas canvas, Size size) {
    for (final place in places) {
      final p = Offset(
        place.position.dx * size.width,
        place.position.dy * size.height,
      );
      canvas.drawCircle(p, 6.5, Paint()..color = place.type.color);
      canvas.drawCircle(
        p,
        6.5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _FilterPlacesPainter oldDelegate) =>
      oldDelegate.places != places;
}

class _DbscanPainter extends CustomPainter {
  const _DbscanPainter({
    required this.places,
    required this.labels,
    required this.palette,
  });

  final List<CampusPlace> places;
  final List<int?> labels;
  final List<Color> palette;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < places.length && i < labels.length; i++) {
      final label = labels[i];
      if (label == null) continue;
      final p = Offset(
        places[i].position.dx * size.width,
        places[i].position.dy * size.height,
      );
      final color = _colorForLabel(label, places[i]);
      canvas.drawCircle(p, 7.0, Paint()..color = color);
      canvas.drawCircle(
        p,
        7.0,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );
    }
  }

  Color _colorForLabel(int label, CampusPlace place) {
    if (label == -2) return place.type.color;
    if (label < 0) return const Color(0xFFB0BEC5);
    return palette[label % palette.length];
  }

  @override
  bool shouldRepaint(covariant _DbscanPainter oldDelegate) {
    return oldDelegate.places != places || oldDelegate.labels != labels;
  }
}
