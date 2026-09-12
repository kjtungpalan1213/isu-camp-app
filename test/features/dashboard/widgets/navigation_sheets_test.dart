import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isu_camp_app/features/dashboard/models/campus_models.dart';
import 'package:isu_camp_app/features/dashboard/widgets/navigation_sheets.dart';
import 'package:latlong2/latlong.dart';

void main() {
  const origin = NavigationOrigin(
    id: 'origin',
    label: 'Mock Origin',
    coordinate: LatLng(16.7216, 121.6917),
    type: NavigationOriginType.campusCenter,
  );
  const destination = CampusBuilding(
    id: 'destination',
    name: 'Mock Destination',
    acronym: 'MD',
    category: 'Academic',
    description: '',
    coordinate: LatLng(16.7187, 121.6884),
    rooms: [
      CampusRoom(
        id: 'room',
        title: 'Room 1',
        category: RoomCategory.classroom,
        floor: '1st Floor',
        icon: Icons.meeting_room,
      ),
    ],
  );

  test('mock route metrics use origin, preference, and transport mode', () {
    final shortestDistance = int.parse(
      RouteMetricsHelper.getDistanceString(
        origin,
        destination,
        RouteType.shortest,
        TransportMode.walking,
      ).replaceAll('m', ''),
    );
    final shadedDistance = int.parse(
      RouteMetricsHelper.getDistanceString(
        origin,
        destination,
        RouteType.comfortableShaded,
        TransportMode.walking,
      ).replaceAll('m', ''),
    );
    final walkingMinutes = int.parse(
      RouteMetricsHelper.getTimeString(
        origin,
        destination,
        RouteType.shortest,
        TransportMode.walking,
      ).split(' ').first,
    );
    final bicycleMinutes = int.parse(
      RouteMetricsHelper.getTimeString(
        origin,
        destination,
        RouteType.shortest,
        TransportMode.bicycle,
      ).split(' ').first,
    );

    expect(shortestDistance, greaterThan(0));
    expect(shadedDistance, greaterThan(shortestDistance));
    expect(walkingMinutes, greaterThanOrEqualTo(bicycleMinutes));
  });
}
