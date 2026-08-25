import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/campus_models.dart';

// Helper to compute dynamic distance & travel time based on building and mode
class RouteMetricsHelper {
  static int getBaseDistance(CampusBuilding building) {
    switch (building.id) {
      case 'bldg_ca_sbo':
        return 400;
      case 'bldg_ccsict':
        return 650;
      case 'bldg_coe':
        return 750;
      case 'bldg_admin':
        return 280;
      case 'bldg_library':
        return 450;
      case 'bldg_gym':
        return 1100;
      case 'parking_main_gate':
        return 150;
      case 'parking_agriculture':
        return 420;
      case 'parking_engineering_ccsict':
        return 780;
      default:
        return 500;
    }
  }

  static String getDistanceString(
      CampusBuilding building, RouteType routeType, TransportMode mode) {
    int base = getBaseDistance(building);
    if (routeType == RouteType.comfortableShaded) {
      base = (base * 1.6).round();
    }
    if (mode == TransportMode.car) {
      base = (base * 1.25).round();
    } else if (mode == TransportMode.motorcycle) {
      base = (base * 1.15).round();
    }
    return '${base}m';
  }

  static String getTimeString(
      CampusBuilding building, RouteType routeType, TransportMode mode) {
    int base = getBaseDistance(building);
    if (routeType == RouteType.comfortableShaded) {
      base = (base * 1.6).round();
    }

    int minutes;
    switch (mode) {
      case TransportMode.walking:
        minutes = (base / 80).ceil();
        return '$minutes mins';
      case TransportMode.bicycle:
        minutes = (base / 220).ceil();
        return '${minutes < 1 ? 1 : minutes} mins';
      case TransportMode.motorcycle:
        minutes = (base / 450).ceil();
        return '${minutes < 1 ? 1 : minutes} mins';
      case TransportMode.car:
        minutes = (base / 350).ceil();
        return '${minutes < 1 ? 1 : minutes} mins';
    }
  }

  static String getArrivalTime(
      CampusBuilding building, RouteType routeType, TransportMode mode) {
    int base = getBaseDistance(building);
    if (routeType == RouteType.comfortableShaded) {
      base = (base * 1.6).round();
    }

    int minutes;
    switch (mode) {
      case TransportMode.walking:
        minutes = (base / 80).ceil();
        break;
      case TransportMode.bicycle:
        minutes = (base / 220).ceil();
        break;
      case TransportMode.motorcycle:
        minutes = (base / 450).ceil();
        break;
      case TransportMode.car:
        minutes = (base / 350).ceil();
        break;
    }
    final now = DateTime.now().add(Duration(minutes: minutes));
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final minuteStr = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'pm' : 'am';
    return '$hour:$minuteStr $period';
  }
}

// =========================================================================
// 1. BUILDING DETAILS MODAL SHEET (Design Mockup Image 5)
// =========================================================================
class BuildingDetailsSheet extends StatelessWidget {
  final CampusBuilding building;
  final VoidCallback onDirectionsTap;

