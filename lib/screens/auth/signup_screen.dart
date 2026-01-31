import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/auth_service.dart';

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
  final _confirmPassword = TextEditingController();

  // ✅ Focus nodes (to detect "field completed")
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;

  // ✅ Track which fields have been "touched" (completed once)
  bool _touchedName = false;
  bool _touchedEmail = false;
  bool _touchedPassword = false;
  bool _touchedConfirm = false;

  @override
  void initState() {
    super.initState();

    // When a field loses focus => mark touched => validate only that field visually
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) {
        setState(() => _touchedName = true);
      }
    });

    _emailFocus.addListener(() {
      if (!_emailFocus.hasFocus) {
        setState(() => _touchedEmail = true);
      }
    });

    _passwordFocus.addListener(() {
      if (!_passwordFocus.hasFocus) {
        setState(() {
          _touchedPassword = true;
          // If password changes, confirm should re-check after leaving confirm field
        });
      }
    });

    _confirmFocus.addListener(() {
      if (!_confirmFocus.hasFocus) {
        setState(() => _touchedConfirm = true);
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();

    _nameFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();

    super.dispose();
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r"^[\w\.\-]+@([\w\-]+\.)+[\w]{2,}$");
    return regex.hasMatch(email.trim());
  }

  String? _validateName(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Name required";
    return null;
  }

  String? _validateEmail(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Email required";
    if (!_isValidEmail(value)) return "Please provide a correct email";
    return null;
  }

  String? _validatePassword(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Password required";
    if (value.length < 6) return "Min 6 characters";
    return null;
  }

  String? _validateConfirm(String? v) {
    final value = (v ?? "").trim();
    if (value.isEmpty) return "Confirm password required";
    if (value != _password.text.trim()) return "Password is not matching";
    return null;
  }

  Future<void> _signup() async {
    // ✅ On button click, show errors for all fields
    setState(() {
      _touchedName = true;
      _touchedEmail = true;
      _touchedPassword = true;
      _touchedConfirm = true;
    });

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fix the highlighted fields."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      await context.read<AuthService>().signUpWithEmail(
        email: _email.text.trim(),
        password: _password.text.trim(),
        name: _name.text.trim(),
      );

      if (!mounted) return;

      Navigator.of(context).pop(); // ✅ AuthGate shows Home automatically
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String msg;
      switch (e.code) {
        case 'invalid-email':
          msg = "Please provide a correct email address.";
          break;

        case 'email-already-in-use':
        case 'account-exists-with-different-credential':
          msg = "This email is already registered.";
          break;

        case 'weak-password':
          msg = "Password is too weak. Use at least 6 characters.";
          break;

        default:
          msg = "Signup failed. Please try again.";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Signup failed. Please try again."),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
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
          autovalidateMode: AutovalidateMode.disabled, // ✅ no typing validation
          child: Column(
            children: [
              // NAME
              TextFormField(
                controller: _name,
                focusNode: _nameFocus,
                decoration: const InputDecoration(
                  labelText: "Name",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  setState(() => _touchedName = true);
                  FocusScope.of(context).requestFocus(_emailFocus);
                },
                validator: (v) => _touchedName ? _validateName(v) : null,
              ),
              const SizedBox(height: 12),

              // EMAIL
              TextFormField(
                controller: _email,
                focusNode: _emailFocus,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  setState(() => _touchedEmail = true);
                  FocusScope.of(context).requestFocus(_passwordFocus);
                },
                validator: (v) => _touchedEmail ? _validateEmail(v) : null,
              ),
              const SizedBox(height: 12),

              // PASSWORD
              TextFormField(
                controller: _password,
                focusNode: _passwordFocus,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                textInputAction: TextInputAction.next,
                onEditingComplete: () {
                  setState(() => _touchedPassword = true);
                  FocusScope.of(context).requestFocus(_confirmFocus);
                },
                validator: (v) => _touchedPassword ? _validatePassword(v) : null,
              ),
              const SizedBox(height: 12),

              // CONFIRM PASSWORD
              TextFormField(
                controller: _confirmPassword,
                focusNode: _confirmFocus,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: "Confirm Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirm
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  setState(() => _touchedConfirm = true);
                  FocusScope.of(context).unfocus();
                },
                validator: (v) => _touchedConfirm ? _validateConfirm(v) : null,
              ),

              const SizedBox(height: 16),

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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
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
