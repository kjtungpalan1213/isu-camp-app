import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'navigation_progress.dart';

/// Farther than this from the route, a position no longer counts as progress
/// along it. Matches the off-route distance used for guidance.
const double routeTrimMaxOffsetMeters = 30;

/// Progress may land this far from the progress so far however little time
/// has passed: about the GPS error navigation still accepts.
const double routeTrimAllowanceMeters = 25;

/// Faster than anyone travels on campus, cars included. Progress reaches only
/// as far ahead as this speed allows since the user was last placed on the
/// route, which still lets the line catch up after a GPS gap.
const double routeTrimMaxSpeed = 20;

/// The part of a route still ahead of the user during navigation.
///
/// Progress only moves forward, so GPS wobble never brings walked route back.
/// It is only looked for in the stretch the user could plausibly have
/// reached, so a nearby later leg (a hairpin) can't swallow the route between.
/// A new route (after a reroute) needs a new [RouteTrim].
class RouteTrim {
  /// The user is at the start of the route at [startedAt].
  RouteTrim(this.points, DateTime startedAt) : _placedAt = startedAt;

  final List<LatLng> points;
  double _walkedMeters = 0;
  DateTime _placedAt;

  /// The route from [position], snapped onto it, to the destination. Without
  /// [advance] (for an untrusted fix), the line is drawn but doesn't move.
  List<LatLng> ahead(LatLng position,
      {required DateTime at, bool advance = true}) {
    if (points.isEmpty) return const [];
    if (advance) _advance(position, at);
    if (_walkedMeters <= 0) return points;
    const distance = Distance();
    var travelled = 0.0;
    for (var i = 1; i < points.length; i++) {
      final a = points[i - 1];
      final b = points[i];
      final length = distance(a, b);
      if (travelled + length > _walkedMeters) {
        final t = length == 0 ? 0.0 : (_walkedMeters - travelled) / length;
        return [
          LatLng(a.latitude + (b.latitude - a.latitude) * t,
              a.longitude + (b.longitude - a.longitude) * t),
          ...points.sublist(i),
        ];
      }
      travelled += length;
    }
    return [points.last];
  }

  void _advance(LatLng position, DateTime at) {
    final seconds = math.max(0, at.difference(_placedAt).inMilliseconds) / 1000;
    final projection = RouteProjection.locate(points, position,
        fromMeters: _walkedMeters - routeTrimAllowanceMeters,
        toMeters: _walkedMeters +
            routeTrimAllowanceMeters +
            routeTrimMaxSpeed * seconds);
    if (projection.awayMeters > routeTrimMaxOffsetMeters) return;
    // On the route near the progress so far, even if not ahead of it, so the
    // plausible stretch ahead is measured from now.
    _placedAt = at;
    _walkedMeters = math.max(_walkedMeters, projection.alongMeters);
  }
}
