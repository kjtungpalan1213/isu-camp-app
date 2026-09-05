import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/campus_dataset.dart';
import '../models/campus_models.dart';
import '../widgets/navigation_sheets.dart';
import 'user_info_screen.dart';
import 'package:flutter_map/flutter_map.dart';

enum NavigationUiState {
  idle,
  buildingDetails,
  chooseRoute,
  routeDetails,
  navigating,
  arrived,
}

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  NavigationUiState _navigationState = NavigationUiState.idle;
  CampusBuilding _selectedBuilding = isuCampusBuildings.first;
  RouteType _selectedRouteType = RouteType.comfortableShaded;
  TransportMode _selectedTransportMode = TransportMode.walking;
  String _selectedCategoryFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<CampusBuilding> _getFilteredBuildings() {
    return isuCampusBuildings.where((b) {
      final query = _searchController.text.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          b.name.toLowerCase().contains(query) ||
          b.acronym.toLowerCase().contains(query) ||
          b.category.toLowerCase().contains(query) ||
          b.rooms.any((r) => r.title.toLowerCase().contains(query));

      if (!matchesQuery) return false;

      if (_selectedCategoryFilter == 'Colleges') {
        return !b.isParking;
      } else if (_selectedCategoryFilter == 'Parkings') {
        return b.isParking;
      } else if (_selectedCategoryFilter == 'Shaded') {
        return b.hasShadedPath;
      }

      return true;
    }).toList();
  }

  void _selectBuildingAndShowDetails(CampusBuilding building) {
    setState(() {
      _selectedBuilding = building;
      _navigationState = NavigationUiState.buildingDetails;
    });
    _mapController.move(building.coordinate, 17.5);
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedCategoryFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFECC700) : const Color(0xFF174A2F),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFFECC700) : Colors.white24,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.black87 : Colors.white,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final filteredBuildings = _getFilteredBuildings();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F5),
      body: Stack(
        children: [
          // 1. Interactive Full-Screen Campus Map Canvas
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: isuMainGateNode,
                initialZoom: 18.2,
                minZoom: 14.0,
                maxZoom: 19.5,
                onTap: (_, __) {
                  if (_navigationState == NavigationUiState.buildingDetails) {
                    setState(() {
                      _navigationState = NavigationUiState.idle;
                    });
                  }
                },
              ),
              children: [
                // OpenStreetMap Tile Layer
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.isucamp.app',
                ),

                // Active Route Polylines (if route chosen or navigating)
                if (_navigationState == NavigationUiState.chooseRoute ||
                    _navigationState == NavigationUiState.routeDetails ||
                    _navigationState == NavigationUiState.navigating)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _selectedBuilding.routes.isNotEmpty
                            ? _selectedBuilding.routes.first.pathPoints
                            : [],
                        strokeWidth: 5.0,
                        color: const Color(0xFF0F751B),
                        borderColor: Colors.white,
                        borderStrokeWidth: 2.0,
                      ),
                    ],
                  ),

                // Building Markers with Visual Name Badges on the Map
                MarkerLayer(
                  markers: filteredBuildings.map((building) {
                    final isSelected = _selectedBuilding.id == building.id;
                    return Marker(
                      point: building.coordinate,
                      width: 140,
                      height: 75,
                      child: GestureDetector(
                        onTap: () => _selectBuildingAndShowDetails(building),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pin Icon
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.all(isSelected ? 7 : 5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFECC700)
                                    : (building.isParking
                                        ? const Color(0xFF1E88E5)
                                        : const Color(0xFF0F751B)),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: isSelected ? 2.5 : 2.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                building.isParking
                                    ? Icons.local_parking
                                    : Icons.school,
                                color:
                                    isSelected ? Colors.black87 : Colors.white,
                                size: isSelected ? 20 : 16,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Building Label Pill on Map
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0F4D20)
                                    : Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFECC700)
                                      : Colors.grey.shade300,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Text(
                                building.acronym.isNotEmpty
                                    ? building.acronym
                                    : building.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF0F4D20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Floating Map Action Buttons (Recenter & Zoom)
          Positioned(
            right: 16,
            top: topPadding + 170,
            child: Column(
              children: [
                // Recenter to ISU Echague Main Gate
                FloatingActionButton.small(
                  heroTag: 'btn_recenter',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F751B),
                  elevation: 4,
                  onPressed: () {
                    _mapController.move(isuMainGateNode, 16.5);
                  },
                  child: const Icon(Icons.my_location, size: 20),
                ),
                const SizedBox(height: 10),
                // Zoom In
                FloatingActionButton.small(
                  heroTag: 'btn_zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F751B),
                  elevation: 4,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      (currentZoom + 1).clamp(14.0, 19.0),
                    );
                  },
                  child: const Icon(Icons.add, size: 20),
                ),
                const SizedBox(height: 8),
                // Zoom Out
                FloatingActionButton.small(
                  heroTag: 'btn_zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF0F751B),
                  elevation: 4,
                  onPressed: () {
                    final currentZoom = _mapController.camera.zoom;
                    _mapController.move(
                      _mapController.camera.center,
                      (currentZoom - 1).clamp(14.0, 19.0),
                    );
                  },
                  child: const Icon(Icons.remove, size: 20),
                ),
              ],
            ),
          ),

          // 2. Dark Green Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, topPadding + 10, 20, 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0B351E),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 28,
                            height: 28,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo_kumpas_app.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.navigation,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'KUMPAS',
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserInfoScreen(
                                    onNavigateToBuilding: (destination) {
                                      _selectBuildingAndShowDetails(
                                          destination);
                                      setState(() {
                                        _navigationState =
                                            NavigationUiState.chooseRoute;
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF174A2F),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white24,
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            width: 36,
                            height: 36,
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo_isu_png.png',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(
                                  Icons.school,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Search Field Bar
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF174A2F),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Colors.white70,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) => setState(() {}),
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search building, parking, or room...',
                              hintStyle: GoogleFonts.montserrat(
                                color: Colors.white60,
                                fontSize: 12.5,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() {});
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white70,
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Category Filter Chips Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildFilterChip('All', Icons.grid_view),
                        _buildFilterChip('Colleges', Icons.school),
                        _buildFilterChip('Parkings', Icons.local_parking),
                        _buildFilterChip('Shaded', Icons.park_outlined),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Floating Search Suggestions Dropdown (appears when user is typing)
          if (_searchController.text.trim().isNotEmpty)
            Positioned(
              top: topPadding + 155,
              left: 20,
              right: 20,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(16),
                color: Colors.white,
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 220),
                  child: filteredBuildings.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No building found matching "${_searchController.text}"',
                            style: GoogleFonts.montserrat(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shrinkWrap: true,
                          itemCount: filteredBuildings.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                          itemBuilder: (context, idx) {
                            final bldg = filteredBuildings[idx];
                            return ListTile(
                              dense: true,
                              leading: Icon(
                                bldg.isParking
                                    ? Icons.local_parking
                                    : Icons.school,
                                color: const Color(0xFF0F751B),
                                size: 20,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      bldg.name,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                  if (bldg.rooms.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F751B)
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${bldg.rooms.length} Rooms',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF0F751B),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              subtitle: Builder(
                                builder: (context) {
                                  final query = _searchController.text
                                      .toLowerCase()
                                      .trim();
                                  final matchedRooms = bldg.rooms
                                      .where((r) => r.title
                                          .toLowerCase()
                                          .contains(query))
                                      .toList();

                                  if (query.isNotEmpty &&
                                      matchedRooms.isNotEmpty) {
                                    final roomNames = matchedRooms
                                        .map((r) => r.title)
                                        .take(2)
                                        .join(', ');
                                    return Text(
                                      'Inside: $roomNames (${matchedRooms.first.floor})',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11,
                                        color: const Color(0xFF0F751B),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  }

                                  return Text(
                                    bldg.acronym.isNotEmpty
                                        ? '${bldg.acronym} • ${bldg.category}'
                                        : bldg.category,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  );
                                },
                              ),
                              onTap: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                                _selectBuildingAndShowDetails(bldg);
                              },
                            );
                          },
                        ),
                ),
              ),
            ),

          // 3. Bottom Sheet Overlay State Machine
          if (_navigationState == NavigationUiState.buildingDetails)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BuildingDetailsSheet(
                building: _selectedBuilding,
                onClose: () {
                  setState(() {
                    _navigationState = NavigationUiState.idle;
                  });
                },
                onDirectionsTap: () {
                  setState(() {
                    _navigationState = NavigationUiState.chooseRoute;
                  });
                },
              ),
            ),

          if (_navigationState == NavigationUiState.chooseRoute)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: ChooseRouteSheet(
                destination: _selectedBuilding,
                onBack: () {
                  setState(() {
                    _navigationState = NavigationUiState.buildingDetails;
                  });
                },
                onViewRoute: (type, mode) {
                  setState(() {
                    _selectedRouteType = type;
                    _selectedTransportMode = mode;
                    _navigationState = NavigationUiState.routeDetails;
                  });
                },
              ),
            ),

          if (_navigationState == NavigationUiState.routeDetails)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: RouteDetailsSheet(
                destination: _selectedBuilding,
                selectedRouteType: _selectedRouteType,
                selectedTransportMode: _selectedTransportMode,
                onBack: () {
                  setState(() {
                    _navigationState = NavigationUiState.chooseRoute;
                  });
                },
                onStartNavigation: () {
                  setState(() {
                    _navigationState = NavigationUiState.navigating;
                  });
                },
              ),
            ),

          // 4. Full-Screen Turn-by-Turn Navigation HUD
          if (_navigationState == NavigationUiState.navigating)
            Positioned.fill(
              child: ActiveNavigationHud(
                destination: _selectedBuilding,
                selectedRouteType: _selectedRouteType,
                selectedTransportMode: _selectedTransportMode,
                onEndRoute: () {
                  setState(() {
                    _navigationState = NavigationUiState.idle;
                  });
                },
                onSimulateArrival: () {
                  setState(() {
                    _navigationState = NavigationUiState.arrived;
                  });
                },
              ),
            ),

          // 5. "You've Arrived!" HUD (Mockup Screen)
          if (_navigationState == NavigationUiState.arrived)
            Positioned.fill(
              child: ArrivalHud(
                destination: _selectedBuilding,
                onFinish: () {
                  setState(() {
                    _navigationState = NavigationUiState.idle;
                  });
                },
              ),
            ),
        ],
      ),
    );
  }
}
