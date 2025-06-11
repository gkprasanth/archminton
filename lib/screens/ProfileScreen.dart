import 'package:archminton/main.dart';
import 'package:archminton/screens/profileoptions/FAQ.dart';
import 'package:archminton/screens/profileoptions/MyBookings.dart';
import 'package:archminton/screens/profileoptions/Support.dart';
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
    setState(() {
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
    });
    
    // Fetch society information from API
    await _fetchUserSociety();
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
    await prefs.remove('accessToken');
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MyApp()));
    }
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
              colors: [Colors.green.shade400, Colors.green.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
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
                    backgroundImage: profileImagePath.isNotEmpty
                        ? FileImage(File(profileImagePath)) as ImageProvider
                        : const AssetImage('assets/images/herosection.jpg'),
                  ),
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
                    Text('Phone: $phone', style: const TextStyle(color: Colors.white70)),
                    Text('Address: $address', style: const TextStyle(color: Colors.white70)),
                    Text('Gender: $gender', style: const TextStyle(color: Colors.white70)),
                    Text('Society: $society', style: const TextStyle(color: Colors.white70)), // Display society
                  ],
                ),
              ),
            ],
          ),
        ),
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
                          : const AssetImage('assets/images/herosection.jpg'),
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
            buildProfileOption(Icons.calendar_today_rounded, 'My Bookings', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen()));
            }),
            buildProfileOption(Icons.card_membership_rounded, 'Memberships', () {
              // TODO: Navigate to memberships
            }),
            buildProfileOption(Icons.question_answer_rounded, 'FAQ', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FAQScreen()));
            }),
            buildProfileOption(Icons.support_agent_rounded, 'Support', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
            }),
            buildProfileOption(Icons.info_outline_rounded, 'About', () {
              // TODO: Navigate to About
            }),
            buildProfileOption(Icons.logout, 'Logout', () async {
              await _logout();
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
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
            const SizedBox(height: 80), // Add bottom padding for nav bar
          ],
        ),
      ),
    );
  }
}
