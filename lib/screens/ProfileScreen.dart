import 'package:archminton/main.dart';
import 'package:archminton/screens/LoginScreen.dart';
import 'package:archminton/screens/profileoptions/FAQ.dart';
import 'package:archminton/screens/profileoptions/MyBookings.dart';
import 'package:archminton/screens/profileoptions/Memberships.dart';
import 'package:archminton/screens/profileoptions/Support.dart';
import 'package:archminton/screens/profileoptions/TermsAndConditions.dart';
import 'package:archminton/screens/profileoptions/PrivacyPolicy.dart';
import 'package:archminton/screens/profileoptions/ShippingPolicy.dart';
import 'package:archminton/screens/profileoptions/ContactUs.dart';
import 'package:archminton/screens/profileoptions/CancellationAndRefunds.dart';
import 'package:archminton/screens/profileoptions/About.dart';
import 'package:archminton/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:archminton/constants/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '';
  String email = '';
  String phone = '';
  String gender = '';
  String address = '';
  String society = ''; // New property for society
  String profileImagePath = ''; // Profile image path
  bool isLoggedIn = false; // Track login status
  
  // Text controllers for editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _societyController = TextEditingController(); // Controller for society

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Set context for ApiService to enable automatic logout
    ApiService.setContext(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _genderController.dispose();
    _societyController.dispose(); // Dispose society controller
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');
    
    setState(() {
      isLoggedIn = token != null && token.isNotEmpty;
      
      if (isLoggedIn) {
        name = prefs.getString('name') ?? 'N/A';
        email = prefs.getString('email') ?? 'N/A';
        phone = prefs.getString('phone') ?? 'N/A';
        gender = prefs.getString('gender') ?? 'N/A';
        if (gender.trim().isEmpty) {
          gender = 'N/A';
        }
        address = prefs.getString('address') ?? 'N/A';
        society = prefs.getString('society') ?? 'N/A'; // Load society
        profileImagePath = prefs.getString('profileImagePath') ?? ''; // Load profile image path
      } else {
        // Guest user defaults
        name = 'Guest User';
        email = 'Not signed in';
        phone = 'N/A';
        gender = 'N/A';
        address = 'N/A';
        society = 'N/A';
        profileImagePath = '';
      }
    });
    
    // Fetch society information from API only if logged in
    if (isLoggedIn) {
      await _fetchUserSociety();
    }
  }
  
  Future<void> _fetchUserSociety() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      
      if (token == null) return; // Not logged in
      
      final url = Uri.parse('${AppConstants.baseUrl}/users/societies');
      
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data != null && data.containsKey('society')) {
          setState(() {
            society = data['society'] ?? 'N/A';
          });
          
          // Save society to shared preferences
          await prefs.setString('society', society);
        }
      } else {
        // Handle error - keep existing society value from SharedPreferences
        print('Failed to fetch society: ${response.statusCode}');
      }
    } catch (e) {
      // Handle error
      print('Error fetching society: $e');
    }
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('phone', phone);
    await prefs.setString('address', address);
    await prefs.setString('gender', gender);
    await prefs.setString('society', society); // Save society
    if (profileImagePath.isNotEmpty) {
      await prefs.setString('profileImagePath', profileImagePath); // Save profile image path
    }
    setState(() {}); // Refresh UI
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Clear all user-related data from SharedPreferences
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove('userId');
    await prefs.remove('email');
    await prefs.remove('name');
    await prefs.remove('phone');
    await prefs.remove('gender');
    await prefs.remove('user');
    
    print('🚪 User logged out - all data cleared');
    
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
    }
  }

  Future<void> _deleteAccount() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Account'),
          content: const Text(
            'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data, bookings, and account information.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Deleting account...'),
              ],
            ),
          );
        },
      );

      try {
        // Call the API service
        final result = await ApiService.deleteUserAccount();

        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        if (result['success']) {
          // Clear all user data
          final prefs = await SharedPreferences.getInstance();
          await prefs.clear();
          
          if (context.mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account deleted successfully'),
                backgroundColor: Colors.green,
              ),
            );
            
            // Navigate to home screen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          }
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to delete account: ${result['error'] ?? 'Unknown error'}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        // Close loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error deleting account: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showLoginRequiredDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.login, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              const Text(
                'Sign In Required',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'You need to sign in to $feature. Would you like to sign in now?',
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Later',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Sign In',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildProfileOption(IconData icon, String title, VoidCallback onTap, {Color iconColor = Colors.green}) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: iconColor, size: 26),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget buildIDCard() {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoggedIn 
                ? [Colors.green.shade400, Colors.green.shade600]
                : [Colors.grey.shade400, Colors.grey.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: (isLoggedIn ? Colors.green : Colors.grey).withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: (isLoggedIn && profileImagePath.isNotEmpty)
                        ? FileImage(File(profileImagePath)) as ImageProvider
                        : const AssetImage('assets/images/profile.png'),
                  ),
                  // Only show camera icon for logged-in users
                  if (isLoggedIn)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.green.shade600, size: 16),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    if (isLoggedIn) ...[
                      Text('Phone: $phone', style: const TextStyle(color: Colors.white70)),
                      Text('Address: $address', style: const TextStyle(color: Colors.white70)),
                      Text('Gender: $gender', style: const TextStyle(color: Colors.white70)),
                      Text('Society: $society', style: const TextStyle(color: Colors.white70)),
                    ] else ...[
                      const Text('Sign in to view your details', style: TextStyle(color: Colors.white70)),
                      const Text('Browse venues and sports', style: TextStyle(color: Colors.white70)),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        // Only show edit button for logged-in users
        if (isLoggedIn)
          Positioned(
            top: 10,
            right: 10,
            child: IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                await _showEditProfileDialog();
              },
            ),
          ),
      ],
    );
  }

  Future<void> _showEditProfileDialog() async {
    _nameController.text = name;
    _phoneController.text = phone;
    _addressController.text = address;
    _genderController.text = gender;
    _societyController.text = society; // Set society controller

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () async {
                  Navigator.pop(context);
                  await _pickImage();
                  if (context.mounted) {
                    _showEditProfileDialog(); // Reopen dialog after image pick
                  }
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: profileImagePath.isNotEmpty
                          ? FileImage(File(profileImagePath)) as ImageProvider
                          : const AssetImage('assets/images/profile.png'),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.green, width: 2),
                      ),
                      child: Icon(Icons.camera_alt, color: Colors.green.shade600, size: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              TextField(
                controller: _genderController,
                decoration: const InputDecoration(labelText: 'Gender'),
              ),
              TextField(
                controller: _societyController,
                decoration: const InputDecoration(labelText: 'Society'), // New field for society
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              name = _nameController.text;
              phone = _phoneController.text;
              address = _addressController.text;
              gender = _genderController.text;
              society = _societyController.text; // Get society from controller
              await _saveUserData();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          profileImagePath = image.path;
        });
        await _saveUserData();
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('My Profile'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            buildIDCard(),
            const SizedBox(height: 30),
            
            // Show sign-in button for guest users
            if (!isLoggedIn) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade600, size: 24),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to access your bookings, memberships, and personalized features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login),
                      label: const Text('Sign In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
            
            // User-specific options (only show for logged-in users or modify behavior for guests)
            if (isLoggedIn) ...[
              buildProfileOption(Icons.calendar_today_rounded, 'My Bookings', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen()));
              }),
              buildProfileOption(Icons.card_membership_rounded, 'Memberships', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MembershipsScreen()));
              }),
            ] else ...[
              buildProfileOption(Icons.calendar_today_rounded, 'My Bookings', () {
                _showLoginRequiredDialog('view your bookings');
              }),
              buildProfileOption(Icons.card_membership_rounded, 'Memberships', () {
                _showLoginRequiredDialog('view your memberships');
              }),
            ],
            
            // Common options available to all users
            buildProfileOption(Icons.question_answer_rounded, 'FAQ', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQScreen()));
            }),
            buildProfileOption(Icons.support_agent_rounded, 'Support', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
            }),
            buildProfileOption(Icons.description_outlined, 'Terms & Conditions', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const TermsAndConditionsScreen()));
            }),
            buildProfileOption(Icons.privacy_tip_outlined, 'Privacy Policy', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PrivacyPolicyScreen()));
            }),
            buildProfileOption(Icons.local_shipping_outlined, 'Service Delivery', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ShippingPolicyScreen()));
            }),
            buildProfileOption(Icons.contact_phone_outlined, 'Contact Us', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ContactUsScreen()));
            }),
            buildProfileOption(Icons.cancel_outlined, 'Cancellation & Refunds', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CancellationAndRefundsScreen()));
            }),
            buildProfileOption(Icons.info_outline_rounded, 'About', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutScreen()));
            }),
            
            // Show logout only for logged-in users
            if (isLoggedIn) ...[
              buildProfileOption(Icons.logout, 'Logout', () async {
                await _logout();
              }, iconColor: Colors.red),
              buildProfileOption(Icons.delete_forever, 'Delete My Account', () async {
                await _deleteAccount();
              }, iconColor: Colors.red),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () async {
                  await _showEditProfileDialog();
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
