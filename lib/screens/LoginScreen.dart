import 'dart:convert';
import 'dart:io';

import 'package:archminton/constants/constants.dart';
import 'package:archminton/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:archminton/main.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'ForgotPasswordScreen.dart';

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
  bool _isGoogleLoading = false;
  // bool _isAppleLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

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
      // Test connectivity first
      print('🔐 Starting login process...');
      print('   - Email: $email');
      
      final workingEndpoint = await ApiService.testConnectivity();
      if (workingEndpoint == null) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      }
      
      final url = Uri.parse('$workingEndpoint/auth/login');
      print('   - Using endpoint: $url');

      // Create HTTP client with timeout and better error handling
      final client = http.Client();
      
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout - please check your internet connection and try again');
        },
      );

      print('📡 Login API Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Login successful, processing response data...');
        
        final user = data['data']['user'];
        final accessToken = data['data']['accessToken'];
        final refreshToken = data['data']['refreshToken'];
        
        print('👤 User data received:');
        print('   - User: $user');
        print('   - Access Token: ${accessToken != null ? "Present (${accessToken.length} chars)" : "NULL"}');
        print('   - Refresh Token: ${refreshToken != null ? "Present (${refreshToken.length} chars)" : "NULL"}');
        
        await _saveUserData(user, accessToken, refreshToken);

        print('🏠 Navigating to home screen...');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        print('❌ Login failed with status ${response.statusCode}');
        String errorMessage =
            data['error'] ?? data['message'] ?? "Login failed";
        print('   - Error message: $errorMessage');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(errorMessage)));
      }
    } on http.ClientException catch (e) {
      print('💥 Network/Client Exception during login:');
      print('   - Error: $e');
      String userMessage = "Network error: Unable to connect to server. Please check your internet connection.";
      if (e.message.contains('Failed host lookup')) {
        userMessage = "Cannot reach server. Please check your internet connection or try again later.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage)),
      );
    } catch (e, stackTrace) {
      print('💥 Exception during login:');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Something went wrong: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserData(dynamic user, String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('accessToken', accessToken);
    await prefs.setString('refreshToken', refreshToken);
    await prefs.setString('userId', user['id'].toString());
    await prefs.setString('email', user['email']);
    await prefs.setString('name', user['name']);
    await prefs.setString('phone', user['phone'] ?? '');
    await prefs.setString('gender', user['gender'] ?? '');

    print('💾 Data saved to SharedPreferences:');
    print('   - accessToken: ${await prefs.getString('accessToken') != null ? "Saved" : "FAILED"}');
    print('   - refreshToken: ${await prefs.getString('refreshToken') != null ? "Saved" : "FAILED"}');
    print('   - userId: ${await prefs.getString('userId')}');
    print('   - email: ${await prefs.getString('email')}');
    print('   - name: ${await prefs.getString('name')}');
    print('   - phone: ${await prefs.getString('phone')}');
    print('   - gender: ${await prefs.getString('gender')}');
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);

    try {
      print('🔐 Starting Firebase Google Sign-In process...');
      
      // Sign out first to ensure fresh login
      await _googleSignIn.signOut();
      await _auth.signOut();
      
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Google Sign-In was cancelled by user');
        return;
      }

      print('✅ Google Sign-In successful for: ${googleUser.email}');
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      print('🔑 Creating Firebase credential...');
      
      // Create Firebase credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw Exception('Firebase authentication failed');
      }

      print('✅ Firebase authentication successful for: ${firebaseUser.email}');
      
      // Get Firebase ID token
      final String? firebaseIdToken = await firebaseUser.getIdToken();
      
      if (firebaseIdToken == null) {
        throw Exception('Failed to get Firebase ID token');
      }

      print('🔑 Firebase ID token received, sending to backend...');
      
      // Test connectivity first
      final workingEndpoint = await ApiService.testConnectivity();
      if (workingEndpoint == null) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      }
      
      final url = Uri.parse('$workingEndpoint/auth/firebase');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'idToken': firebaseIdToken,
          'email': firebaseUser.email,
          'name': firebaseUser.displayName,
          'photoURL': firebaseUser.photoURL,
        }),
      ).timeout(const Duration(seconds: 30));

      print('📡 Firebase Auth API Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Firebase authentication successful');
        
        final user = data['data']['user'];
        final accessToken = data['data']['accessToken'];
        final refreshToken = data['data']['refreshToken'];
        
        await _saveUserData(user, accessToken, refreshToken);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const BottomNavBar()),
        );
      } else {
        String errorMessage = data['error'] ?? data['message'] ?? "Firebase Sign-In failed";
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e, stackTrace) {
      print('💥 Exception during Firebase Google Sign-In:');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Firebase Google Sign-In failed: $e")),
      );
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  // Future<void> _signInWithApple() async {
  //   // Only show Apple Sign-In on iOS
  //   if (!Platform.isIOS) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Apple Sign-In is only available on iOS devices")),
  //     );
  //     return;
  //   }

  //   setState(() => _isAppleLoading = true);

  //   try {
  //     print('🍎 Starting Apple Sign-In process...');
      
  //     final credential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );

  //     print('✅ Apple Sign-In successful');
      
  //     // Test connectivity first
  //     final workingEndpoint = await ApiService.testConnectivity();
  //     if (workingEndpoint == null) {
  //       throw Exception('Cannot connect to server. Please check your internet connection.');
  //     }
      
  //     final url = Uri.parse('$workingEndpoint/auth/apple');
      
  //     final response = await http.post(
  //       url,
  //       headers: {'Content-Type': 'application/json'},
  //       body: jsonEncode({
  //         'identityToken': credential.identityToken,
  //         'authorizationCode': credential.authorizationCode,
  //         'userIdentifier': credential.userIdentifier,
  //         'email': credential.email,
  //         'givenName': credential.givenName,
  //         'familyName': credential.familyName,
  //       }),
  //     ).timeout(const Duration(seconds: 30));

  //     print('📡 Apple Auth API Response:');
  //     print('   - Status Code: ${response.statusCode}');
  //     print('   - Response Body: ${response.body}');

  //     final data = jsonDecode(response.body);

  //     if (response.statusCode == 200) {
  //       print('✅ Apple authentication successful');
        
  //       final user = data['data']['user'];
  //       final accessToken = data['data']['accessToken'];
  //       final refreshToken = data['data']['refreshToken'];
        
  //       await _saveUserData(user, accessToken, refreshToken);

  //       Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(builder: (context) => const BottomNavBar()),
  //       );
  //     } else {
  //       String errorMessage = data['error'] ?? data['message'] ?? "Apple Sign-In failed";
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text(errorMessage)),
  //       );
  //     }
  //   } catch (e, stackTrace) {
  //     print('💥 Exception during Apple Sign-In:');
  //     print('   - Error: $e');
  //     print('   - Stack trace: $stackTrace');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Apple Sign-In failed: $e")),
  //     );
  //   } finally {
  //     setState(() => _isAppleLoading = false);
  //   }
  // }

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
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ForgotPasswordScreen(),
                ),
              );
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Colors.green,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 20),
          // Google Sign-In Button
          _isGoogleLoading
              ? const CircularProgressIndicator()
              : _buildSocialButton(
                  "Continue with Google",
                  Icons.g_mobiledata,
                  Colors.red,
                  _signInWithGoogle,
                ),
          const SizedBox(height: 12),
          // Apple Sign-In Button (iOS only) - COMMENTED OUT
          // if (Platform.isIOS)
          //   _isAppleLoading
          //       ? const CircularProgressIndicator()
          //       : _buildSocialButton(
          //           "Continue with Apple",
          //           Icons.apple,
          //           Colors.black,
          //           _signInWithApple,
          //         ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(
          text,
          style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w500),
        ),
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
