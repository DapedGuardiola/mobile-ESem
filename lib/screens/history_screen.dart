import 'package:flutter/material.dart';
import '../controllers/event_controller.dart';
import '../controllers/attendance_controller.dart';
import 'event_detail_full_screen.dart';
import '../models/event_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _currentIndex = 2;
  final TextEditingController searchController = TextEditingController();
  final EventController eventController = EventController();
  final AttendanceController attendanceController = AttendanceController();
  
  bool isLoading = true;
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  
  // Untuk filtering
  String selectedFilter = 'all'; // all, today, week, month
  List<Event> todayEvents = [];
  List<Event> thisWeekEvents = [];
  List<Event> thisMonthEvents = [];

  @override
  void initState() {
    super.initState();
    _loadHistoryData();
  }

  Future<void> _loadHistoryData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Load event history
      final result = await eventController.getRecentEvent();
        // Sort by date (newest first)
        final events = result;
        events.sort((a, b) {
          final dateA = DateTime.parse(a.eventDetail!.date);
          final dateB = DateTime.parse(b.eventDetail!.date);
          return dateB.compareTo(dateA);
        });

        setState(() {
          allEvents = events;
          filteredEvents = events;
          _categorizeEvents(events);
        });
    } catch (e) {
      print('Error loading history: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  void _categorizeEvents(List<Event> events) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayList = <Event>[];
    final weekList = <Event>[];
    final monthList = <Event>[];

    for (final event in events) {
      final eventDateStr = event.eventDetail?.date;
      if (eventDateStr == null) continue;
      
      final eventDate = DateTime.tryParse(eventDateStr);
      if (eventDate == null) continue;

      final eventDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
      
      // Calculate difference in days
      final difference = eventDay.difference(today).inDays;

      if (difference == 0) {
        todayList.add(event);
      } else if (difference >= -7 && difference < 0) {
        weekList.add(event);
      } else if (difference >= -30 && difference < 0) {
        monthList.add(event);
      }
    }

    setState(() {
      todayEvents = todayList;
      thisWeekEvents = weekList;
      thisMonthEvents = monthList;
    });
  }

  void _filterEvents(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredEvents = allEvents;
      });
      return;
    }

    final filtered = allEvents.where((event) {
      final name = event.eventName.toString().toLowerCase();
      final location = event.eventDetail?.eventAddress.toString().toLowerCase() ?? '';
      final searchLower = query.toLowerCase();
      
      return name.contains(searchLower) || location.contains(searchLower);
    }).toList();

    setState(() {
      filteredEvents = filtered;
    });
  }

  void _applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });

    switch (filter) {
      case 'today':
        setState(() {
          filteredEvents = todayEvents;
        });
        break;
      case 'week':
        setState(() {
          filteredEvents = thisWeekEvents;
        });
        break;
      case 'month':
        setState(() {
          filteredEvents = thisMonthEvents;
        });
        break;
      default:
        setState(() {
          filteredEvents = allEvents;
        });
        break;
    }
  }

  Future<void> _refreshData() async {
    await _loadHistoryData();
  }

  String _getStatusColor(String status) {
    switch (status.toLowerCase().trim()) {
      case 'ended':
        return '0xFF9E9E9E'; // Green
      case 'on going':
        return '0xFFFF9800'; // Orange
      case 'cancelled':
        return '0xFFF44336'; // Red
      default:
        return '0xFF4CAF50'; // Grey
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase().trim()) {
      case 'ended':
        return 'Selesai';
      case 'on going':
        return 'Berlangsung';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return 'Tidak Diketahui';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E7D4),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar dengan Search
            _buildAppBar(),
            
            // Filter Chips
            _buildFilterChips(),
            
            // Content
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      backgroundColor: const Color(0xFFD4E7D4),
                      color: const Color(0xFF9DD79D),
                      child: filteredEvents.isEmpty
                          ? _buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: filteredEvents.length,
                              itemBuilder: (context, index) {
                                return _buildEventCard(filteredEvents[index]);
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF9DD79D),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                child: Center(
                  child: Text(
                    'Riwayat Event',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadHistoryData,
              ),
            ],
          ),
          const SizedBox(height: 15),
          
          // Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: _filterEvents,
              decoration: InputDecoration(
                hintText: 'Cari event...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          searchController.clear();
                          _filterEvents('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'value': 'all', 'label': 'Semua'},
      {'value': 'today', 'label': 'Hari Ini'},
      {'value': 'week', 'label': 'Minggu Ini'},
      {'value': 'month', 'label': 'Bulan Ini'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: FilterChip(
              label: Text(filter['label']!),
              selected: isSelected,
              onSelected: (selected) {
                _applyFilter(filter['value']!);
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF9DD79D),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF9DD79D) : Colors.grey[300]!,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_toggle_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum ada riwayat event',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Anda belum pernah mengikuti atau membuat event',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/event-detail',
                arguments: {
                  'event_id': 2,
                  'show_export': true, // Ada export di history
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9DD79D),
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Lihat Event Aktif',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(Event event) {
    final formattedDate = event.eventDetail?.dateString ?? 'Tanggal tidak diketahui';
    
    final statusColor = Color(int.parse(_getStatusColor(event.eventStatus)));
    final statusText = _getStatusText(event.eventStatus);
    print('event_status =');
    print(event.eventStatus);
    
    final participantCount = event.eventDetail?.totalParticipant ?? 0;
    final currentParticipants = event.eventDetail?.totalParticipant  ?? 0;
    final attendanceRate = participantCount > 0 
        ? ((currentParticipants / participantCount) * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailFullScreen(
                  eventId: event.eventId,
                  showExport: true,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header dengan tanggal dan status
                Row(
                  children: [
                    // Date indicator
                    Row(
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Event details row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Event Name
                          Text(
                            event.eventName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Time
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Text(
                                event.eventDetail?.timeString ?? 'Waktu tidak diketahui',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          // Location
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  event.eventDetail?.eventAddress ?? 'Lokasi tidak diketahui',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Stats
                          Row(
                            children: [
                              // Participants
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE3F2FD),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.people,
                                      size: 14,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$currentParticipants/$participantCount',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              // Attendance Rate
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E8),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.percent,
                                      size: 14,
                                      color: Colors.green[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '$attendanceRate% hadir',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Action buttons
                          Row(
                            children: [
                              // Info Detail Button
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EventDetailFullScreen(
                                        eventId: event.eventId,
                                        showExport: true,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFFA726),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  elevation: 0,
                                ),
                                child: const Text(
                                  'Info Detail',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              
                              // Export Button (only for completed events)
                              if (event.eventStatus == 'Ended')
                                OutlinedButton(
                                  onPressed: () {
                                    _showExportOptions(event.eventId);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(color: Color(0xFF9DD79D)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                  ),
                                  child: const Text(
                                    'Export',
                                    style: TextStyle(
                                      color: Color(0xFF9DD79D),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Event Image
                    const SizedBox(width: 12),
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://via.placeholder.com/120x120/FF0000/FFFFFF?text=Event',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
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

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF9DD79D),
        unselectedItemColor: Colors.black45,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        currentIndex: _currentIndex,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 28),
            activeIcon: Icon(Icons.home, size: 28),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner, size: 26),
            activeIcon: Icon(Icons.qr_code_scanner, size: 26),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 28),
            activeIcon: Icon(Icons.history, size: 28),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outlined, size: 28),
            activeIcon: Icon(Icons.person, size: 28),
            label: 'Account',
          ),
        ],
        onTap: (index) {
          setState(() => _currentIndex = index);
          
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false
              );
              break;
            case 1:
              Navigator.pushNamed(context, '/scan-qr');
              break;
            case 2:
              // Already on History
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  void _showExportOptions(int eventId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pilih format export:'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportData(eventId, 'pdf');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('PDF'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _exportData(eventId, 'excel');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Excel'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportData(int eventId, String format) async {
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
        ),
      ),
    );

    try {
      final result = await attendanceController.exportAttendance(eventId, format);
      
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
        
        // Jika ada file_url, bisa ditambahkan logika untuk download
        if (result['file_url'] != null) {
          // Implement download logic here
          print('File available at: ${result['file_url']}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}