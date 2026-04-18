import 'package:app/core/theme/app_button_styles.dart';
import 'package:app/core/theme/app_theme.dart';
import 'package:app/features/places/data/place_catalog.dart';
import 'package:app/features/places/domain/place.dart';
import 'package:app/features/rating/domain/digit_recognizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RatingPage extends StatefulWidget {
  const RatingPage({super.key});

  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  static const _size = DigitRecognizer.size;
  final _recognizer = DigitRecognizer();
  final _pixels = List<bool>.filled(_size * _size, false);
  final _places = PlaceCatalog.places;
  final Map<String, List<int>> _ratingsByPlaceId = <String, List<int>>{};

  PlaceType? _selectedType;
  CampusPlace? _selectedPlace;
  DigitRecognition? _result;

  List<CampusPlace> get _filteredPlaces {
    if (_selectedType == null) return const [];
    return _places
        .where((p) => p.type == _selectedType)
        .toList(growable: false);
  }

  void _toggleCell(int index) {
    setState(() {
      _pixels[index] = !_pixels[index];
      _result = _recognizer.recognize(_pixels);
    });
  }

  void _clearDigitGrid() {
    setState(() {
      for (var i = 0; i < _pixels.length; i++) {
        _pixels[i] = false;
      }
      _result = null;
    });
  }

  void _saveRating() {
    final result = _result;
    final place = _selectedPlace;
    if (result == null || place == null) return;

    _ratingsByPlaceId.putIfAbsent(place.id, () => <int>[]).add(result.digit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Оценка ${result.digit} сохранена для ${place.name}'),
      ),
    );
    setState(() {});
  }

  double? _averageFor(String placeId) {
    final values = _ratingsByPlaceId[placeId];
    if (values == null || values.isEmpty) return null;
    final sum = values.fold<int>(0, (acc, v) => acc + v);
    return sum / values.length;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredPlaces;
    final predicted = _result?.digit;
    final confidence = _result?.confidence;
    final avg = _selectedPlace == null ? null : _averageFor(_selectedPlace!.id);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Тип заведения',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            _TypeDropdown(
              value: _selectedType,
              onChanged: (type) {
                setState(() {
                  _selectedType = type;
                  final list = _filteredPlaces;
                  _selectedPlace = list.isEmpty ? null : list.first;
                });
              },
            ),
            const SizedBox(height: 10),
            const Text(
              'Заведение (из выбранного фильтра)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.softSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<CampusPlace>(
                  isExpanded: true,
                  value: filtered.contains(_selectedPlace)
                      ? _selectedPlace
                      : null,
                  hint: const Text('Сначала выберите тип'),
                  onChanged: filtered.isEmpty
                      ? null
                      : (value) {
                          if (value == null) return;
                          setState(() {
                            _selectedPlace = value;
                          });
                        },
                  items: filtered
                      .map(
                        (p) => DropdownMenuItem<CampusPlace>(
                          value: p,
                          child: Text(p.name),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (_selectedPlace == null)
              const Text('Средняя оценка: выберите заведение')
            else if (avg == null)
              const Text('Средняя оценка: пока нет')
            else
              Text('Средняя оценка: ${avg.toStringAsFixed(2)}'),
            const SizedBox(height: 14),
            const Text(
              'Нарисуйте цифру 0..9 на сетке 5x5',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Center(
              child: SizedBox(
                width: 250,
                height: 250,
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pixels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _size,
                    crossAxisSpacing: 6,
                    mainAxisSpacing: 6,
                  ),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _toggleCell(index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 90),
                        decoration: BoxDecoration(
                          color: _pixels[index] ? Colors.black : Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFB0BEC5)),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: AppButtonStyles.resolve(
                      context,
                      variant: AppButtonVariant.soft,
                      radius: 0,
                    ),
                    onPressed: _clearDigitGrid,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Очистить'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: AppButtonStyles.resolve(context, radius: 0),
                    onPressed: predicted != null && _selectedPlace != null
                        ? _saveRating
                        : null,
                    icon: const Icon(Icons.save),
                    label: const Text('Сохранить оценку'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (predicted == null)
              const Text('Распознавание: нет данных')
            else
              Text(
                'Распознано: $predicted (уверенность ${(confidence! * 100).toStringAsFixed(1)}%)',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  const _TypeDropdown({required this.value, required this.onChanged});

  final PlaceType? value;
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
        child: DropdownButton<PlaceType>(
          isExpanded: true,
          value: value,
          hint: const Text('Тип не выбран'),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          onChanged: onChanged,
          items: PlaceType.values
              .map((type) {
                return DropdownMenuItem<PlaceType>(
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
              })
              .toList(growable: false),
        ),
      ),
    );
  }
}
