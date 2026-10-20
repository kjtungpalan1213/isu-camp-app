import 'package:flutter_test/flutter_test.dart';
import 'package:isu_camp_app/features/dashboard/models/route_trim.dart';
import 'package:latlong2/latlong.dart';

void main() {
  // About 111 m north, then about 107 m east.
  const route = [
    LatLng(16.72, 121.69),
    LatLng(16.721, 121.69),
    LatLng(16.721, 121.691),
  ];
  const distance = Distance();

  test('the line starts where the user is on the route', () {
    final trim = RouteTrim(route);
    final ahead = trim.ahead(const LatLng(16.7205, 121.69));
    expect(distance(ahead.first, const LatLng(16.7205, 121.69)), lessThan(1));
    expect(ahead.sublist(1), route.sublist(1));
  });

  test('a position off to the side snaps onto the route', () {
    final ahead = RouteTrim(route).ahead(const LatLng(16.7205, 121.69005));
    expect(distance(ahead.first, const LatLng(16.7205, 121.69)), lessThan(1));
  });

  test('past a corner, the walked leg is gone', () {
    final ahead = RouteTrim(route).ahead(const LatLng(16.721, 121.6905));
    expect(ahead, hasLength(2));
    expect(ahead.last, route.last);
    expect(distance(ahead.first, const LatLng(16.721, 121.6905)), lessThan(1));
  });

  test('the full route shows before the user reaches it', () {
    expect(RouteTrim(route).ahead(const LatLng(16.7198, 121.69)), route);
  });

  test('walked route never grows back', () {
    final trim = RouteTrim(route);
    trim.ahead(const LatLng(16.7208, 121.69));
    final ahead = trim.ahead(const LatLng(16.7203, 121.69));
    expect(distance(ahead.first, const LatLng(16.7208, 121.69)), lessThan(1));
  });

  test('positions far from the route do not move the trim', () {
    final trim = RouteTrim(route);
    trim.ahead(const LatLng(16.7202, 121.69));
    // Well east of the route: a wrong GPS fix, not progress.
    final ahead = trim.ahead(const LatLng(16.7205, 121.693));
    expect(distance(ahead.first, const LatLng(16.7202, 121.69)), lessThan(1));
  });

  test('at the destination, only the end point is left', () {
    final ahead = RouteTrim(route).ahead(route.last);
    expect(ahead, hasLength(1));
    expect(distance(ahead.single, route.last), lessThan(1));
  });

  test('an empty route stays empty', () {
    expect(RouteTrim(const []).ahead(route.first), isEmpty);
  });
}
