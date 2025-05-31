import 'package:archminton/main.dart';
import 'package:archminton/screens/profileoptions/FAQ.dart';
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
    return Container(
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
          const CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/herosection.jpg'),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Phone: $phone', style: const TextStyle(color: Colors.white70)),
                Text('Email: $email', style: const TextStyle(color: Colors.white70)),
                Text('Gender: $gender', style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
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
          ],
        ),
      ),
    );
  }
}
