import 'package:flutter/material.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/event_controller.dart';

class EventDetailFullScreen extends StatefulWidget {
  final int? eventId;
  final bool showExport;
  
  const EventDetailFullScreen({
    super.key,
    this.eventId,
    this.showExport = false,
  });

  @override
  State<EventDetailFullScreen> createState() => _EventDetailFullScreenState();
}

class _EventDetailFullScreenState extends State<EventDetailFullScreen> {
  final TextEditingController searchController = TextEditingController();
  String sortBy = 'Newest';
  int currentPage = 1;
  final int itemsPerPage = 10;
  
  Map<String, dynamic>? eventDetail;
  List<Map<String, dynamic>> participants = [];
  bool isLoading = true;
  
  final AttendanceController attendanceController = AttendanceController();
  final EventController eventController = EventController();

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      _loadEventDetail();
      _loadParticipants();
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _loadEventDetail() async {
    if (widget.eventId == null) return;
    
    try {
      final result = await eventController.getEventDetail(widget.eventId!);
      if (result['success'] == true) {
        setState(() {
          eventDetail = result['data'];
        });
      }
    } catch (e) {
      print('Error loading event detail: $e');
    }
  }

  Future<void> _loadParticipants() async {
    if (widget.eventId == null) return;
    
    setState(() {
      isLoading = true;
    });
    
    try {
      final result = await attendanceController.getEventParticipants(widget.eventId!);
      if (result['success'] == true) {
        setState(() {
          participants = List<Map<String, dynamic>>.from(result['data']);
        });
      } else {
        // Fallback dummy data jika API tidak tersedia
        _loadDummyParticipants();
      }
    } catch (e) {
      print('Error loading participants: $e');
      _loadDummyParticipants();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _loadDummyParticipants() {
    participants = [
      {'name': 'Jane Cooper', 'regist': 'OFF-112', 'time': '07:31:50 AM'},
      {'name': 'Floyd Miles', 'regist': 'ON-074', 'time': '07:31:50 AM'},
      {'name': 'Ronald Richards', 'regist': 'OFF-113', 'time': '07:32:15 AM'},
      {'name': 'Savannah Nguyen', 'regist': 'ON-075', 'time': '07:33:20 AM'},
      {'name': 'Kathryn Murphy', 'regist': 'OFF-114', 'time': '07:34:10 AM'},
    ];
  }

  Future<void> _refreshData() async {
    await Future.wait([
      _loadEventDetail(),
      _loadParticipants(),
    ]);
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Container(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF9DD79D),
                      Color(0xFF7EB7E8),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // App Name
              const Text(
                'ESEM',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 25),

              // Question
              const Text(
                'Export File dengan\nformat PDF?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 30),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'CANCEL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _exportToPDF();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'YES',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _exportToPDF() async {
    if (widget.eventId == null) return;
    
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
        ),
      ),
    );

    try {
      final result = await attendanceController.exportAttendance(widget.eventId!, 'pdf');
      
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: const Color(0xFF00897B),
          ),
        );
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
          content: Text('Error exporting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _exportToExcel() async {
    if (widget.eventId == null) return;
    
    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
        ),
      ),
    );

    try {
      final result = await attendanceController.exportAttendance(widget.eventId!, 'excel');
      
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
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
          content: Text('Error exporting: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Tanggal tidak diketahui';
    
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E7D4),
      body: SafeArea(
        child: Column(
          children: [
            // Header DENGAN TOMBOL BACK
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF9DD79D),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Tombol Back
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Detail Event',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  // Spacer untuk balance layout
                  Container(
                    width: 45,
                    height: 45,
                  ),
                ],
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshData,
                backgroundColor: const Color(0xFFD4E7D4),
                color: const Color(0xFF9DD79D),
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Event Info Card
                            if (eventDetail != null) _buildEventInfoCard(),
                            
                            const SizedBox(height: 20),

                            // Search and Sort Row
                            Row(
                              children: [
                                // Search
                                Expanded(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Search peserta...',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 15,
                                          vertical: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Sort Dropdown
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        'Short by : ',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      DropdownButton<String>(
                                        value: sortBy,
                                        underline: const SizedBox(),
                                        icon: const Icon(Icons.keyboard_arrow_down),
                                        items: ['Newest', 'Oldest', 'Name']
                                            .map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            sortBy = newValue!;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Participant Count & Export Buttons
                            Row(
                              children: [
                                // Participant Count
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.people_outline,
                                          color: Colors.black87,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${participants.length} Participant',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Export Buttons (only show in History)
                                if (widget.showExport) ...[
                                  const SizedBox(width: 12),
                                  _buildExportButton(
                                    icon: Icons.picture_as_pdf,
                                    color: Colors.red,
                                    onTap: _showExportDialog,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildExportButton(
                                    icon: Icons.table_chart,
                                    color: Colors.green,
                                    onTap: _exportToExcel,
                                  ),
                                ],
                              ],
                            ),

                            const SizedBox(height: 20),

                            // Address
                            if (eventDetail != null && eventDetail!['location'] != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Alamat:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      eventDetail!['location'] ?? 'Alamat tidak tersedia',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Event Description
                            if (eventDetail != null && eventDetail!['description'] != null)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Deskripsi:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      eventDetail!['description'] ?? 'Deskripsi tidak tersedia',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                        height: 1.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            const SizedBox(height: 20),

                            // Participants Table
                            participants.isEmpty
                                ? _buildNoParticipants()
                                : _buildParticipantsTable(),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      // HAPUS BOTTOM NAVIGATION BAR DI DETAIL EVENT
      // Karena kita sudah punya tombol back untuk kembali
    );
  }

  Widget _buildEventInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Event Name
          Text(
            eventDetail!['name'] ?? 'Nama Event',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),

          // Date and Time
          Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                _formatDate(eventDetail!['date']),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(width: 20),
              Icon(Icons.access_time, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                eventDetail!['time'] ?? 'Waktu tidak diketahui',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Type and Max Participants
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: eventDetail!['type'] == 'paid' 
                      ? const Color(0xFFF3E5F5) 
                      : const Color(0xFFE8F5E8),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: eventDetail!['type'] == 'paid' 
                        ? const Color(0xFF7B1FA2) 
                        : const Color(0xFF9DD79D),
                  ),
                ),
                child: Text(
                  eventDetail!['type'] == 'paid' ? 'Berbayar' : 'Gratis',
                  style: TextStyle(
                    fontSize: 12,
                    color: eventDetail!['type'] == 'paid' 
                        ? const Color(0xFF7B1FA2) 
                        : const Color(0xFF5AA65A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF7EB7E8)),
                ),
                child: Text(
                  'Maks: ${eventDetail!['max_participants'] ?? 0} peserta',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1976D2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoParticipants() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            Icons.people_outline,
            size: 60,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada peserta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tidak ada peserta yang terdaftar di event ini',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantsTable() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFFE8E8E8),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'Nama Peserta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'No Regist',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Waktu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // Table Rows
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: participants.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            itemBuilder: (context, index) {
              final participant = participants[index];
              return Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        participant['name'] ?? 'Nama tidak diketahui',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        participant['regist'] ?? '-',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB2DFDB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF00897B),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          participant['time'] ?? '-',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00897B),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Pagination Info & Controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Showing data 1 to ${participants.length} of ${participants.length} entries',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 15),

                // Pagination Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildPaginationButton(
                      icon: Icons.chevron_left,
                      isActive: false,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildPaginationButton(
                      label: '1',
                      isActive: true,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildPaginationButton(
                      label: '...',
                      isActive: false,
                      onTap: () {},
                    ),
                    const SizedBox(width: 8),
                    _buildPaginationButton(
                      icon: Icons.chevron_right,
                      isActive: false,
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 26),
      ),
    );
  }

  Widget _buildPaginationButton({
    String? label,
    IconData? icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: label == '...' ? 8 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFFA726) : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: icon != null
            ? Icon(
                icon,
                size: 18,
                color: isActive ? Colors.white : Colors.black54,
              )
            : Text(
                label!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.black54,
                  fontSize: 14,
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}