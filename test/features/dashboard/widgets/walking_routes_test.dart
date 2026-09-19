import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:latlong2/latlong.dart';
import 'package:isu_camp_app/features/dashboard/models/campus_models.dart';
import 'package:isu_camp_app/features/dashboard/widgets/navigation_sheets.dart';

void main() {
  const origin = NavigationOrigin(
      id: 'main_gate',
      label: 'Gate',
      coordinate: LatLng(16.72, 121.69),
      type: NavigationOriginType.mainGate);
  const destination = CampusBuilding(
      id: '1',
      name: 'Building',
      acronym: 'B',
      category: 'Building',
      description: '',
      coordinate: LatLng(16.721, 121.69));
  Map<String, dynamic> route(String type, int distance) => {
        'type': type,
        'distanceMeters': distance,
        'estimatedMinutes': 3,
        'startNodeName': 'Gate',
        'pathPoints': [
          [16.72, 121.69],
          [16.721, 121.69]
        ],
        'steps': [],
      };

  testWidgets('uses backend metrics and returns selected shaded route',
      (tester) async {
    WalkingRoute? selected;
    await http.runWithClient(() async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: ChooseRouteSheet(
        destination: destination,
        origin: origin,
        onBack: () {},
        onCancel: () {},
        onViewRoute: (route, mode) {
          selected = route;
        },
      ))));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('100 m'), findsOneWidget);
      expect(find.text('150 m'), findsOneWidget);
      await tester.tap(find.text('View Route'));
      expect(selected?.type, RouteType.comfortableShaded);
      expect(selected?.distanceMeters, 150);
      await tester.tap(find.byIcon(Icons.directions_car));
      await tester.pump();
      expect(find.text('Routing is currently available for Walking only.'),
          findsOneWidget);
      expect(
          tester
              .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'View Route'))
              .onPressed,
          isNull);
      expect(tester.takeException(), isNull);
    },
        () => MockClient((request) async {
              expect(request.method, 'POST');
              expect(jsonDecode(request.body)['destinationBuildingId'], '1');
              return http.Response(
                  jsonEncode({
                    'routes': [
                      route('shortest', 100),
                      route('comfortableShaded', 150)
                    ]
                  }),
                  200);
            }));
  });

  testWidgets('no-route message disables navigation', (tester) async {
    await http.runWithClient(() async {
      await tester.binding.setSurfaceSize(const Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(MaterialApp(
          home: Scaffold(
              body: ChooseRouteSheet(
        destination: destination,
        origin: origin,
        onBack: () {},
        onCancel: () {},
        onViewRoute: (_, __) => fail('No route must not navigate'),
      ))));
      await tester.pump();
      expect(find.text('No walking route'), findsOneWidget);
      expect(
          tester
              .widget<ElevatedButton>(
                  find.widgetWithText(ElevatedButton, 'View Route'))
              .onPressed,
          isNull);
      expect(find.text('Retry'), findsOneWidget);
    },
        () => MockClient(
            (_) async => http.Response('{"detail":"No walking route"}', 404)));
  });
}
