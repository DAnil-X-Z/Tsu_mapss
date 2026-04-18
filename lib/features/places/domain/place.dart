import 'package:flutter/material.dart';

enum PlaceType {
  coffee('Кофе', 'assets/icons/ic_type_coffee.svg', Color(0xFF6D4C41)),
  pancakes('Блины', 'assets/icons/ic_type_pancakes.svg', Color(0xFFF57C00)),
  fullMeal('Полный обед', 'assets/icons/ic_type_full_meal.svg', Color(0xFF2E7D32)),
  snack('Перекус', 'assets/icons/ic_type_snack.svg', Color(0xFF1565C0));

  const PlaceType(this.label, this.iconAsset, this.color);

  final String label;
  final String iconAsset;
  final Color color;
}

class CampusPlace {
  const CampusPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
  });

  final String id;
  final String name;
  final PlaceType type;
  final Offset position;
}
