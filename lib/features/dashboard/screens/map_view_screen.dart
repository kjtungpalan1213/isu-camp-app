import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/campus_dataset.dart';
import '../models/campus_models.dart';
import '../widgets/navigation_sheets.dart';
import 'user_info_screen.dart';

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

  void _checkAdminConnection() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cloud_done, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Connected to KUMPAS Admin Service. Ready for Map API synchronization.',
                style: GoogleFonts.montserrat(fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F751B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  List<CampusBuilding> _getFilteredBuildings() {
    return isuCampusBuildings.where((b) {
      final query = _searchController.text.toLowerCase().trim();
      final matchesQuery = query.isEmpty ||
          b.name.toLowerCase().contains(query) ||
          b.acronym.toLowerCase().contains(query) ||
          b.category.toLowerCase().contains(query);

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
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final isSelected = _selectedCategoryFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryFilter = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFECC700)
              : const Color(0xFF174A2F),
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
          // 1. Campus Canvas & Interactive Building Directory
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, topPadding + 160, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Admin Sync Status Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF0F751B).withValues(alpha: 0.12),
                          ),
                          child: const Icon(
                            Icons.cloud_sync,
                            color: Color(0xFF0F751B),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ISU Echague Navigation Engine',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0F4D20),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Select any campus building or parking below to preview route directions & shaded navigation.',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Directory Heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Campus Destinations (${filteredBuildings.length})',
                        style: GoogleFonts.montserrat(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F4D20),
                        ),
                      ),
                      GestureDetector(
                        onTap: _checkAdminConnection,
                        child: Text(
                          'Sync API',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E60D0),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Buildings & Parkings List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredBuildings.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final bldg = filteredBuildings[index];
                      final baseDist = RouteMetricsHelper.getBaseDistance(bldg);

                      return GestureDetector(
                        onTap: () => _selectBuildingAndShowDetails(bldg),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedBuilding.id == bldg.id
                                  ? const Color(0xFF0F751B)
                                  : Colors.transparent,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: bldg.isParking
                                      ? const Color(0xFF1E60D0).withValues(alpha: 0.1)
                                      : const Color(0xFF0F751B).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  bldg.isParking
                                      ? Icons.local_parking
                                      : Icons.account_balance,
                                  color: bldg.isParking
                                      ? const Color(0xFF1E60D0)
                                      : const Color(0xFF0F751B),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      bldg.name,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Text(
                                          '${baseDist}m • ${bldg.category}',
                                          style: GoogleFonts.montserrat(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        if (bldg.hasShadedPath) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF22C55E)
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              '🌳 Shaded',
                                              style: GoogleFonts.montserrat(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xFF0F751B),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: Colors.grey,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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
                                      _selectBuildingAndShowDetails(destination);
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

          // 3. Bottom Sheet Overlay State Machine
          if (_navigationState == NavigationUiState.buildingDetails)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: BuildingDetailsSheet(
                building: _selectedBuilding,
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