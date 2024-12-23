//-----------------------------------------
//-  Copyright (c) 2024. Liubchenko Oleh  -
//-----------------------------------------

class MarkerModel {
  final String id;
  final double latitude;
  final double longitude;
  final String title;
  final String description;
  final String unit;

  MarkerModel({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.title,
    required this.description,
    required this.unit,
  });

  factory MarkerModel.fromMap(Map<String, dynamic> map) {
    return MarkerModel(
      id: map['id'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      unit: map['unit'] ?? '',
    );
  }
}