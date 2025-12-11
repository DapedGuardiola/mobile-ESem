import 'package:flutter/material.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  int _currentIndex = 1; // Event tab active
  final TextEditingController searchController = TextEditingController();

  // Dummy data
  final List<Map<String, dynamic>> todayEvents = [
    {
      'date': '22 August 2025',
      'name': 'Good Day SCHOOLICIOUS',
      'time': '07.30 - 15.00',
      'location': 'Graha Polinema, Malang, Jawa Timur',
      'image': 'assets/img/event_placeholder.png',
    },
  ];

  final List<Map<String, dynamic>> thisWeekEvents = [
    {
      'date': '22 August 2025',
      'name': 'Good Day SCHOOLICIOUS',
      'time': '07.30 - 15.00',
      'location': 'Graha Polinema, Malang, Jawa Timur',
      'image': 'assets/img/event_placeholder.png',
    },
    {
      'date': '22 August 2025',
      'name': 'Good Day SCHOOLICIOUS',
      'time': '07.30 - 15.00',
      'location': 'Graha Polinema, Malang, Jawa Timur',
      'image': 'assets/img/event_placeholder.png',
    },
  ];

  final List<Map<String, dynamic>> thisMonthEvents = [
    {
      'date': '22 August 2025',
      'name': 'Good Day SCHOOLICIOUS',
      'time': '07.30 - 15.00',
      'location': 'Graha Polinema, Malang, Jawa Timur',
      'image': 'assets/img/event_placeholder.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E7D4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
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
                    decoration: InputDecoration(
                      hintText: 'Search',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // TODAY Section
                _buildSectionHeader('TODAY'),
                const SizedBox(height: 15),
                ...todayEvents.map((event) => _buildEventCard(event, true)),

                const SizedBox(height: 30),

                // THIS WEEK Section
                _buildSectionHeader('THIS WEEK'),
                const SizedBox(height: 15),
                ...thisWeekEvents.map((event) => _buildEventCard(event, false)),

                const SizedBox(height: 30),

                // THIS MONTH Section
                _buildSectionHeader('THIS MONTH'),
                const SizedBox(height: 15),
                ...thisMonthEvents.map((event) => _buildEventCard(event, false)),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isToday) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          // Left Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date with indicator
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFA726),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event['date'],
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFA726),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Event Name
                Text(
                  event['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),

                // Time
                Text(
                  event['time'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),

                // Location
                Text(
                  event['location'],
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Info Detail Button
                SizedBox(
                  width: 120,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/event-detail',
                        arguments: {
                          'event_id': 3, // Ganti dengan ID event yang sebenarnya
                          'show_export': false,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA726),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Event Image
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red,
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
            icon: Icon(Icons.add_box_outlined, size: 28),
            activeIcon: Icon(Icons.add_box, size: 28),
            label: 'Event',
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
              Navigator.pushNamed(context, '/scan-qr'); // PERBAIKAN
              break;
            case 2:
              Navigator.pushNamed(context, '/history');
              break;
            case 3:
              Navigator.pushNamed(context, '/profile');
              break;
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}