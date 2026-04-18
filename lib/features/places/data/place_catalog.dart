import 'package:app/features/places/domain/place.dart';
import 'package:flutter/material.dart';

class PlaceCatalog {
  static const List<CampusPlace> places = <CampusPlace>[
    CampusPlace(
      id: 'starbooks',
      name: 'Starbooks',
      type: PlaceType.coffee,
      position: Offset(0.47, 0.23),
    ),
    CampusPlace(
      id: 'bus_stop_coffee',
      name: 'Bus Stop Coffee',
      type: PlaceType.coffee,
      position: Offset(0.50, 0.24),
    ),
    CampusPlace(
      id: 'yarche',
      name: 'Yarche',
      type: PlaceType.snack,
      position: Offset(0.54, 0.25),
    ),
    CampusPlace(
      id: 'siberian_pancakes',
      name: 'Siberian Pancakes',
      type: PlaceType.pancakes,
      position: Offset(0.42, 0.31),
    ),
    CampusPlace(
      id: 'blin_corner',
      name: 'Pancake Corner',
      type: PlaceType.pancakes,
      position: Offset(0.57, 0.31),
    ),
    CampusPlace(
      id: 'main_cafeteria',
      name: 'Main Cafeteria',
      type: PlaceType.fullMeal,
      position: Offset(0.40, 0.43),
    ),
    CampusPlace(
      id: 'second_cafeteria',
      name: 'Second Building Cafe',
      type: PlaceType.fullMeal,
      position: Offset(0.50, 0.43),
    ),
    CampusPlace(
      id: 'coffee_point',
      name: 'Coffee Point',
      type: PlaceType.coffee,
      position: Offset(0.60, 0.43),
    ),
    CampusPlace(
      id: 'snack_station',
      name: 'Snack Station',
      type: PlaceType.snack,
      position: Offset(0.46, 0.58),
    ),
    CampusPlace(
      id: 'vending_machine',
      name: 'Vending Machine',
      type: PlaceType.snack,
      position: Offset(0.53, 0.58),
    ),
    CampusPlace(
      id: 'lunch_hall',
      name: 'Lunch Hall',
      type: PlaceType.fullMeal,
      position: Offset(0.44, 0.69),
    ),
    CampusPlace(
      id: 'pancake_hub',
      name: 'Pancake Hub',
      type: PlaceType.pancakes,
      position: Offset(0.56, 0.69),
    ),
  ];
}
