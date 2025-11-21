import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ===============================
  // CONTROLLERS
  // ===============================
  final TextEditingController emailController = TextEditingController();
  final TextEditingController namaController = TextEditingController();
  final TextEditingController alamatController = TextEditingController();
  final TextEditingController teleponController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthController authController = AuthController();
  // Role dropdown
  String? selectedRole;

  bool isLoading = false;
    void register() async {
      setState(() {
        isLoading = true;
      });
      Map<String, dynamic> data = {
        "role_id" : 1,
        "email": emailController.text,
        "password": passwordController.text,
        "user_name": namaController.text,
        "address": alamatController.text,
        "user_phone": teleponController.text,
      };
      try {
        Map result = await authController.register(data);
        if (!mounted) return;
        if (result.containsKey('token')) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Register berhasil!')));
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'Register gagal')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error:$e')),);
      }
      finally{
        setState(() {
          isLoading = false;
        });
      }
      
    }
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          SizedBox(
            height: screenHeight,
            width: screenWidth,
            child: Image.asset(
              'assets/img/landingpagebg.png',
              fit: BoxFit.cover,
            ),
          ),

          // ===== Register Card Center =====
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 30),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Register",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // Role (Dropdown)
                    // =========================
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: "Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: const [
                        DropdownMenuItem(value: "admin", child: Text("Admin")),
                        DropdownMenuItem(
                          value: "panitia",
                          child: Text("Panitia"),
                        ),
                        DropdownMenuItem(
                          value: "peserta",
                          child: Text("Peserta"),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // Email
                    // =========================
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // Nama Lengkap
                    // =========================
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: "Nama Lengkap",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // Alamat
                    // =========================
                    TextField(
                      controller: alamatController,
                      decoration: InputDecoration(
                        labelText: "Alamat",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // Nomor Telepon
                    // =========================
                    TextField(
                      controller: teleponController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Nomor Telepon",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =========================
                    // Password
                    // =========================
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          register();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9DD79D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Register",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Back to Login
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "Sudah punya akun? Login",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
