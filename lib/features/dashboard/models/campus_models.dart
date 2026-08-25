import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum RoomCategory {
  laboratory,
  administrative,
  faculty,
  classroom,
  studyArea,
  facility,
  parking,
}

enum RouteType {
  shortest,
  comfortableShaded,
}

enum TransportMode {
  car,
  motorcycle,
  bicycle,
  walking,
}

class CampusRoom {
  final String id;
  final String title;
  final RoomCategory category;
  final String floor;
  final IconData icon;

  const CampusRoom({
    required this.id,
    required this.title,
    required this.category,
    required this.floor,
    required this.icon,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'category': category.name,
        'floor': floor,
      };

  factory CampusRoom.fromJson(Map<String, dynamic> json) => CampusRoom(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        category: RoomCategory.values.firstWhere(
          (e) => e.name == json['category'],
          orElse: () => RoomCategory.classroom,
        ),
        floor: json['floor'] ?? '1st Floor',
        icon: Icons.meeting_room_outlined,
      );
}

class NavigationStep {
  final String instruction;
  final String distance;
  final IconData icon;
  final LatLng coordinate;

  const NavigationStep({
    required this.instruction,
    required this.distance,
    required this.icon,
    required this.coordinate,
  });
}

class CampusRoute {
  final RouteType type;
  final String title;
  final String subtitle;
  final String distance;
  final String estimatedTime;
  final String arrivalTime;
  final IconData icon;
  final List<LatLng> pathPoints;
  final List<NavigationStep> steps;

  const CampusRoute({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.distance,
    required this.estimatedTime,
    this.arrivalTime = '9:46 am',
    required this.icon,
    required this.pathPoints,
    this.steps = const [],
  });

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'title': title,
        'subtitle': subtitle,
        'distance': distance,
        'estimatedTime': estimatedTime,
        'arrivalTime': arrivalTime,
        'pathPoints': pathPoints
            .map((p) => {'lat': p.latitude, 'lng': p.longitude})
            .toList(),
      };
}

class CampusBuilding {
  final String id;
  final String name;
  final String acronym;
  final String category;
  final String description;
  final LatLng coordinate;
  final String? imageUrl;
  final bool isParking;
  final bool hasShadedPath;
  final List<CampusRoom> rooms;
  final List<CampusRoute> routes;

  const CampusBuilding({
    required this.id,
    required this.name,
    required this.acronym,
    required this.category,
    required this.description,
    required this.coordinate,
    this.imageUrl,
    this.isParking = false,
    this.hasShadedPath = false,
    this.rooms = const [],
    this.routes = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'acronym': acronym,
        'category': category,
        'description': description,
        'latitude': coordinate.latitude,
        'longitude': coordinate.longitude,
        'imageUrl': imageUrl,
        'isParking': isParking,
        'hasShadedPath': hasShadedPath,
        'rooms': rooms.map((r) => r.toJson()).toList(),
        'routes': routes.map((r) => r.toJson()).toList(),
      };

  factory CampusBuilding.fromJson(Map<String, dynamic> json) => CampusBuilding(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        acronym: json['acronym'] ?? '',
        category: json['category'] ?? 'Academic Building',
        description: json['description'] ?? '',
        coordinate: LatLng(
          (json['latitude'] as num?)?.toDouble() ?? 16.7118,
          (json['longitude'] as num?)?.toDouble() ?? 121.6888,
        ),
        imageUrl: json['imageUrl'],
        isParking: json['isParking'] ?? false,
        hasShadedPath: json['hasShadedPath'] ?? false,
        rooms: (json['rooms'] as List<dynamic>?)
                ?.map((r) => CampusRoom.fromJson(r))
                .toList() ??
            [],
      );
}
