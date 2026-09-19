# Walking routing changes

This change connects the existing starting-point and destination flow to Supabase. No database records or schema were changed.

## Files

- `server/app/utils/routing.py`: directed walking graph and two Dijkstra computations.
- `server/app/routes/campus.py`: new `POST /campus/routes`, validated input, paginated reads and error responses. Existing buildings endpoint remains.
- `lib/features/dashboard/services/campus_service.dart`: calls the new endpoint with origin type/coordinates, optional origin building ID and destination building ID.
- `lib/features/dashboard/models/campus_models.dart`: `WalkingRoute` response model with actual distance, estimated minutes, points and starting-node name.
- `lib/features/dashboard/widgets/navigation_sheets.dart`: asynchronous route cards with loading, retry and no-route states; preview and navigation HUD use backend metrics. Non-walking modes cannot start routing.
- `lib/features/dashboard/screens/map_view_screen.dart`: selected route is passed to preview/HUD; map draws returned pathway points, replacing the mock curve. The start marker uses the resolved network node.
- `server/tests/test_routing.py`: routing algorithm and data-rule tests.
- `test/features/dashboard/widgets/walking_routes_test.dart`: route selection, metrics, unavailable mode and no-route tests.
- `test/features/dashboard/map_view_screen_test.dart`: updates an outdated code-label expectation to match the user's existing building-name label.

## Data and rules

Tables: `route_node`, `pathway`, `pathway_allowed_mode`, `path_point`.

Only active nodes/pathways/points and pathways explicitly allowing `Walking` are used. One-way adds a source-to-destination edge; two-way also adds a reverse edge with reversed geometry. Unknown directions are excluded. Nodes without `building_id` remain valid junctions.

Shortest weight: computed pathway length from route nodes and ordered path points.

Shaded weight: computed pathway length multiplied by `(1 + penalty)` using `pathway.shade`:

| Shade | Penalty |
|---|---:|
| Fully Shaded | 0 |
| Mostly Shaded | 0.25 |
| Partial Shade | 0.50 |
| Unshaded | 1 |
| Unknown, null or unrecognized | 1 |

Actual distance is returned separately from weighted cost. Distance is calculated from the ordered geometry, and estimated time uses an 80 meters/minute walking speed. The database `distance_m` and `estimated_minutes` values are not read for routing.

Building starts/destinations use active entrance nodes associated through `building_id`. Multiple entrances are considered in the graph search. Missing or disconnected entrances produce an explicit no-route response.

Main Gate resolves a uniquely named active node (`Gate`, `Main Gate`, or `ISU Main Gate`). Current Location and Campus Center use the nearest active node with outgoing walking edges, within 200 meters. The route starts at that node; the distance does not include an unverified off-network connector. The UI displays the resolved starting-node name.

Points are sorted by `sequence_no` and oriented source-to-destination. When a pathway has no points, its endpoint coordinates form its geometry. Both alternatives may be identical.

## Verified against live data

- Near Junction Shortcut to CCSICT: 58 m, pathways 8 -> 9 -> 10. Both alternatives currently use the same route.
- Main Gate to CCSICT: no connected walking route under the current allowed modes. Vehicle-only edges are not used as a fallback.

## Scope limits

This implements route calculation, selection and display. Automatic rerouting, live remaining-distance calculation and automatic arrival detection are not added. The existing manual arrival action remains. The active HUD shows total route distance/time and asks the user to follow the highlighted path; it does not invent turn instructions.

Restart FastAPI and fully restart Flutter after applying these changes. No migrations are required.
