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
  // A hairpin: about 111 m north, 11 m east, then back south alongside.
  const hairpin = [
    LatLng(16.72, 121.69),
    LatLng(16.721, 121.69),
    LatLng(16.721, 121.6901032),
    LatLng(16.72, 121.6901032),
  ];
  const distance = Distance();
  final start = DateTime(2026);
  DateTime after(int seconds) => start.add(Duration(seconds: seconds));

  test('the line starts where the user is on the route', () {
    final trim = RouteTrim(route, start);
    final ahead = trim.ahead(const LatLng(16.7205, 121.69), at: after(10));
    expect(distance(ahead.first, const LatLng(16.7205, 121.69)), lessThan(1));
    expect(ahead.sublist(1), route.sublist(1));
  });

  test('a position off to the side snaps onto the route', () {
    final ahead = RouteTrim(route, start)
        .ahead(const LatLng(16.7205, 121.69005), at: after(10));
    expect(distance(ahead.first, const LatLng(16.7205, 121.69)), lessThan(1));
  });

  test('past a corner, the walked leg is gone', () {
    final ahead = RouteTrim(route, start)
        .ahead(const LatLng(16.721, 121.6905), at: after(10));
    expect(ahead, hasLength(2));
    expect(ahead.last, route.last);
    expect(distance(ahead.first, const LatLng(16.721, 121.6905)), lessThan(1));
  });

  test('the full route shows before the user reaches it', () {
    expect(
        RouteTrim(route, start)
            .ahead(const LatLng(16.7198, 121.69), at: after(10)),
        route);
  });

  test('walked route never grows back', () {
    final trim = RouteTrim(route, start);
    trim.ahead(const LatLng(16.7208, 121.69), at: after(10));
    final ahead = trim.ahead(const LatLng(16.7203, 121.69), at: after(11));
    expect(distance(ahead.first, const LatLng(16.7208, 121.69)), lessThan(1));
  });

  test('positions far from the route do not move the trim', () {
    final trim = RouteTrim(route, start);
    trim.ahead(const LatLng(16.7202, 121.69), at: after(10));
    // Well east of the route: a wrong GPS fix, not progress.
    final ahead = trim.ahead(const LatLng(16.7205, 121.693), at: after(11));
    expect(distance(ahead.first, const LatLng(16.7202, 121.69)), lessThan(1));
  });

  test('at the destination, only the end point is left', () {
    final ahead = RouteTrim(route, start).ahead(route.last, at: after(20));
    expect(ahead, hasLength(1));
    expect(distance(ahead.single, route.last), lessThan(1));
  });

  test('an empty route stays empty', () {
    expect(
        RouteTrim(const [], start).ahead(route.first, at: after(1)), isEmpty);
  });

  test('walking along, the line keeps starting at the user', () {
    final trim = RouteTrim(route, start);
    // About 1.4 m/s, one fix a second.
    for (var second = 1; second <= 60; second++) {
      final position = LatLng(16.72 + 0.0000126 * second, 121.69);
      final ahead = trim.ahead(position, at: after(second));
      expect(distance(ahead.first, position), lessThan(1));
    }
  });

  test('a vehicle at speed is not left behind', () {
    final trim = RouteTrim(route, start);
    // About 18 m/s up the first leg.
    for (var second = 1; second <= 5; second++) {
      final position = LatLng(16.72 + 0.000162 * second, 121.69);
      final ahead = trim.ahead(position, at: after(second));
      expect(distance(ahead.first, position), lessThan(1));
    }
  });

  test('after a long GPS gap, the line catches up with the user', () {
    final trim = RouteTrim(route, start);
    trim.ahead(const LatLng(16.7201, 121.69), at: after(1));
    final ahead = trim.ahead(const LatLng(16.721, 121.6905), at: after(60));
    expect(ahead, hasLength(2));
    expect(distance(ahead.first, const LatLng(16.721, 121.6905)), lessThan(1));
  });

  test('a position too far ahead is caught up with soon after', () {
    final trim = RouteTrim(route, start);
    trim.ahead(const LatLng(16.7201, 121.69), at: after(1));
    // Past the corner a second later is implausible, but staying there is
    // not: the line follows within a few seconds.
    var ahead = trim.ahead(const LatLng(16.721, 121.6905), at: after(2));
    expect(ahead, hasLength(3));
    for (var second = 3; second <= 10; second++) {
      ahead = trim.ahead(const LatLng(16.721, 121.6905), at: after(second));
    }
    expect(ahead, hasLength(2));
    expect(distance(ahead.first, const LatLng(16.721, 121.6905)), lessThan(1));
  });

  test('a later leg close by does not swallow the route still ahead', () {
    final trim = RouteTrim(hairpin, start);
    // About 44 m up the first leg.
    trim.ahead(const LatLng(16.720396, 121.69), at: after(30));
    // 8 m sideways error: nearer the returning leg than the one walked.
    var ahead = trim.ahead(const LatLng(16.720405, 121.690075), at: after(31));
    expect(ahead, hasLength(4));
    for (var second = 32; second <= 35; second++) {
      final position = LatLng(16.720405 + 0.0000126 * (second - 31), 121.69);
      ahead = trim.ahead(position, at: after(second));
      expect(ahead, hasLength(4));
      expect(distance(ahead.first, position), lessThan(1));
    }
  });

  test('wobble while standing still does not let a later leg swallow the route',
      () {
    final trim = RouteTrim(hairpin, start);
    // Standing about 44 m up the first leg, fixes a few meters either way.
    for (var second = 1; second <= 30; second++) {
      trim.ahead(
          LatLng(16.720396 + (second.isEven ? 0.00003 : -0.00003), 121.69),
          at: after(second));
    }
    // 8 m sideways error: nearer the returning leg than the one walked.
    final ahead =
        trim.ahead(const LatLng(16.720405, 121.690075), at: after(31));
    expect(ahead, hasLength(4));
  });

  test('a line that starts late on a hairpin still catches up with the user',
      () {
    // The route arrives while the user is already on the returning leg,
    // beside about 45 m of the first leg.
    final trim = RouteTrim(hairpin, start);
    var ahead = hairpin;
    var position = hairpin.first;
    for (var second = 0; second <= 30; second++) {
      position = LatLng(16.720405 - 0.0000126 * second, 121.6901032);
      ahead = trim.ahead(position, at: after(second));
    }
    expect(ahead, hasLength(2));
    expect(distance(ahead.first, position), lessThan(1));
  });

  test('a position that may not advance the line still draws it', () {
    final trim = RouteTrim(route, start);
    trim.ahead(const LatLng(16.7202, 121.69), at: after(10));
    final ahead = trim.ahead(const LatLng(16.721, 121.6905),
        at: after(60), advance: false);
    expect(ahead, hasLength(3));
    expect(distance(ahead.first, const LatLng(16.7202, 121.69)), lessThan(1));
  });
}
