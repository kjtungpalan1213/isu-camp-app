import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../models/campus_models.dart';

// CCSICT Main Focal Point
const LatLng isuMainGateNode = LatLng(16.7187243115489, 121.68845169376614);

final List<CampusBuilding> isuCampusBuildings = [
  // -------------------------------------------------------------
  // 1. CCSICT BUILDING
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_ccsict',
    name: 'CCSICT Building',
    acronym: 'CCSICT',
    category: 'Academic College',
    description:
        'College of Computing Studies, Information and Communication Technology Main Academic Building.',
    coordinate: const LatLng(16.7187243115489, 121.68845169376614),
    imageUrl: 'assets/images/Appdev_background1.png',
    hasShadedPath: true,
    rooms: const [
      // --- 1st Floor ---
      CampusRoom(
        id: 'ccsict_research_office',
        title: 'Research Office',
        category: RoomCategory.administrative,
        floor: '1st Floor',
        icon: Icons.science_outlined,
      ),
      CampusRoom(
        id: 'ccsict_faculty_office',
        title: 'Faculty Office',
        category: RoomCategory.faculty,
        floor: '1st Floor',
        icon: Icons.people_outline,
      ),
      CampusRoom(
        id: 'ccsict_room_2',
        title: 'Room 2',
        category: RoomCategory.classroom,
        floor: '1st Floor',
        icon: Icons.meeting_room_outlined,
      ),
      CampusRoom(
        id: 'ccsict_room_3',
        title: 'Room 3',
        category: RoomCategory.classroom,
        floor: '1st Floor',
        icon: Icons.meeting_room_outlined,
      ),
      CampusRoom(
        id: 'ccsict_room_4',
        title: 'Room 4',
        category: RoomCategory.classroom,
        floor: '1st Floor',
        icon: Icons.meeting_room_outlined,
      ),
      CampusRoom(
        id: 'ccsict_room_5',
        title: 'Room 5',
        category: RoomCategory.classroom,
        floor: '1st Floor',
        icon: Icons.meeting_room_outlined,
      ),
      CampusRoom(
        id: 'ccsict_room_6',
        title: 'Room 6',
        category: RoomCategory.classroom,
        floor: '1st Floor',
        icon: Icons.meeting_room_outlined,
      ),
      CampusRoom(
        id: 'ccsict_female_cr',
        title: 'Female CR',
        category: RoomCategory.facility,
        floor: '1st Floor',
        icon: Icons.wc,
      ),
      CampusRoom(
        id: 'ccsict_male_cr',
        title: 'Male CR',
        category: RoomCategory.facility,
        floor: '1st Floor',
        icon: Icons.wc,
      ),

      // --- 2nd Floor ---
      CampusRoom(
        id: 'ccsict_it_lab_1',
        title: 'IT Lab 1',
        category: RoomCategory.laboratory,
        floor: '2nd Floor',
        icon: Icons.computer_outlined,
      ),
      CampusRoom(
        id: 'ccsict_it_lab_2',
        title: 'IT Lab 2',
        category: RoomCategory.laboratory,
        floor: '2nd Floor',
        icon: Icons.computer_outlined,
      ),
      CampusRoom(
        id: 'ccsict_room_1',
        title: 'Room 1',
        category: RoomCategory.classroom,
        floor: '2nd Floor',
        icon: Icons.meeting_room_outlined,
      ),
      CampusRoom(
        id: 'ccsict_deans_office',
        title: "Deans Office",
        category: RoomCategory.administrative,
        floor: '2nd Floor',
        icon: Icons.admin_panel_settings_outlined,
      ),
      CampusRoom(
        id: 'ccsict_pearson_office',
        title: 'Pearson Office',
        category: RoomCategory.administrative,
        floor: '2nd Floor',
        icon: Icons.business_outlined,
      ),
      CampusRoom(
        id: 'ccsict_it_lab_3',
        title: 'IT Lab 3',
        category: RoomCategory.laboratory,
        floor: '2nd Floor',
        icon: Icons.computer_outlined,
      ),
    ],
    routes: const [
      CampusRoute(
        type: RouteType.shortest,
        title: 'Direct Walkway',
        subtitle: 'Most direct path',
        distance: '50m',
        estimatedTime: '1 min',
        arrivalTime: 'Just now',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.718249233129978, 121.68839873166945),
          LatLng(16.7185000000000, 121.6884200000000),
          LatLng(16.7187243115489, 121.68845169376614),
        ],
        steps: [
          NavigationStep(
            instruction: 'Head North towards CCSICT Main Entrance',
            distance: '50m',
            icon: Icons.straight,
            coordinate: LatLng(16.7187243115489, 121.68845169376614),
          ),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 2. CENTRUM LABORATORIES
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'bldg_centrum_lab',
    name: 'Centrum Laboratories',
    acronym: 'Centrum Lab',
    category: 'Computer Laboratories',
    description:
        'Centrum IT and Computer Laboratories Building housing programming labs, SBO, and faculty facilities.',
    coordinate: const LatLng(16.718249233129978, 121.68839873166945),
    imageUrl: 'assets/images/Appdev_background1.png',
    hasShadedPath: true,
    rooms: const [
      CampusRoom(
        id: 'cl_lab_1',
        title: 'CL Lab 1',
        category: RoomCategory.laboratory,
        floor: 'Ground Floor',
        icon: Icons.computer_outlined,
      ),
      CampusRoom(
        id: 'cl_lab_2',
        title: 'CL Lab 2',
        category: RoomCategory.laboratory,
        floor: 'Ground Floor',
        icon: Icons.computer_outlined,
      ),
      CampusRoom(
        id: 'cl_lab_3',
        title: 'CL Lab 3',
        category: RoomCategory.laboratory,
        floor: '2nd Floor',
        icon: Icons.computer_outlined,
      ),
      CampusRoom(
        id: 'cl_lab_4',
        title: 'CL Lab 4',
        category: RoomCategory.laboratory,
        floor: '2nd Floor',
        icon: Icons.computer_outlined,
      ),
      CampusRoom(
        id: 'centrum_faculty_cr',
        title: 'Faculty CR',
        category: RoomCategory.facility,
        floor: 'Ground Floor',
        icon: Icons.wc,
      ),
      CampusRoom(
        id: 'centrum_sbo_office',
        title: 'SBO Office',
        category: RoomCategory.administrative,
        floor: 'Ground Floor',
        icon: Icons.groups_outlined,
      ),
    ],
    routes: const [
      CampusRoute(
        type: RouteType.shortest,
        title: 'Centrum Path',
        subtitle: 'Direct walkway from CCSICT',
        distance: '50m',
        estimatedTime: '1 min',
        arrivalTime: 'Just now',
        icon: Icons.bolt,
        pathPoints: [
          LatLng(16.7187243115489, 121.68845169376614),
          LatLng(16.7185000000000, 121.6884200000000),
          LatLng(16.718249233129978, 121.68839873166945),
        ],
        steps: [
          NavigationStep(
            instruction: 'Walk South along the covered hallway to Centrum Lab',
            distance: '50m',
            icon: Icons.straight,
            coordinate: LatLng(16.718249233129978, 121.68839873166945),
          ),
        ],
      ),
    ],
  ),

  // -------------------------------------------------------------
  // 3. PARKING AREA 1
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'parking_ccsict_1',
    name: 'Parking Area 1',
    acronym: 'Parking 1',
    category: 'Campus Parking',
    description:
        'Designated parking area near Centrum Laboratories for motorcycles and faculty vehicles.',
    coordinate: const LatLng(16.718287184017132, 121.68843817264855),
    isParking: true,
    hasShadedPath: true,
    rooms: const [],
    routes: const [],
  ),

  // -------------------------------------------------------------
  // 4. PARKING AREA 2
  // -------------------------------------------------------------
  CampusBuilding(
    id: 'parking_ccsict_2',
    name: 'Parking Area 2',
    acronym: 'Parking 2',
    category: 'Campus Parking',
    description:
        'Designated parking area near CCSICT Main Building for student and visitor vehicles.',
    coordinate: const LatLng(16.718871440652308, 121.68854065033383),
    isParking: true,
    hasShadedPath: true,
    rooms: const [],
    routes: const [],
  ),
];
