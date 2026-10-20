import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:isu_camp_app/features/dashboard/screens/map_view_screen.dart';
import 'package:isu_camp_app/features/dashboard/widgets/navigation_sheets.dart';
import 'package:latlong2/latlong.dart';

import 'live_navigation_test.dart' show TestGps;

void main() {
  testWidgets('the route line shrinks behind the user while navigating',
      (tester) async {
    final previousGps = GeolocatorPlatform.instance;
    final gps = TestGps()..current = TestGps.fix(16.72, 121.69, speed: 0);
    GeolocatorPlatform.instance = gps;
    addTearDown(() async {
      GeolocatorPlatform.instance = previousGps;
      await gps.fixes.close();
      await tester.binding.setSurfaceSize(null);
    });
    final tile = File('assets/images/logo_isu_png.png').readAsBytesSync();
    const distance = Distance();
    List<LatLng> drawnRoute() => tester
        .widget<PolylineLayer>(find.byType(PolylineLayer))
        .polylines
        .single
        .points;

    await http.runWithClient(() async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      await tester.pumpWidget(const MaterialApp(home: MapViewScreen()));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.byKey(const ValueKey('building-icon-1')));
      await tester.pump();
      await tester.tap(find.text('DIRECTIONS'));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('route-origin-field')));
      await tester.pump();
      await tester.tap(find.text('Use My Current Location'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.ensureVisible(find.text('View Route'));
      await tester.tap(find.text('View Route'));
      await tester.pump();
      // Route details still show the whole route.
      expect(drawnRoute(), hasLength(3));
      await tester.ensureVisible(find.text('Start'));
      await tester.tap(find.text('Start'));
      for (var i = 0;
          i < 10 && find.byType(ActiveNavigationHud).evaluate().isEmpty;
          i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(find.byType(ActiveNavigationHud), findsOneWidget);

      gps.move(16.7205, 121.69, speed: 0);
      await tester.pump();
      expect(distance(drawnRoute().first, const LatLng(16.7205, 121.69)),
          lessThan(1));
      expect(drawnRoute(), hasLength(3));

      // A fix slightly behind does not bring the walked route back.
      gps.move(16.7203, 121.69, speed: 0);
      await tester.pump();
      expect(distance(drawnRoute().first, const LatLng(16.7205, 121.69)),
          lessThan(1));

      // Round the corner: the first leg is gone.
      gps.move(16.721, 121.6905, speed: 0);
      await tester.pump();
      expect(drawnRoute(), hasLength(2));
      expect(distance(drawnRoute().first, const LatLng(16.721, 121.6905)),
          lessThan(1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    },
        () => MockClient((request) async {
              if (request.url.path == '/campus/buildings') {
                return http.Response(
                    jsonEncode({
                      'buildings': [
                        {
                          'id': '1',
                          'name': 'Test Building',
                          'acronym': 'TEST',
                          'latitude': 16.721,
                          'longitude': 121.691,
                        }
                      ]
                    }),
                    200);
              }
              if (request.url.path == '/campus/routes') {
                return http.Response(
                    jsonEncode({
                      'routes': [
                        for (final type in ['shortest', 'comfortableShaded'])
                          {
                            'type': type,
                            'mode': 'walking',
                            'distanceMeters': 220,
                            'estimatedMinutes': 3,
                            'startNodeName': 'Gate',
                            'pathPoints': [
                              [16.72, 121.69],
                              [16.721, 121.69],
                              [16.721, 121.691]
                            ],
                            'steps': [],
                          }
                      ]
                    }),
                    200);
              }
              return http.Response.bytes(tile, 200,
                  headers: {'content-type': 'image/png'});
            }));
  });
}
