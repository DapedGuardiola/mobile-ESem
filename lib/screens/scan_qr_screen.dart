import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/event_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/event_model.dart';
import 'dart:convert';

class ScanQRScreen extends StatefulWidget {
  final int? eventId;

  const ScanQRScreen({super.key, this.eventId});

  @override
  State<ScanQRScreen> createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool isScanning = false;
  String? scannedResult;
  int? selectedEventId;
  int? selectedSessionId;
  final AttendanceController attendanceController = AttendanceController();
  final EventController eventController = EventController();
  List<Event> activeEvents = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    selectedEventId = widget.eventId;
    _loadActiveEvents();
  }

  Future<void> _loadActiveEvents() async {
    final result = await eventController.getActiveEvent();
    setState(() {
      activeEvents = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E7D4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9DD79D),
        title: const Text('Scan QR Code'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // =======================
          // Nama Event
          // =======================
          if (activeEvents.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              color: Colors.white,
              child: Text(
                "Event: ${activeEvents[0].eventName}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),

          // =======================
          // Dropdown Pilih Sesi
          // =======================
          Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Pilih Sesi",
              ),
              value: selectedSessionId,
              items: const [
                DropdownMenuItem(value: 1, child: Text("Sesi Pembuka")),
                DropdownMenuItem(value: 2, child: Text("Inti Acara")),
                DropdownMenuItem(value: 3, child: Text("Penutupan")),
              ],
              onChanged: (value) {
                setState(() {
                  selectedSessionId = value;
                  isScanning = false;
                });
              },
            ),
          ),

          // =======================
          // Tombol mulai scan
          // =======================
          if (selectedSessionId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    isScanning = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: const Color(0xFF9DD79D),
                ),
                child: const Text("Mulai Scan QR"),
              ),
            ),

          const SizedBox(height: 10),

          // =======================
          // Kamera hanya tampil setelah pilih sesi
          // =======================
          if (selectedSessionId != null)
            Expanded(
              child: Stack(
                children: [
                  MobileScanner(
                    controller: cameraController,
                    onDetect: (capture) {
                      if (!isScanning && activeEvents.isNotEmpty) {
                        final String? qrData = capture.barcodes.first.rawValue;
                        if (qrData != null) {
                          _processQRCode(qrData);
                        }
                      }
                    },
                  ),

                  // Overlay
                  Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.green, width: 3),
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),

                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.4),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF9DD79D),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Bottom Panel
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  scannedResult ?? 'Arahkan kamera ke QR Code peserta',
                  style: TextStyle(
                    fontSize: 14,
                    color: scannedResult != null ? Colors.green : Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          cameraController.toggleTorch();
        },
        backgroundColor: const Color(0xFF9DD79D),
        child: const Icon(Icons.flash_on),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
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
        currentIndex: 1, // Scan tab active
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
          switch (index) {
            case 0:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
              break;
            case 1:
              // Already on Scan
              break;
            case 2:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/history',
                (route) => false,
              );
              break;
            case 3:
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/profile',
                (route) => false,
              );
              break;
          }
        },
      ),
    );
  }

  Future<void> _processQRCode(String qrData) async {
    if (isLoading) return;
    setState(() {
      isScanning = true;
      scannedResult = qrData;
    });

    final parsed = jsonDecode(qrData);
    final data = {
      "event_id": parsed["event_id"],
      "registered_id": parsed["registered_id"],
      "session_id": selectedSessionId,
    };

    print('data : ');
    print(data);
    setState(() => isLoading = true);

    final result = await attendanceController.scanQR(data);

    setState(() => isLoading = false);

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

    // Kirim ke API

    if (!mounted) return;
    Navigator.pop(context); // Tutup loading dialog

    if (result['success'] == true) {
      _showSuccessDialog(qrData, result['message']);
    } else {
      _showErrorDialog(result['message']);
    }

    // Reset scanning setelah 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          isScanning = false;
        });
      }
    });
  }

  void _showSuccessDialog(String qrData, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 10),
            Text('Absensi Berhasil'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Peserta: $qrData'),
            const SizedBox(height: 10),
            Text('Status: $message'),
            const SizedBox(height: 15),
            const Text(
              'Data telah disimpan ke database',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9DD79D),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 10),
            Text('Gagal Scan'),
          ],
        ),
        content: Text(errorMessage),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9DD79D),
            ),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
