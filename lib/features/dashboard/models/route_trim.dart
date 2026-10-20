import 'package:latlong2/latlong.dart';
import 'navigation_progress.dart';

/// Farther than this from the route, a position no longer counts as progress
/// along it. Matches the off-route distance used for guidance.
const double routeTrimMaxOffsetMeters = 30;

/// The part of a route still ahead of the user during navigation.
///
/// Progress only moves forward, so GPS wobble never brings walked route back.
/// A new route (after a reroute) needs a new [RouteTrim].
class RouteTrim {
  RouteTrim(this.points);

  final List<LatLng> points;
  double _walkedMeters = 0;

  /// The route from [position], snapped onto it, to the destination.
  List<LatLng> ahead(LatLng position) {
    if (points.isEmpty) return const [];
    final projection = RouteProjection.locate(points, position);
    if (projection.awayMeters <= routeTrimMaxOffsetMeters &&
        projection.alongMeters > _walkedMeters) {
      _walkedMeters = projection.alongMeters;
    }
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
}
