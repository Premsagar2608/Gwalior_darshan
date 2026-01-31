import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await context.read<AuthService>().signInWithEmail(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      // ✅ AuthGate will automatically move to HomeScreen
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String msg;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential': // ✅ newer Firebase mostly returns this
          msg = "Wrong password! Kindly provide correct details.";
          break;

        case 'user-not-found':
          msg = "No account found with this email. Please sign up first.";
          break;

        case 'invalid-email':
          msg = "Invalid email format. Please enter a valid email.";
          break;

        case 'user-disabled':
          msg = "This account has been disabled. Contact support.";
          break;

        case 'too-many-requests':
          msg = "Too many attempts. Please try again after some time.";
          break;

        default:
          msg = "Login failed. Please check your details and try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login failed. Please try again.")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        /// BEAUTIFUL COLORFUL BACKGROUND
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1746A2),
              Color(0xFF4FC3F7),
              Color(0xFFFFA600),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),

        child: Stack(
          children: [
            /// BACKGROUND ICONS (AUTO, BUS, AIRPLANE, FORT)
            Positioned(top: 40, left: 20, child: _bgIcon(Icons.directions_bus)),
            Positioned(top: 120, right: 20, child: _bgIcon(Icons.flight)),
            Positioned(bottom: 150, left: 30, child: _bgIcon(Icons.auto_awesome)),
            Positioned(bottom: 80, right: 10, child: _bgIcon(Icons.location_city)),
            Positioned(top: 250, right: 120, child: _bgIcon(Icons.train)),

            /// MAIN LOGIN CARD
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 3,
                      )
                    ],
                  ),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Welcome Back 👋",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1746A2),
                          ),
                        ),

                        const SizedBox(height: 15),

                        /// Email
                        TextFormField(
                          controller: _email,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            final value = (v ?? "").trim();
                            if (value.isEmpty) return "Enter email";
                            if (!value.contains("@")) return "Invalid email";
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        /// Password
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            border: const OutlineInputBorder(),
                            suffixIcon: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility
                                  : Icons.visibility_off),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          validator: (v) {
                            final value = (v ?? "").trim();
                            if (value.isEmpty) return "Enter password";
                            if (value.length < 6) return "Min 6 characters";
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        /// LOGIN BUTTON
                        ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1746A2),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 60, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            foregroundColor: Colors.white,
                          ),
                          child: _loading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                              : const Text(
                            "Login",
                            style: TextStyle(fontSize: 17),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// SIGNUP NAVIGATION
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Don't have an account? "),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const SignupScreen()),
                                );
                              },
                              child: const Text("Create Account"),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// BACKGROUND ICON STYLE
  Widget _bgIcon(IconData icon) {
    return Icon(
      icon,
      size: 60,
      color: Colors.white.withOpacity(0.15),
    );
  }
}
