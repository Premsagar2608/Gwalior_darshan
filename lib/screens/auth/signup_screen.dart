import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';
import '../../services/user_profile_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  // ✅ NEW
  final _location = TextEditingController();
  String _userType = "Traveller"; // or "Local"

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1) Create Auth user
      await context.read<AuthService>().signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text.trim(),
        name: _name.text.trim(),
      );

      // 2) Get current user uid
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw "User not found after signup";

      // 3) Save profile to Firestore (ONE TIME)
      await UserProfileService().createUserProfile(
        uid: user.uid,
        name: _name.text.trim(),
        email: _email.text.trim(),
        location: _location.text.trim(),
        userType: _userType,
      );

      // Done - go back (AuthGate will show Home automatically)
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup failed: $e")),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color(0xFF1746A2);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // NAME
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if ((v ?? "").trim().isEmpty) return "Name required";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // EMAIL
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  final value = (v ?? "").trim();
                  if (value.isEmpty) return "Email required";
                  if (!value.contains("@")) return "Enter valid email";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // PASSWORD
              TextFormField(
                controller: _password,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                validator: (v) {
                  final value = (v ?? "").trim();
                  if (value.isEmpty) return "Password required";
                  if (value.length < 6) return "Min 6 characters";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ✅ LOCATION
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: "Your Location (City)",
                  hintText: "e.g. Gwalior, Indore, Delhi",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) {
                  if ((v ?? "").trim().isEmpty) return "Location required";
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ✅ Local/Traveller
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "You are",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Local"),
                            selected: _userType == "Local",
                            onSelected: (_) => setState(() => _userType = "Local"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ChoiceChip(
                            label: const Text("Traveller"),
                            selected: _userType == "Traveller",
                            onSelected: (_) => setState(() => _userType = "Traveller"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text("Create Account"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
