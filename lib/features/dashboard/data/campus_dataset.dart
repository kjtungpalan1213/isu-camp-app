import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/campus_models.dart';

// ISU Echague Main Origin Point
const LatLng isuMainGateNode = LatLng(16.71180, 121.68880);

final List<CampusBuilding> isuCampusBuildings = [
  // -------------------------------------------------------------
  // 1. COLLEGE OF AGRICULTURE - SBO OFFICE (Featured in Designs)
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_ca_sbo',
    name: 'College of Agriculture- SBO',
    acronym: 'CA SBO',
    category: 'College of Agriculture- ISU Echague',
    description:
        'Main Student Body Organization office and academic department for the College of Agriculture.',
    coordinate: const LatLng(16.71750, 121.68920),
    imageUrl: 'assets/images/Appdev_background1.png',
    hasShadedPath: true,
    routes: [
      const CampusRoute(
        type: RouteType.shortest,
        title: 'Shortest Route',
        subtitle: 'Most Direct Path',
        distance: '400m',
        estimatedTime: '5 mins',
        arrivalTime: '9:46 am',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.71350, 121.68890),
          LatLng(16.71550, 121.68900),
          LatLng(16.71750, 121.68920),
        ],
        steps: [
          NavigationStep(
            instruction: 'Head Northeast toward Central Boulevard',
            distance: '150m',
            icon: Icons.straight,
            coordinate: LatLng(16.71180, 121.68880),
          ),
          NavigationStep(
            instruction: 'Continue straight along Academic Row',
            distance: '200m',
            icon: Icons.straight,
            coordinate: LatLng(16.71350, 121.68890),
          ),
          NavigationStep(
            instruction: 'Arrive at College of Agriculture - SBO Office on the right',
            distance: '50m',
            icon: Icons.location_on,
            coordinate: LatLng(16.71750, 121.68920),
          ),
        ],
      ),
      const CampusRoute(
        type: RouteType.comfortableShaded,
        title: 'Comfortable Path',
        subtitle: 'Shaded, Wider',
        distance: '800m',
        estimatedTime: '10 mins',
        arrivalTime: '9:51 am',
        icon: Icons.cloud_outlined,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.71250, 121.68980),
          LatLng(16.71450, 121.69020),
          LatLng(16.71680, 121.68990),
          LatLng(16.71750, 121.68920),
        ],
        steps: [
          NavigationStep(
            instruction: 'Head East toward Canopy Walkway',
            distance: '120m',
            icon: Icons.turn_right,
            coordinate: LatLng(16.71180, 121.68880),
          ),
          NavigationStep(
            instruction: 'Follow the covered tree-shaded promenade',
            distance: '450m',
            icon: Icons.straight,
            coordinate: LatLng(16.71250, 121.68980),
          ),
          NavigationStep(
            instruction: 'Turn Left onto Agriculture Quadrangle walkway',
            distance: '230m',
            icon: Icons.turn_left,
            coordinate: LatLng(16.71680, 121.68990),
          ),
        ],
      ),
    ],
    rooms: [
      const CampusRoom(
        id: 'ca_sbo_office',
        title: 'SBO Student Council Room',
        category: RoomCategory.administrative,
        floor: 'Ground Floor',
        icon: Icons.meeting_room,
      ),
      const CampusRoom(
        id: 'ca_dean_office',
        title: "Dean's Office",
        category: RoomCategory.administrative,
        floor: '2nd Floor',
        icon: Icons.account_balance,
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 2. COLLEGE OF COMPUTING STUDIES (CCSICT)
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_ccsict',
    name: 'College of Information & Communications Technology',
    acronym: 'CCSICT',
    category: 'Academic College',
    description:
        'Home to Computer Science, IT, Computer Engineering laboratories, and software research centers.',
    coordinate: const LatLng(16.71866, 121.68846),
    hasShadedPath: true,
    routes: [
      const CampusRoute(
        type: RouteType.shortest,
        title: 'Shortest Route',
        subtitle: 'Direct Walk',
        distance: '500m',
        estimatedTime: '6 mins',
        arrivalTime: '9:47 am',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.71450, 121.68870),
          LatLng(16.71866, 121.68846),
        ],
      ),
      const CampusRoute(
        type: RouteType.comfortableShaded,
        title: 'Comfortable Path',
        subtitle: 'Covered Canopy',
        distance: '650m',
        estimatedTime: '8 mins',
        arrivalTime: '9:49 am',
        icon: Icons.cloud_outlined,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.71300, 121.68950),
          LatLng(16.71600, 121.68930),
          LatLng(16.71866, 121.68846),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 3. COLLEGE OF ENGINEERING (COE)
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_coe',
    name: 'College of Engineering',
    acronym: 'COE',
    category: 'Academic College',
    description:
        'Civil, Agricultural, and Electrical engineering departments, machine shops, and testing labs.',
    coordinate: const LatLng(16.71920, 121.68980),
    hasShadedPath: true,
    routes: [
      const CampusRoute(
        type: RouteType.shortest,
        title: 'Shortest Route',
        subtitle: 'Direct Walk',
        distance: '600m',
        estimatedTime: '7 mins',
        arrivalTime: '9:48 am',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.71500, 121.68900),
          LatLng(16.71920, 121.68980),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 4. UNIVERSITY ADMINISTRATION BUILDING
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_admin',
    name: 'University Administration Building',
    acronym: 'Admin',
    category: 'Administrative & Executive',
    description:
        'University President, Registrar, Cashier, Accounting, and Central Campus Management offices.',
    coordinate: const LatLng(16.71450, 121.68950),
    hasShadedPath: true,
    routes: [
      const CampusRoute(
        type: RouteType.shortest,
        title: 'Shortest Route',
        subtitle: 'Main Boulevard Entrance',
        distance: '300m',
        estimatedTime: '4 mins',
        arrivalTime: '9:45 am',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.71450, 121.68950),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 5. UNIVERSITY MAIN LIBRARY
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_library',
    name: 'University Main Library',
    acronym: 'Library',
    category: 'Learning & Resource Center',
    description:
        'Central knowledge resource center, digital research terminals, and quiet study areas.',
    coordinate: const LatLng(16.71600, 121.69080),
    hasShadedPath: true,
    routes: [
      const CampusRoute(
        type: RouteType.shortest,
        title: 'Shortest Route',
        subtitle: 'Direct Walk',
        distance: '450m',
        estimatedTime: '5 mins',
        arrivalTime: '9:46 am',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.71600, 121.69080),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 6. UNIVERSITY GYMNASIUM & SPORTS COMPLEX
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_gym',
    name: 'University Gymnasium & Sports Complex',
    acronym: 'Gymnasium',
    category: 'Sports & Facilities',
    description:
        'Indoor basketball courts, event stage, athletic offices, and campus gathering center.',
    coordinate: const LatLng(16.72100, 121.69120),
    hasShadedPath: false,
    routes: [
      const CampusRoute(
        type: RouteType.shortest,
        title: 'Shortest Route',
        subtitle: 'Campus Oval Walk',
        distance: '950m',
        estimatedTime: '12 mins',
        arrivalTime: '9:53 am',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.71180, 121.68880),
          LatLng(16.72100, 121.69120),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 7. CAMPUS PARKING AREAS
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'parking_main_gate',
    name: 'Main Gate Vehicle & Motorcycle Parking',
    acronym: 'Main Parking',
    category: 'Campus Parking',
    description:
        'Official designated parking zone for four-wheel vehicles, motorcycles, and campus visitors.',
    coordinate: const LatLng(16.71210, 121.68930),
    isParking: true,
    hasShadedPath: true,
  ),

  CampusBuilding(
    id: 'parking_agriculture',
    name: 'College of Agriculture Parking Lot',
    acronym: 'CA Parking',
    category: 'Campus Parking',
    description:
        'Designated motorcycle and staff parking adjacent to the College of Agriculture complex.',
    coordinate: const LatLng(16.71710, 121.68960),
    isParking: true,
    hasShadedPath: true,
  ),

  CampusBuilding(
    id: 'parking_engineering_ccsict',
    name: 'Engineering & CCSICT Student Parking',
    acronym: 'COE/ICT Parking',
    category: 'Campus Parking',
    description:
        'Covered parking for students and faculty of Engineering and Computing Studies.',
    coordinate: const LatLng(16.71890, 121.68890),
    isParking: true,
    hasShadedPath: true,
  ),
];