  const BuildingDetailsSheet({
    super.key,
    required this.building,
    required this.onDirectionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // "RESULT" Tag
          Text(
            'RESULT',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          // Building Image with rounded corners
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 155,
              width: double.infinity,
              color: Colors.grey.shade200,
              child: Image.asset(
                building.imageUrl ?? 'assets/images/Appdev_background1.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Center(
                  child: Icon(
                    building.isParking ? Icons.local_parking : Icons.school,
                    size: 54,
                    color: const Color(0xFF0F751B),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Title & Subtitle + Green "DIRECTIONS" Button Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      building.name,
                      style: GoogleFonts.montserrat(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      building.category,
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onDirectionsTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F5A28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'DIRECTIONS',
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 2. CHOOSE ROUTE MODAL SHEET (Design Mockup Images 1 & 3)
// =========================================================================
class ChooseRouteSheet extends StatefulWidget {
  final CampusBuilding destination;
  final String originName;
  final VoidCallback onBack;
  final Function(RouteType selectedType, TransportMode selectedMode) onViewRoute;

  const ChooseRouteSheet({
    super.key,
    required this.destination,
    this.originName = 'Your Location',
    required this.onBack,
    required this.onViewRoute,
  });

  @override
  State<ChooseRouteSheet> createState() => _ChooseRouteSheetState();
}

class _ChooseRouteSheetState extends State<ChooseRouteSheet> {
  TransportMode _selectedMode = TransportMode.walking;
  RouteType _selectedRoute = RouteType.comfortableShaded;

  @override
  Widget build(BuildContext context) {
    final shortestDist = RouteMetricsHelper.getDistanceString(
      widget.destination,
      RouteType.shortest,
      _selectedMode,
    );
    final shortestTime = RouteMetricsHelper.getTimeString(
      widget.destination,
      RouteType.shortest,
      _selectedMode,
    );

    final comfortableDist = RouteMetricsHelper.getDistanceString(
      widget.destination,
      RouteType.comfortableShaded,
      _selectedMode,
    );
    final comfortableTime = RouteMetricsHelper.getTimeString(
      widget.destination,
      RouteType.comfortableShaded,
      _selectedMode,
    );

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFE5E7EB),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Dark Green Header Box: Route Modes & Origin/Destination Box
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            decoration: const BoxDecoration(
              color: Color(0xFF0B351E),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transport Mode Selector Icons
                Row(
                  children: [
                    Text(
                      'Route Modes',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 14),
                    _buildModeIcon(TransportMode.car, Icons.directions_car),
                    const SizedBox(width: 12),
                    _buildModeIcon(TransportMode.motorcycle, Icons.two_wheeler),
                    const SizedBox(width: 12),
                    _buildModeIcon(TransportMode.bicycle, Icons.pedal_bike),
                    const SizedBox(width: 12),
                    _buildModeIcon(TransportMode.walking, Icons.directions_walk),
                  ],
                ),

                const SizedBox(height: 14),

                // Origin & Destination Container
                Row(
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF22C55E),
                              width: 3.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 2,
                          height: 28,
                          color: Colors.white38,
                        ),
                        const Icon(
                          Icons.location_on,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  widget.originName,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 13,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 36,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Text(
                              widget.destination.name,
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Content: CHOOSE ROUTE Options
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: widget.onBack,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            size: 18,
                            color: Color(0xFF0F4D20),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Back',
                            style: GoogleFonts.montserrat(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0F4D20),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Text(
                  'CHOOSE ROUTE',
                  style: GoogleFonts.montserrat(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: const Color(0xFF0B351E),
                  ),
                ),

                const SizedBox(height: 16),

                // Option 1: Shortest Route Card
                _buildRouteCard(
                  type: RouteType.shortest,
                  title: 'Shortest Route',
                  subtitle: 'Most Direct Path',
                  distance: shortestDist,
                  walkTime: shortestTime,
                  icon: Icons.bolt,
                  iconColor: const Color(0xFFECC700),
                ),

                const SizedBox(height: 12),

                // Option 2: Comfortable Path Card (Shaded)
                _buildRouteCard(
                  type: RouteType.comfortableShaded,
                  title: 'Comfortable Path',
                  subtitle: 'Shaded, Wider',
                  distance: comfortableDist,
                  walkTime: comfortableTime,
                  icon: Icons.cloud_outlined,
                  iconColor: const Color(0xFF0F5A28),
                ),

                const SizedBox(height: 20),

                // "View Route" Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () =>
                        widget.onViewRoute(_selectedRoute, _selectedMode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F5A28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'View Route',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeIcon(TransportMode mode, IconData icon) {
    final isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _selectedMode = mode),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.white60,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildRouteCard({
    required RouteType type,
    required String title,
    required String subtitle,
    required String distance,
    required String walkTime,
    required IconData icon,
    required Color iconColor,
  }) {
    final isSelected = _selectedRoute == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedRoute = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF1B62D4) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 11.5,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF1B62D4)
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF1B62D4),
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Distance: ',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  distance,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 18),
                Text(
                  'Est. Time: ',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  walkTime,
                  style: GoogleFonts.montserrat(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// =========================================================================
// 3. ROUTE DETAILS MODAL SHEET (Design Mockup Image 4)
// =========================================================================
class RouteDetailsSheet extends StatelessWidget {
  final CampusBuilding destination;
  final RouteType selectedRouteType;
  final TransportMode selectedTransportMode;
  final VoidCallback onBack;
  final VoidCallback onStartNavigation;

  const RouteDetailsSheet({
    super.key,
    required this.destination,
    required this.selectedRouteType,
    this.selectedTransportMode = TransportMode.walking,
    required this.onBack,
    required this.onStartNavigation,
  });

  @override
  Widget build(BuildContext context) {
    final isShortest = selectedRouteType == RouteType.shortest;
    final title = isShortest ? 'Shortest Route' : 'Comfortable Path';
    final subtitle = isShortest ? 'Most Direct Path' : 'Shaded, Wider';

    final distance = RouteMetricsHelper.getDistanceString(
      destination,
      selectedRouteType,
      selectedTransportMode,
    );
    final estTime = RouteMetricsHelper.getTimeString(
      destination,
      selectedRouteType,
      selectedTransportMode,
    );
    final arrivalTime = RouteMetricsHelper.getArrivalTime(
      destination,
      selectedRouteType,
      selectedTransportMode,
    );

    final icon = isShortest ? Icons.bolt : Icons.cloud_outlined;
    final iconColor =
        isShortest ? const Color(0xFFECC700) : const Color(0xFF0F5A28);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Row(
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: Color(0xFF0F4D20),
                ),
                const SizedBox(width: 4),
                Text(
                  'Back',
                  style: GoogleFonts.montserrat(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F4D20),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Text(
            'ROUTE DETAILS',
            style: GoogleFonts.montserrat(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: const Color(0xFF0B351E),
            ),
          ),

          const SizedBox(height: 16),

          // Origin to Destination Timeline
          Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF22C55E),
                        width: 4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'ISU MAIN GATE',
                    style: GoogleFonts.montserrat(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  height: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.grey.shade400,
                ),
              ),
              Column(
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destination.acronym.toUpperCase(),
                    style: GoogleFonts.montserrat(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Selected Route Info Card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.montserrat(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Distance: $distance',
                        style: GoogleFonts.montserrat(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Est: $estTime',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Time of\nArrival: $arrivalTime',
                      textAlign: TextAlign.right,
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // "Start Navigation" Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onStartNavigation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F5A28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: Text(
                'Start Navigation',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// 4. ACTIVE TURN-BY-TURN NAVIGATION HUD (Design Mockup Image 2)
// =========================================================================
class ActiveNavigationHud extends StatelessWidget {
  final CampusBuilding destination;
  final RouteType selectedRouteType;
  final TransportMode selectedTransportMode;
  final VoidCallback onEndRoute;
  final VoidCallback onSimulateArrival;

  const ActiveNavigationHud({
    super.key,
    required this.destination,
    required this.selectedRouteType,
    required this.selectedTransportMode,
    required this.onEndRoute,
    required this.onSimulateArrival,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final distance = RouteMetricsHelper.getDistanceString(
      destination,
      selectedRouteType,
      selectedTransportMode,
    );
    final time = RouteMetricsHelper.getTimeString(
      destination,
      selectedRouteType,
      selectedTransportMode,
    );

    return Stack(
      children: [
        // 1. Top Turn-by-Turn Guidance Banner
        Positioned(
          top: topPadding + 10,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF374151).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_upward,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Head Northeast',
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        distance,
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Floating Compass / Arrival Simulator Button
        Positioned(
          right: 18,
          bottom: 230,
          child: GestureDetector(
            onTap: onSimulateArrival,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Transform.rotate(
                angle: 0.5,
                child: const Icon(
                  Icons.navigation,
                  color: Color(0xFF0F751B),
                  size: 26,
                ),
              ),
            ),
          ),
        ),

        // 3. Bottom Dark Status Card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 34),
            decoration: const BoxDecoration(
              color: Color(0xFF262626),
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 16,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Destination',
                            style: GoogleFonts.montserrat(
                              fontSize: 11.5,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            destination.name,
                            style: GoogleFonts.montserrat(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          time.split(' ').first,
                          style: GoogleFonts.montserrat(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22C55E),
                          ),
                        ),
                        Text(
                          'min',
                          style: GoogleFonts.montserrat(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22C55E),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Green Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 0.65,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade700,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF22C55E),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Red "End Route" Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: onEndRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'End Route',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// 5. ARRIVAL HUD: "You've Arrived!" (New Mockup Screen)
// =========================================================================
class ArrivalHud extends StatelessWidget {
  final CampusBuilding destination;
  final VoidCallback onFinish;

  const ArrivalHud({
    super.key,
    required this.destination,
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // 1. Top "You've Arrived!" Banner Card
        Positioned(
          top: topPadding + 10,
          left: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF374151).withValues(alpha: 0.94),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "You've Arrived!",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        destination.name,
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. Bottom "Finish" Green Button
        Positioned(
          bottom: 30,
          left: 40,
          right: 40,
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: onFinish,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F5A28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
              ),
              child: Text(
                'Finish',
                style: GoogleFonts.montserrat(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
