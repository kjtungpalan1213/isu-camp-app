import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/screens/help_screen.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/services/user_session.dart';
import '../data/campus_dataset.dart';
import '../models/campus_models.dart';
import '../models/navigation_history.dart';
import '../services/navigation_history_service.dart';
import 'about_us_screen.dart';

// =========================================================================
// 1. MAIN USER INFO SCREEN
// =========================================================================
class UserInfoScreen extends StatefulWidget {
  final Function(CampusBuilding destination)? onNavigateToBuilding;

  const UserInfoScreen({
    super.key,
    this.onNavigateToBuilding,
  });

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final username = UserSession.currentUsername;

    return Scaffold(
      backgroundColor: const Color(0xFF0B351E),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // 1. Top Header with Faded Campus Image, "Done" button, and Curved Arch
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                ClipPath(
                  clipper: _UserHeaderCurveClipper(),
                  child: Container(
                    height: 250,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/Appdev_background1.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(color: Colors.grey.shade200),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withValues(alpha: 0.90),
                                Colors.white.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                        ),
                        SafeArea(
                          bottom: false,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                top: 18.0,
                                right: 24.0,
                              ),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Text(
                                  'Done',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Circular Avatar centered over the curved arch
                Positioned(
                  bottom: -48,
                  child: Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEDF0F2),
                      border: Border.all(
                        color: const Color(0xFF1F2937),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.22),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.person_outline,
                        size: 58,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 58),

            // 2. Dynamic Username Text from Authentication
            Text(
              username,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.4,
              ),
            ),

            const SizedBox(height: 28),

            // 3. User Menu Cards Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Card 1: Offline Map
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const _OfflineMapSubScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.cloud_download_outlined,
                              color: Color(0xFF757575),
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                'Offline Map',
                                style: GoogleFonts.montserrat(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF9CA3AF),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Card 2: Grouped Menu (History, About us, Help)
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildMenuRow(
                            icon: Icons.access_time,
                            label: 'History',
                            onTap: () async {
                              final destination =
                                  await Navigator.push<CampusBuilding>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const _HistorySubScreen(),
                                ),
                              );
                              if (!context.mounted || destination == null) {
                                return;
                              }
                              Navigator.pop(context);
                              widget.onNavigateToBuilding?.call(destination);
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                          _buildMenuRow(
                            icon: Icons.people_outline,
                            label: 'About us',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AboutUsScreen(),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFF1F5F9),
                          ),
                          _buildMenuRow(
                            icon: Icons.help_outline,
                            label: 'Help',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const HelpScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 4. Log Out Outlined Button
                    SizedBox(
                      width: 175,
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () {
                          UserSession.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          'Log Out',
                          style: GoogleFonts.montserrat(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuRow({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6B7280), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.montserrat(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFF9CA3AF),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserHeaderCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 25,
      size.width,
      size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

// =========================================================================
// 2. OFFLINE MAP VIEW (Compiled into user_info_screen.dart)
// =========================================================================
enum DownloadStatus {
  notDownloaded,
  downloading,
  paused,
  completed,
}

class _OfflineMapSubScreen extends StatefulWidget {
  const _OfflineMapSubScreen();

  @override
  State<_OfflineMapSubScreen> createState() => _OfflineMapSubScreenState();
}

class _OfflineMapSubScreenState extends State<_OfflineMapSubScreen> {
  DownloadStatus _status = DownloadStatus.notDownloaded;
  double _progress = 0.0;
  Timer? _downloadTimer;
  final double _totalSizeMb = 30.0;

  @override
  void dispose() {
    _downloadTimer?.cancel();
    super.dispose();
  }

  void _startOrResumeDownload() {
    setState(() {
      _status = DownloadStatus.downloading;
    });

    _downloadTimer?.cancel();
    _downloadTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress += 0.025;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _status = DownloadStatus.completed;
          timer.cancel();
          _showCompletedSnackbar();
        }
      });
    });
  }

  void _pauseDownload() {
    _downloadTimer?.cancel();
    setState(() {
      _status = DownloadStatus.paused;
    });
  }

  void _deleteDownload() {
    _downloadTimer?.cancel();
    setState(() {
      _status = DownloadStatus.notDownloaded;
      _progress = 0.0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Offline map deleted from storage.',
          style: GoogleFonts.montserrat(fontSize: 12.5),
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showCompletedSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'KUMPAS Campus Map downloaded successfully! Offline navigation is now active.',
                style: GoogleFonts.montserrat(fontSize: 12.5),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF0F751B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final downloadedMb = (_progress * _totalSizeMb).toStringAsFixed(1);
    final percentage = (_progress * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFF0B351E),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar with Back and "Done" buttons
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white70,
                      size: 20,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Done',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // Gold Cloud Outline Icon + "Offline Map" Title
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_download_outlined,
                          size: 52,
                          color: Color(0xFFECC700),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Offline Map',
                          style: GoogleFonts.montserrat(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description Paragraph
                    Text(
                      'To use KUMPAS offline, start by downloading the map. Then you\'ll be able to search and get directions with the map even without internet connection.',
                      style: GoogleFonts.montserrat(
                        fontSize: 13.5,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.45,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Download Card with Interactive Pause / Resume / Cancel Controls
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildStatusIcon(),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'ISU Map (Echague Campus)',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _status == DownloadStatus.completed
                                          ? '30 MB • Offline Ready'
                                          : _status ==
                                                  DownloadStatus.downloading
                                              ? '$downloadedMb MB / 30 MB • $percentage%'
                                              : _status == DownloadStatus.paused
                                                  ? '$downloadedMb MB / 30 MB • Paused'
                                                  : '30 MB',
                                      style: GoogleFonts.montserrat(
                                        fontSize: 12,
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildActionButton(),
                            ],
                          ),
                          if (_status == DownloadStatus.downloading ||
                              _status == DownloadStatus.paused) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _progress,
                                minHeight: 6,
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _status == DownloadStatus.paused
                                      ? const Color(0xFFECC700)
                                      : const Color(0xFF00B2FE),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Feature Highlights Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _buildFeatureRow(
                            icon: Icons.search,
                            title: 'Offline Building Search',
                            subtitle:
                                'Search all colleges, offices, and rooms with zero mobile data.',
                          ),
                          const SizedBox(height: 14),
                          _buildFeatureRow(
                            icon: Icons.directions_walk,
                            title: 'Turn-by-Turn Offline Routing',
                            subtitle:
                                'Navigate shortest and comfortable shaded paths anywhere on campus.',
                          ),
                          const SizedBox(height: 14),
                          _buildFeatureRow(
                            icon: Icons.local_parking,
                            title: 'Parking & Facilities Locator',
                            subtitle:
                                'Find vehicle & motorcycle parking spots without internet.',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    switch (_status) {
      case DownloadStatus.completed:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0F751B),
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 22),
        );
      case DownloadStatus.downloading:
        return const SizedBox(
          width: 38,
          height: 38,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B2FE)),
          ),
        );
      case DownloadStatus.paused:
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFECC700),
          ),
          child: const Icon(Icons.pause, color: Colors.black87, size: 22),
        );
      case DownloadStatus.notDownloaded:
        return const Icon(
          Icons.cloud_download_outlined,
          color: Colors.white70,
          size: 38,
        );
    }
  }

  Widget _buildActionButton() {
    switch (_status) {
      case DownloadStatus.notDownloaded:
        return ElevatedButton.icon(
          onPressed: _startOrResumeDownload,
          icon: const Icon(Icons.download, size: 16, color: Colors.black87),
          label: Text(
            'Download',
            style: GoogleFonts.montserrat(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFECC700),
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      case DownloadStatus.downloading:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.pause_circle_outline,
                  color: Color(0xFFECC700), size: 28),
              tooltip: 'Pause Download',
              onPressed: _pauseDownload,
            ),
            IconButton(
              icon: const Icon(Icons.cancel_outlined,
                  color: Colors.redAccent, size: 24),
              tooltip: 'Cancel Download',
              onPressed: _deleteDownload,
            ),
          ],
        );
      case DownloadStatus.paused:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.play_circle_outline,
                  color: Color(0xFF22C55E), size: 28),
              tooltip: 'Resume Download',
              onPressed: _startOrResumeDownload,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  color: Colors.redAccent, size: 24),
              tooltip: 'Delete Download',
              onPressed: _deleteDownload,
            ),
          ],
        );
      case DownloadStatus.completed:
        return IconButton(
          icon:
              const Icon(Icons.delete_outline, color: Colors.white60, size: 24),
          tooltip: 'Delete Offline Map',
          onPressed: _deleteDownload,
        );
    }
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFFECC700), size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.montserrat(
                  fontSize: 11.5,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// 3. NAVIGATION HISTORY
// =========================================================================
class _HistorySubScreen extends StatefulWidget {
  const _HistorySubScreen();

  @override
  State<_HistorySubScreen> createState() => _HistorySubScreenState();
}

class _HistorySubScreenState extends State<_HistorySubScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<NavigationHistoryEntry> _historyItems = [];
  bool _isLoading = true;

  List<NavigationHistoryEntry> get _filteredItems {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _historyItems;
    return _historyItems.where((item) {
      return item.destinationName.toLowerCase().contains(query) ||
          item.destinationAcronym.toLowerCase().contains(query) ||
          (item.roomName?.toLowerCase().contains(query) ?? false) ||
          item.originLabel.toLowerCase().contains(query) ||
          _statusLabel(item.status).toLowerCase().contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final entries =
        await NavigationHistoryService.load(UserSession.currentUsername);
    if (!mounted) return;
    setState(() {
      _historyItems = entries;
      _isLoading = false;
    });
  }

  Future<void> _deleteEntry(NavigationHistoryEntry entry) async {
    setState(() => _historyItems.removeWhere((item) => item.id == entry.id));
    await NavigationHistoryService.delete(
      UserSession.currentUsername,
      entry.id,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'History item deleted.',
          style: GoogleFonts.montserrat(fontSize: 12.5),
        ),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFFA7F3D0),
          onPressed: () async {
            await NavigationHistoryService.upsert(
              UserSession.currentUsername,
              entry,
            );
            await _loadHistory();
          },
        ),
      ),
    );
  }

  Future<void> _clearHistory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear navigation history?'),
        content: const Text('This will remove all saved destinations.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await NavigationHistoryService.clear(UserSession.currentUsername);
    if (!mounted) return;
    setState(() => _historyItems.clear());
  }

  void _openDestination(NavigationHistoryEntry entry) {
    final matches = isuCampusBuildings
        .where((building) => building.id == entry.destinationId);
    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This destination is no longer available.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    Navigator.pop(context, matches.first);
  }

  String _statusLabel(NavigationHistoryStatus status) {
    switch (status) {
      case NavigationHistoryStatus.previewed:
        return 'Previewed';
      case NavigationHistoryStatus.navigationStarted:
        return 'Navigation started';
      case NavigationHistoryStatus.endedEarly:
        return 'Ended early';
      case NavigationHistoryStatus.completed:
        return 'Completed';
    }
  }

  Color _statusColor(NavigationHistoryStatus status) {
    switch (status) {
      case NavigationHistoryStatus.previewed:
        return const Color(0xFF2563EB);
      case NavigationHistoryStatus.navigationStarted:
        return const Color(0xFF0F751B);
      case NavigationHistoryStatus.endedEarly:
        return const Color(0xFFD97706);
      case NavigationHistoryStatus.completed:
        return const Color(0xFF047857);
    }
  }

  IconData _transportIcon(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return Icons.directions_walk;
      case TransportMode.bicycle:
        return Icons.pedal_bike;
      case TransportMode.motorcycle:
        return Icons.two_wheeler;
      case TransportMode.car:
        return Icons.directions_car;
    }
  }

  String _transportLabel(TransportMode mode) {
    switch (mode) {
      case TransportMode.walking:
        return 'Walk';
      case TransportMode.bicycle:
        return 'Bike';
      case TransportMode.motorcycle:
        return 'Motorcycle';
      case TransportMode.car:
        return 'Car';
    }
  }

  String _dateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(itemDate).inDays;
    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _timeLabel(DateTime date) {
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute ${date.hour >= 12 ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final visibleItems = _filteredItems;
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF072B18),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          'History',
          style: GoogleFonts.montserrat(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_historyItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear History',
              onPressed: _clearHistory,
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search destinations or starting points',
                hintStyle: GoogleFonts.montserrat(fontSize: 12.5),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0F751B)),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close, size: 19),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFDDE7E0)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF0F751B)),
                  )
                : _historyItems.isEmpty
                    ? _buildEmptyHistory()
                    : visibleItems.isEmpty
                        ? _buildNoResults()
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
                            itemCount: visibleItems.length,
                            itemBuilder: (context, index) {
                              final entry = visibleItems[index];
                              final group = _dateGroup(entry.updatedAt);
                              final showGroup = index == 0 ||
                                  _dateGroup(
                                          visibleItems[index - 1].updatedAt) !=
                                      group;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (showGroup) ...[
                                    Padding(
                                      padding: EdgeInsets.only(
                                        top: index == 0 ? 2 : 16,
                                        bottom: 9,
                                        left: 2,
                                      ),
                                      child: Text(
                                        group,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF52665A),
                                        ),
                                      ),
                                    ),
                                  ],
                                  _buildHistoryCard(entry),
                                  const SizedBox(height: 11),
                                ],
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(NavigationHistoryEntry entry) {
    final statusColor = _statusColor(entry.status);
    final routeLabel = entry.routeType == RouteType.shortest
        ? 'Shortest route'
        : 'Comfortable path';
    return Dismissible(
      key: ValueKey(entry.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _deleteEntry(entry),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 22),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _openDestination(entry),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFDDE7E0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.035),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
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
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEAF7EE),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF0F751B),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.destinationName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.montserrat(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF17251D),
                            ),
                          ),
                          if (entry.roomName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              entry.roomName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                color: const Color(0xFF66756C),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Delete item',
                      onPressed: () => _deleteEntry(entry),
                      icon: const Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: Color(0xFF8A9690),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 11),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _historyChip(
                      _statusLabel(entry.status),
                      Icons.circle,
                      statusColor,
                    ),
                    _historyChip(
                      _transportLabel(entry.transportMode),
                      _transportIcon(entry.transportMode),
                      const Color(0xFF0F751B),
                    ),
                    _historyChip(
                      routeLabel,
                      Icons.route,
                      const Color(0xFF52665A),
                    ),
                  ],
                ),
                const Divider(height: 22, color: Color(0xFFE7ECE9)),
                Row(
                  children: [
                    const Icon(
                      Icons.trip_origin,
                      size: 14,
                      color: Color(0xFF22A653),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${entry.originLabel}  →  ${entry.destinationAcronym}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.montserrat(
                          fontSize: 11.5,
                          color: const Color(0xFF52665A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 9),
                Row(
                  children: [
                    Text(
                      '${entry.distanceMeters.round()} m',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17251D),
                      ),
                    ),
                    const Text('  •  ', style: TextStyle(color: Colors.grey)),
                    Text(
                      '${entry.estimatedMinutes.ceil()} min',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF17251D),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _timeLabel(entry.updatedAt),
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        color: const Color(0xFF78847D),
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF0F751B),
                      size: 19,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _historyChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: icon == Icons.circle ? 7 : 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.montserrat(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.history,
                size: 42,
                color: Color(0xFF0F751B),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No navigation history yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF26362D),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Previewed and started routes will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(
                fontSize: 12.5,
                color: const Color(0xFF718078),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Text(
        'No matching destinations found.',
        style: GoogleFonts.montserrat(
          fontSize: 13,
          color: const Color(0xFF718078),
        ),
      ),
    );
  }
}
