import 'package:latlong2/latlong.dart';
import '../models/campus_models.dart';

// ISU Echague campus focal point used by the frontend map.
const LatLng isuCampusCenter = LatLng(16.721646458577446, 121.69173144090183);

// Mock navigation entrance until the admin-provided gate is available.
const LatLng isuMainGateNode = LatLng(16.7187243115489, 121.68845169376614);

// Loaded from the backend; no sample buildings are used as a fallback.
final List<CampusBuilding> isuCampusBuildings = [];
