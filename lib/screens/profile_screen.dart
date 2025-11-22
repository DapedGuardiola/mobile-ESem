import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../controllers/auth_controller.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();

  final AuthController authController = AuthController();
  
  bool isLoadingProfile = true;
  Uint8List? profileImageBytes;
  String profileImageUrl = "https://images.unsplash.com/photo-1633332755192-727a05c4013d?w=400";

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  Future<void> loadUserProfile() async {
    try {
      final result = await authController.getMe();
      
      if (result['success'] == true) {
        final data = result['data'];
        setState(() {
          namaController.text = data['nama'] ?? "Nama User";
          emailController.text = data['email'] ?? "user@gmail.com";
          alamatController.text = data['alamat'] ?? "Belum diisi";
          teleponController.text = data['telepon'] ?? "Belum diisi";
          isLoadingProfile = false;
        });

        // Simpan ke SharedPreferences untuk cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("nama", data['nama'] ?? "");
        prefs.setString("email", data['email'] ?? "");
        prefs.setString("alamat", data['alamat'] ?? "");
        prefs.setString("telepon", data['telepon'] ?? "");
      } else {
        setState(() {
          isLoadingProfile = false;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Gagal memuat profil'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        isLoadingProfile = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login',
      (Route<dynamic> route) => false,
    );
  }

  Future<void> changeProfilePicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.bytes != null) {
        setState(() {
          profileImageBytes = result.files.single.bytes;
        });
        
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Foto profil berhasil diubah'),
              ],
            ),
            backgroundColor: const Color(0xFF9DD79D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error memilih foto: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void showEditDialog(String field, TextEditingController controller) {
    final tempController = TextEditingController(text: controller.text);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9DD79D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _getIconForField(field),
                  color: const Color(0xFF9DD79D),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Edit $field',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          content: TextField(
            controller: tempController,
            decoration: InputDecoration(
              labelText: field,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF9DD79D), width: 2),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            maxLines: field == "Alamat" ? 3 : 1,
            keyboardType: field == "Nomor Telepon" ? TextInputType.phone : TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                showSaveConfirmationDialog(field, controller, tempController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9DD79D),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Simpan',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSaveConfirmationDialog(String field, TextEditingController controller, String newValue) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
            ),
            const SizedBox(width: 12),
            const Text(
              'Konfirmasi Perubahan',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apakah Anda yakin ingin menyimpan perubahan?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _getIconForField(field),
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        field,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    newValue,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Perubahan akan tersimpan permanen',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              // Tampilkan loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: Container(
                    padding: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Menyimpan perubahan...',
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              );

              try {
                // Kirim ke API
                final prefs = await SharedPreferences.getInstance();
                String? token = prefs.getString("token");

                final response = await ApiService.postAuth("/update-profile", {
                  "user_name": namaController.text,
                  "address": alamatController.text,
                  "user_phone": teleponController.text,
                }, token!);

                final result = jsonDecode(response.body);

                if (!mounted) return;
                Navigator.pop(context); // Tutup loading

                if (result['success'] == true) {
                  setState(() {
                    controller.text = newValue;
                  });

                  // Update SharedPreferences
                  final fieldKey = _getFieldKey(field);
                  prefs.setString(fieldKey, newValue);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 12),
                          Expanded(child: Text('$field berhasil diperbarui')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF9DD79D),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Gagal memperbarui profil'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (!mounted) return;
                Navigator.pop(context); // Tutup loading
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9DD79D),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Ya, Simpan',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  String _getFieldKey(String field) {
    switch (field) {
      case "Nama":
      case "Nama Lengkap":
        return "nama";
      case "Email":
        return "email";
      case "Alamat":
        return "alamat";
      case "Nomor Telepon":
        return "telepon";
      default:
        return field.toLowerCase();
    }
  }

  IconData _getIconForField(String field) {
    switch (field) {
      case "Nama":
      case "Nama Lengkap":
        return Icons.person;
      case "Email":
        return Icons.email;
      case "Alamat":
        return Icons.location_on;
      case "Nomor Telepon":
        return Icons.phone;
      default:
        return Icons.edit;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4E7D4),
      body: isLoadingProfile
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
              ),
            )
          : CustomScrollView(
              slivers: [
                // Custom App Bar dengan gradient
                SliverAppBar(
                  expandedHeight: 100,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF9DD79D),
                  elevation: 0,
                  leading: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  actions: [
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white, size: 24),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                              title: const Row(
                                children: [
                                  Icon(Icons.logout, color: Colors.red),
                                  SizedBox(width: 12),
                                  Text('Logout'),
                                ],
                              ),
                              content: const Text('Apakah Anda yakin ingin keluar?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Batal',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    logout();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF9DD79D),
                            Color(0xFF7EC97E),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Content
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),

                      // Profile Card
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF9DD79D).withOpacity(0.3),
                                        blurRadius: 20,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.grey[300],
                                    backgroundImage: profileImageBytes != null
                                        ? MemoryImage(profileImageBytes!)
                                        : NetworkImage(profileImageUrl) as ImageProvider,
                                  ),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: changeProfilePicture,
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9DD79D),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 3),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.2),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              namaController.text,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF9DD79D).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "User",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF5AA65A),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Section Title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                color: const Color(0xFF9DD79D),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              "Informasi Pribadi",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Field Nama
                      _buildProfileField(
                        icon: Icons.person_outline,
                        label: "Nama Lengkap",
                        value: namaController.text,
                        onEdit: () => showEditDialog("Nama", namaController),
                        color: const Color(0xFF9DD79D),
                      ),

                      const SizedBox(height: 12),

                      // Field Email
                      _buildProfileField(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: emailController.text,
                        onEdit: () => showEditDialog("Email", emailController),
                        color: const Color(0xFF7EB7E8),
                      ),

                      const SizedBox(height: 12),

                      // Field Alamat
                      _buildProfileField(
                        icon: Icons.location_on_outlined,
                        label: "Alamat",
                        value: alamatController.text,
                        onEdit: () => showEditDialog("Alamat", alamatController),
                        color: const Color(0xFFE89A7E),
                      ),

                      const SizedBox(height: 12),

                      // Field Nomor Telepon
                      _buildProfileField(
                        icon: Icons.phone_outlined,
                        label: "Nomor Telepon",
                        value: teleponController.text,
                        onEdit: () => showEditDialog("Nomor Telepon", teleponController),
                        color: const Color(0xFFE8D77E),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
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
          currentIndex: 3,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today_outlined, size: 26),
              activeIcon: Icon(Icons.calendar_today, size: 26),
              label: 'Event',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, size: 28),
              activeIcon: Icon(Icons.history, size: 28),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon: Icon(Icons.person, size: 28),
              label: 'Account',
            ),
          ],
          onTap: (index) {
            // Navigation logic
            switch (index) {
              case 0:
                // Navigator.pushNamed(context, '/home');
                break;
              case 1:
                // Navigator.pushNamed(context, '/event');
                break;
              case 2:
                // Navigator.pushNamed(context, '/history');
                break;
              case 3:
                // Already on Account page
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onEdit,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        value,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    alamatController.dispose();
    teleponController.dispose();
    super.dispose();
  }
}