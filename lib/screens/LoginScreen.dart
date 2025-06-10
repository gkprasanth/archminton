import 'dart:convert';

import 'package:archminton/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:archminton/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

final String baseUrl = AppConstants.baseUrl;

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 100),
              // Logo at the top
              Center(
                child: Column(
                  children: [
                    Image.asset('assets/logo.png', height: 100),
                    const SizedBox(height: 10),
                    const Text(
                      'Welcome to Archminton',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              const TabBar(
                labelColor: Colors.green,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.green,
                dividerColor: Colors.transparent,
                tabs: [Tab(text: "Login"), Tab(text: "Sign Up")],
              ),
              const Expanded(
                child: TabBarView(children: [LoginTab(), SignUpTab()]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginTab extends StatefulWidget {
  const LoginTab({super.key});

  @override
  State<LoginTab> createState() => _LoginTabState();
}

class _LoginTabState extends State<LoginTab> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Input fields should not be empty")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final user = data['data']['user'];
        final accessToken = data['data']['accessToken'];
        final refreshToken = data['data']['refreshToken'];
        // final phoneNumber = data['data']['user'];
        final prefs = await SharedPreferences.getInstance();

        await prefs.setString('accessToken', accessToken);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setString('userId', user['id'].toString());
        await prefs.setString('email', user['email']);
        await prefs.setString('name', user['name']);
        await prefs.setString('phone', user['phone'] ?? '');
        await prefs.setString('gender', user['gender'] ?? '');

        // await prefs.setString('phone', user['phone']);
        // await prefs.setString('gender', user['gender'] ?? '');
        // await prefs.setString('role', user['role'] ?? '');

        // Optional: Show success message
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text(data['message'] ?? "Login successful")),
        // );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        String errorMessage =
            data['error'] ?? data['message'] ?? "Login failed";
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildTextField(_emailController, "Email", Icons.email),
          const SizedBox(height: 20),
          _buildTextField(
            _passwordController,
            "Password",
            Icons.lock,
            isPassword: true,
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : _buildButton("Login", _login),
        ],
      ),
    );
  }
}

class SignUpTab extends StatefulWidget {
  const SignUpTab({super.key});

  @override
  State<SignUpTab> createState() => _SignUpTabState();
}

class _SignUpTabState extends State<SignUpTab> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  void _signUp() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (email.isEmpty ||
        name.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must fill all the input fields")),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    final passwordRegex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d).{8,}$');
    final phoneRegex = RegExp(r'^[\d+\-\s()]{7,15}$');

    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a valid email address")),
      );
      return;
    }

    if (!passwordRegex.hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Password must be at least 8 characters long, contain one letter and one number",
          ),
        ),
      );
      return;
    }

    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Name must be at least 2 characters long"),
        ),
      );
      return;
    }

    if (!phoneRegex.hasMatch(phone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a valid phone number")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse('$baseUrl/auth/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": email,
          "name": name,
          "phone": phone,
          "password": password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? "Account created! Please login."),
          ),
        );

        _emailController.clear();
        _nameController.clear();
        _phoneController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();

        DefaultTabController.of(context).animateTo(0);
      } else {
        String errorMessage = "Signup failed";
        if (data['error'] != null) {
          errorMessage = data['error'];
        } else if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['errors'] != null) {
          errorMessage = data['errors'].toString();
        }

        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildTextField(_emailController, "Email", Icons.email),
          const SizedBox(height: 20),
          _buildTextField(_nameController, "Name", Icons.person),
          const SizedBox(height: 20),
          _buildTextField(_phoneController, "Phone", Icons.phone),
          const SizedBox(height: 20),
          _buildTextField(
            _passwordController,
            "Password",
            Icons.lock,
            isPassword: true,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            _confirmPasswordController,
            "Confirm Password",
            Icons.lock_outline,
            isPassword: true,
          ),
          const SizedBox(height: 30),
          _isLoading
              ? const CircularProgressIndicator()
              : _buildButton("Sign Up", _signUp),
        ],
      ),
    );
  }
}

// Reusable styled text field
Widget _buildTextField(
  TextEditingController controller,
  String label,
  IconData icon, {
  bool isPassword = false,
}) {
  return TextField(
    controller: controller,
    obscureText: isPassword,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      filled: true,
      fillColor: Colors.grey[100],
    ),
  );
}

// Reusable gradient button
Widget _buildButton(String text, VoidCallback onPressed) {
  return SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    ),
  );
}
