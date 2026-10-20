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
  late TravelOdometer odometer;
  setUp(() => odometer = TravelOdometer()..record(start, 0));
  // A fix [seconds] in, moving at [speed] m/s, fed to the trim as the map does.
  List<LatLng> fix(RouteTrim trim, LatLng position, int seconds,
      {double speed = 0, bool advance = true}) {
    odometer.record(after(seconds), speed);
    return trim.ahead(position,
        travelled: odometer.metersAt(after(seconds)), advance: advance);
  }

  test('the line starts where the user is on the route', () {
    final ahead =
        fix(RouteTrim(route, 0), const LatLng(16.7205, 121.69), 40, speed: 1.4);
    expect(distance(ahead.first, const LatLng(16.7205, 121.69)), lessThan(1));
    expect(ahead.sublist(1), route.sublist(1));
  });

  test('a position off to the side snaps onto the route', () {
    final ahead = fix(RouteTrim(route, 0), const LatLng(16.7205, 121.69005), 40,
        speed: 1.4);
    expect(distance(ahead.first, const LatLng(16.7205, 121.69)), lessThan(1));
  });

  test('past a corner, the walked leg is gone', () {
    final ahead = fix(RouteTrim(route, 0), const LatLng(16.721, 121.6905), 120,
        speed: 1.4);
    expect(ahead, hasLength(2));
    expect(ahead.last, route.last);
    expect(distance(ahead.first, const LatLng(16.721, 121.6905)), lessThan(1));
  });

  test('the full route shows before the user reaches it', () {
    expect(fix(RouteTrim(route, 0), const LatLng(16.7198, 121.69), 10), route);
  });

  test('walked route never grows back', () {
    final trim = RouteTrim(route, 0);
    fix(trim, const LatLng(16.7208, 121.69), 90, speed: 1.4);
    final ahead = fix(trim, const LatLng(16.7203, 121.69), 91);
    expect(distance(ahead.first, const LatLng(16.7208, 121.69)), lessThan(1));
  });

  test('positions far from the route do not move the trim', () {
    final trim = RouteTrim(route, 0);
    fix(trim, const LatLng(16.7202, 121.69), 20, speed: 1.4);
    // Well east of the route: a wrong GPS fix, not progress.
    final ahead = fix(trim, const LatLng(16.7205, 121.693), 21, speed: 1.4);
    expect(distance(ahead.first, const LatLng(16.7202, 121.69)), lessThan(1));
  });

  test('at the destination, only the end point is left', () {
    final ahead = fix(RouteTrim(route, 0), route.last, 160, speed: 1.4);
    expect(ahead, hasLength(1));
    expect(distance(ahead.single, route.last), lessThan(1));
  });

  test('an empty route stays empty', () {
    expect(fix(RouteTrim(const [], 0), route.first, 1), isEmpty);
  });

  test('walking along, the line keeps starting at the user', () {
    final trim = RouteTrim(route, 0);
    // About 1.4 m/s, one fix a second.
    for (var second = 1; second <= 60; second++) {
      final position = LatLng(16.72 + 0.0000126 * second, 121.69);
      final ahead = fix(trim, position, second, speed: 1.4);
      expect(distance(ahead.first, position), lessThan(1));
    }
  });

  test('a vehicle at speed is not left behind', () {
    final trim = RouteTrim(route, 0);
    // About 18 m/s up the first leg.
    for (var second = 1; second <= 5; second++) {
      final position = LatLng(16.72 + 0.000162 * second, 121.69);
      final ahead = fix(trim, position, second, speed: 18);
      expect(distance(ahead.first, position), lessThan(1));
    }
  });

  test('after a long GPS gap, the line catches up with the user', () {
    final trim = RouteTrim(route, 0);
    fix(trim, const LatLng(16.7201, 121.69), 8, speed: 1.4);
    // No fixes for a minute; the next one is moving, about 150 m on.
    final ahead = fix(trim, const LatLng(16.721, 121.6905), 68, speed: 2.5);
    expect(ahead, hasLength(2));
    expect(distance(ahead.first, const LatLng(16.721, 121.6905)), lessThan(1));
  });

  test('a position too far ahead is caught up with as the user moves', () {
    final trim = RouteTrim(route, 0);
    fix(trim, const LatLng(16.7201, 121.69), 8, speed: 1.4);
    // Past the corner a second later is implausible, but moving on from
    // there is not: the line follows once the user has moved a little.
    var ahead = fix(trim, const LatLng(16.721, 121.6905), 9, speed: 1.4);
    expect(ahead, hasLength(3));
    for (var second = 10; second <= 30; second++) {
      ahead = fix(trim, const LatLng(16.721, 121.6905), second, speed: 1.4);
    }
    expect(ahead, hasLength(2));
    expect(distance(ahead.first, const LatLng(16.721, 121.6905)), lessThan(1));
  });

  test('a later leg close by does not swallow the route still ahead', () {
    final trim = RouteTrim(hairpin, 0);
    // About 44 m up the first leg.
    fix(trim, const LatLng(16.720396, 121.69), 32, speed: 1.4);
    // 8 m sideways error: nearer the returning leg than the one walked.
    var ahead = fix(trim, const LatLng(16.720405, 121.690075), 33, speed: 1.4);
    expect(ahead, hasLength(4));
    for (var second = 34; second <= 37; second++) {
      final position = LatLng(16.720405 + 0.0000126 * (second - 33), 121.69);
      ahead = fix(trim, position, second, speed: 1.4);
      expect(ahead, hasLength(4));
      expect(distance(ahead.first, position), lessThan(1));
    }
  });

  test('wobble while standing still does not let a later leg swallow the route',
      () {
    final trim = RouteTrim(hairpin, 0);
    fix(trim, const LatLng(16.720396, 121.69), 32, speed: 1.4);
    // Standing about 44 m up the first leg, fixes a few meters either way.
    for (var second = 33; second <= 62; second++) {
      fix(
          trim,
          LatLng(16.720396 + (second.isEven ? 0.00003 : -0.00003), 121.69),
          second);
    }
    // 8 m sideways error: nearer the returning leg than the one walked.
    expect(fix(trim, const LatLng(16.720405, 121.690075), 63), hasLength(4));
  });

  test('a corrected fix while standing still does not open the way ahead', () {
    final trim = RouteTrim(hairpin, 0);
    // Standing about 44 m up the first leg.
    fix(trim, const LatLng(16.720396, 121.69), 32, speed: 1.4);
    // One fix 13 m ahead, then corrected fixes back where the user stands.
    fix(trim, const LatLng(16.720513, 121.69), 33);
    for (var second = 34; second <= 42; second++) {
      fix(trim, const LatLng(16.720396, 121.69), second);
    }
    // 8 m sideways error: nearer the returning leg than the one walked.
    final ahead = fix(trim, const LatLng(16.720396, 121.690075), 43);
    expect(ahead, hasLength(4));
  });

  test('a line that starts late on a hairpin still catches up with the user',
      () {
    // The route arrives while the user is already on the returning leg,
    // beside about 45 m of the first leg.
    final trim = RouteTrim(hairpin, odometer.metersAt(start));
    var ahead = hairpin;
    var position = hairpin.first;
    for (var second = 0; second <= 30; second++) {
      position = LatLng(16.720405 - 0.0000126 * second, 121.6901032);
      ahead = fix(trim, position, second, speed: 1.4);
    }
    expect(ahead, hasLength(2));
    expect(distance(ahead.first, position), lessThan(1));
  });

  test('a position that may not advance the line still draws it', () {
    final trim = RouteTrim(route, 0);
    fix(trim, const LatLng(16.7202, 121.69), 20, speed: 1.4);
    final ahead = fix(trim, const LatLng(16.721, 121.6905), 80,
        speed: 1.4, advance: false);
    expect(ahead, hasLength(3));
    expect(distance(ahead.first, const LatLng(16.7202, 121.69)), lessThan(1));
  });

  group('travel', () {
    test('standing still, or a speed GPS cannot give, is no travel', () {
      for (var second = 1; second <= 60; second++) {
        odometer.record(after(second), second.isEven ? 0 : double.nan);
      }
      expect(odometer.metersAt(after(60)), 0);
    });

    test('moving adds up, carried past the last fix only while predicted', () {
      for (var second = 1; second <= 10; second++) {
        odometer.record(after(second), 2);
      }
      expect(odometer.metersAt(after(10)), closeTo(20, 0.01));
      expect(odometer.metersAt(start.add(const Duration(milliseconds: 10500))),
          closeTo(21, 0.01));
      // Without fixes, it stops growing.
      expect(odometer.metersAt(after(60)), closeTo(23, 0.01));
    });

    test('moving off after a gap in fixes counts the gap', () {
      odometer.record(after(60), 2.5);
      expect(odometer.metersAt(after(60)), closeTo(150, 0.01));
    });
  });
}
