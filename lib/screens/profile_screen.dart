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
  final TextEditingController roleController = TextEditingController();

  final AuthController authController = AuthController();
  
  bool isLoadingProfile = true;
  bool isSaving = false;
  Uint8List? profileImageBytes;
  String profileImageUrl = "";
  String userRole = "User";

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
          namaController.text = data['nama'] ?? data['user_name'] ?? "Nama User";
          emailController.text = data['email'] ?? "user@gmail.com";
          alamatController.text = data['alamat'] ?? data['address'] ?? "Belum diisi";
          teleponController.text = data['telepon'] ?? data['user_phone'] ?? "Belum diisi";
          roleController.text = data['role'] ?? "User";
          userRole = data['role'] ?? "User";
          profileImageUrl = data['profile_image'] ?? "";
          isLoadingProfile = false;
        });

        // Simpan ke SharedPreferences untuk cache
        final prefs = await SharedPreferences.getInstance();
        prefs.setString("nama", namaController.text);
        prefs.setString("email", emailController.text);
        prefs.setString("alamat", alamatController.text);
        prefs.setString("telepon", teleponController.text);
        prefs.setString("role", userRole);
      } else {
        // Fallback ke SharedPreferences jika API gagal
        await _loadFromSharedPreferences();
      }
    } catch (e) {
      print('Error loading profile: $e');
      await _loadFromSharedPreferences();
    }
  }

  Future<void> _loadFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        namaController.text = prefs.getString("nama") ?? "Nama User";
        emailController.text = prefs.getString("email") ?? "user@gmail.com";
        alamatController.text = prefs.getString("alamat") ?? "Belum diisi";
        teleponController.text = prefs.getString("telepon") ?? "Belum diisi";
        userRole = prefs.getString("role") ?? "User";
        roleController.text = userRole;
        isLoadingProfile = false;
      });
    } catch (e) {
      setState(() {
        isLoadingProfile = false;
      });
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat profil: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> saveProfileChanges(Map<String, dynamic> updatedData) async {
    setState(() {
      isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      // Kirim perubahan ke API
      final response = await ApiService.postAuth("/update-profile", updatedData, token);
      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        // Update SharedPreferences
        if (updatedData.containsKey('user_name')) {
          prefs.setString("nama", updatedData['user_name']);
        }
        if (updatedData.containsKey('address')) {
          prefs.setString("alamat", updatedData['address']);
        }
        if (updatedData.containsKey('user_phone')) {
          prefs.setString("telepon", updatedData['user_phone']);
        }

        // Tampilkan sukses
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text('Perubahan berhasil disimpan'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Gagal menyimpan perubahan');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isSaving = false;
      });
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
        
        // Simpan ke API
        await _uploadProfileImage(result.files.single.bytes!);
        
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

  Future<void> _uploadProfileImage(Uint8List imageBytes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");
      
      if (token == null) return;

      // Convert image to base64
      String base64Image = base64Encode(imageBytes);
      
      final response = await ApiService.postAuth("/upload-profile-image", {
        'image': base64Image,
        'filename': 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
      }, token);

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        // Update image URL
        setState(() {
          profileImageUrl = result['image_url'] ?? "";
        });
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  void showEditDialog(String field, TextEditingController controller, String fieldKey) {
    final tempController = TextEditingController(text: controller.text);
    final fieldName = _getFieldDisplayName(fieldKey);
    
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
                  _getIconForField(fieldKey),
                  color: const Color(0xFF9DD79D),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Edit $fieldName',
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
          content: TextField(
            controller: tempController,
            decoration: InputDecoration(
              labelText: fieldName,
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
            maxLines: fieldKey == "alamat" ? 3 : 1,
            keyboardType: fieldKey == "telepon" ? TextInputType.phone : 
                         fieldKey == "email" ? TextInputType.emailAddress : TextInputType.text,
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
                _saveFieldChanges(fieldKey, controller, tempController.text);
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

  Future<void> _saveFieldChanges(String fieldKey, TextEditingController controller, String newValue) async {
    if (newValue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_getFieldDisplayName(fieldKey)} tidak boleh kosong'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (newValue == controller.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak ada perubahan pada ${_getFieldDisplayName(fieldKey)}'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9DD79D)),
              ),
              const SizedBox(height: 16),
              Text(
                'Menyimpan ${_getFieldDisplayName(fieldKey)}...',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      // Prepare data untuk API
      final updateData = <String, dynamic>{};
      
      switch (fieldKey) {
        case "nama":
          updateData['user_name'] = newValue;
          break;
        case "email":
          updateData['email'] = newValue;
          break;
        case "alamat":
          updateData['address'] = newValue;
          break;
        case "telepon":
          updateData['user_phone'] = newValue;
          break;
      }

      await saveProfileChanges(updateData);

      if (!mounted) return;
      Navigator.pop(context); // Tutup loading

      setState(() {
        controller.text = newValue;
      });

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tutup loading
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void showChangePasswordDialog() {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        title: const Row(
          children: [
            Icon(Icons.lock, color: Color(0xFF9DD79D)),
            SizedBox(width: 12),
            Text('Ganti Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Lama',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Password baru tidak cocok'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              await _changePassword(
                oldPasswordController.text,
                newPasswordController.text,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9DD79D),
            ),
            child: const Text('Ganti Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String oldPassword, String newPassword) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("token");

      if (token == null) {
        throw Exception("Token tidak ditemukan");
      }

      final response = await ApiService.postAuth("/change-password", {
        'old_password': oldPassword,
        'new_password': newPassword,
      }, token);

      final result = jsonDecode(response.body);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password berhasil diubah'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(result['message'] ?? 'Gagal mengubah password');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getFieldDisplayName(String fieldKey) {
    switch (fieldKey) {
      case "nama":
        return "Nama Lengkap";
      case "email":
        return "Email";
      case "alamat":
        return "Alamat";
      case "telepon":
        return "Nomor Telepon";
      case "role":
        return "Role";
      default:
        return fieldKey;
    }
  }

  IconData _getIconForField(String fieldKey) {
    switch (fieldKey) {
      case "nama":
        return Icons.person;
      case "email":
        return Icons.email;
      case "alamat":
        return Icons.location_on;
      case "telepon":
        return Icons.phone;
      case "role":
        return Icons.assignment_ind;
      default:
        return Icons.edit;
    }
  }

  String _getFieldKeyForApi(String fieldKey) {
    switch (fieldKey) {
      case "nama":
        return "user_name";
      case "alamat":
        return "address";
      case "telepon":
        return "user_phone";
      default:
        return fieldKey;
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
                  automaticallyImplyLeading: false,
                  title: const Text(
                    'Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  centerTitle: true,
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
                                        : (profileImageUrl.isNotEmpty
                                            ? NetworkImage(profileImageUrl) as ImageProvider
                                            : const AssetImage('assets/images/default_profile.png')),
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
                              child: Text(
                                userRole,
                                style: const TextStyle(
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
                        onEdit: () => showEditDialog("Nama", namaController, "nama"),
                        color: const Color(0xFF9DD79D),
                      ),

                      const SizedBox(height: 12),

                      // Field Email
                      _buildProfileField(
                        icon: Icons.email_outlined,
                        label: "Email",
                        value: emailController.text,
                        onEdit: () => showEditDialog("Email", emailController, "email"),
                        color: const Color(0xFF7EB7E8),
                      ),

                      const SizedBox(height: 12),

                      // Field Alamat
                      _buildProfileField(
                        icon: Icons.location_on_outlined,
                        label: "Alamat",
                        value: alamatController.text,
                        onEdit: () => showEditDialog("Alamat", alamatController, "alamat"),
                        color: const Color(0xFFE89A7E),
                      ),

                      const SizedBox(height: 12),

                      // Field Nomor Telepon
                      _buildProfileField(
                        icon: Icons.phone_outlined,
                        label: "Nomor Telepon",
                        value: teleponController.text,
                        onEdit: () => showEditDialog("Nomor Telepon", teleponController, "telepon"),
                        color: const Color(0xFFE8D77E),
                      ),

                      const SizedBox(height: 12),

                      // Field Role (read-only)
                      _buildProfileField(
                        icon: Icons.assignment_ind_outlined,
                        label: "Role",
                        value: roleController.text,
                        onEdit: null, // Role tidak bisa diedit
                        color: const Color(0xFF9C27B0),
                        isEditable: false,
                      ),

                      const SizedBox(height: 30),

                      // Change Password Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: showChangePasswordDialog,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: const BorderSide(color: Color(0xFF9DD79D), width: 2),
                              ),
                              elevation: 0,
                            ),
                            icon: const Icon(
                              Icons.lock_outline,
                              color: Color(0xFF9DD79D),
                              size: 24,
                            ),
                            label: const Text(
                              'Ganti Password',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF9DD79D),
                              ),
                            ),
                          ),
                        ),
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
          currentIndex: 3, // Account page active
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
                  (route) => false
                );
                break;
              case 1:
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/scan-qr', 
                  (route) => false
                );
                break;
              case 2:
                Navigator.pushNamedAndRemoveUntil(
                  context, 
                  '/history', 
                  (route) => false
                );
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
    required VoidCallback? onEdit,
    required Color color,
    bool isEditable = true,
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
          onTap: isEditable ? onEdit : null,
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
                if (isEditable)
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
    roleController.dispose();
    super.dispose();
  }
}