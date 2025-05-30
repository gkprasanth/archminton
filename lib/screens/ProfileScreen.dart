import 'package:archminton/main.dart';
import 'package:archminton/screens/profileoptions/MyBookings.dart';
import 'package:archminton/screens/profileoptions/Support.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? 'N/A';
      email = prefs.getString('email') ?? 'N/A';
      phone = prefs.getString('phone') ?? 'N/A';
      gender = prefs.getString('gender') ?? 'N/A';
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    // Navigate to login or home after logout
    if (context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const MyApp()));
    }
  }

  Widget buildProfileOption(IconData icon, String title, VoidCallback onTap, {Color iconColor = Colors.deepPurple}) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text('Profile'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage('assets/images/herosection.jpg'),
                      backgroundColor: Colors.grey,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: $name', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Phone: $phone', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Gender: $gender', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          Text('Email: $email', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            buildProfileOption(Icons.calendar_today, 'My Bookings', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBookingsScreen()));
            }),
            buildProfileOption(Icons.card_membership, 'Memberships', () {
              // Navigate to memberships
            }),
            buildProfileOption(Icons.question_answer, 'FAQ', () {
              // Navigate to FAQ
            }),
            buildProfileOption(Icons.support_agent, 'Support', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
            }),
            buildProfileOption(Icons.info_outline, 'About', () {
              // Navigate to About
            }),
            buildProfileOption(Icons.logout, 'Logout', () async {
              await _logout();
            }, iconColor: Colors.red),
          ],
        ),
      ),
    );
  }
}
