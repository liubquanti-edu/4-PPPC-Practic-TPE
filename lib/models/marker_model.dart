//-----------------------------------------
//-  Copyright (c) 2024. Liubchenko Oleh  -
//-----------------------------------------

class MarkerModel {
  final String id;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String unit;

  MarkerModel({
    required this.id,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.unit,
  });

  factory MarkerModel.fromMap(Map<String, dynamic> map, String id) {
    return MarkerModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      unit: map['unit'] ?? 'gas',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'unit': unit,
    };
  }
}