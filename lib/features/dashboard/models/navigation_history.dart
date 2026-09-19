import 'campus_models.dart';

enum NavigationHistoryStatus {
  previewed,
  navigationStarted,
  endedEarly,
  completed,
}

class NavigationHistoryEntry {
  final String id;
  final String destinationId;
  final String destinationName;
  final String destinationAcronym;
  final String? roomId;
  final String? roomName;
  final String originLabel;
  final RouteType routeType;
  final TransportMode transportMode;
  final double distanceMeters;
  final double estimatedMinutes;
  final NavigationHistoryStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NavigationHistoryEntry({
    required this.id,
    required this.destinationId,
    required this.destinationName,
    required this.destinationAcronym,
    this.roomId,
    this.roomName,
    required this.originLabel,
    required this.routeType,
    required this.transportMode,
    required this.distanceMeters,
    required this.estimatedMinutes,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  NavigationHistoryEntry copyWith({
    NavigationHistoryStatus? status,
    DateTime? updatedAt,
  }) {
    return NavigationHistoryEntry(
      id: id,
      destinationId: destinationId,
      destinationName: destinationName,
      destinationAcronym: destinationAcronym,
      roomId: roomId,
      roomName: roomName,
      originLabel: originLabel,
      routeType: routeType,
      transportMode: transportMode,
      distanceMeters: distanceMeters,
      estimatedMinutes: estimatedMinutes,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'destinationId': destinationId,
        'destinationName': destinationName,
        'destinationAcronym': destinationAcronym,
        'roomId': roomId,
        'roomName': roomName,
        'originLabel': originLabel,
        'routeType': routeType.name,
        'transportMode': transportMode.name,
        'distanceMeters': distanceMeters,
        'estimatedMinutes': estimatedMinutes,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory NavigationHistoryEntry.fromJson(Map<String, dynamic> json) {
    T enumValue<T extends Enum>(List<T> values, String? name, T fallback) {
      return values.where((value) => value.name == name).firstOrNull ??
          fallback;
    }

    final now = DateTime.now();
    return NavigationHistoryEntry(
      id: json['id'] as String? ?? now.microsecondsSinceEpoch.toString(),
      destinationId: json['destinationId'] as String? ?? '',
      destinationName: json['destinationName'] as String? ?? 'Destination',
      destinationAcronym: json['destinationAcronym'] as String? ?? '',
      roomId: json['roomId'] as String?,
      roomName: json['roomName'] as String?,
      originLabel: json['originLabel'] as String? ?? 'ISU Echague Main Gate',
      routeType: enumValue(
        RouteType.values,
        json['routeType'] as String?,
        RouteType.shortest,
      ),
      transportMode: enumValue(
        TransportMode.values,
        json['transportMode'] as String?,
        TransportMode.walking,
      ),
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] as num?)?.toDouble() ?? 0,
      status: enumValue(
        NavigationHistoryStatus.values,
        json['status'] as String?,
        NavigationHistoryStatus.previewed,
      ),
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? now,
    );
  }
}
