import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('About Archminton'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Logo and Name
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.sports_tennis,
                      size: 60,
                      color: Colors.green.shade600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Archminton',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your Sports Booking Companion',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            _buildSection(
              'About Us',
              'Archminton Sports Pvt Ltd is a leading sports booking platform that connects sports enthusiasts with premium venues across India. We make it easy to find, book, and play at the best sports facilities in your area.',
            ),
            _buildSection(
              'Our Mission',
              'To make sports accessible to everyone by providing a seamless booking experience that connects players with quality venues. We believe that sports should be convenient, affordable, and available to all.',
            ),
            _buildSection(
              'What We Offer',
              '• Badminton court bookings\n• Multi-sport venue access\n• Equipment rentals\n• Coaching services\n• Tournament organization\n• Group bookings\n• Membership plans\n• Real-time availability',
            ),
            _buildSection(
              'Why Choose Archminton',
              '• Verified venues with quality assurance\n• Instant booking confirmation\n• Secure payment processing\n• 24/7 customer support\n• Competitive pricing\n• Easy cancellation policy\n• User-friendly mobile app\n• Regular offers and discounts',
            ),
            _buildSection(
              'Our Values',
              'Quality: We partner only with the best venues\nTransparency: No hidden fees or charges\nCommunity: Building a strong sports community\nInnovation: Constantly improving our services\nSupport: Always here when you need us',
            ),
            _buildSection(
              'Company Information',
              'Archminton Sports Pvt Ltd\nFounded: 2020\nHeadquarters: Hyderabad, Telangana\nServing: Major cities across India\nActive Users: 10,000+\nPartner Venues: 500+',
            ),
            _buildSection(
              'Contact Information',
              'Email: support@archminton.in / archmintonsports@gmail.com\nPhone: +91 8008871828 / +91 8008814466\nAddress: 2-57/1/1083, S.A.Society Behind Meridian School\nSiddhi Vinayak Nagar, Madhapur, HITEC City\nHyderabad, Telangana 500081\nIndia',
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Join Our Community',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Be part of a growing community of sports enthusiasts. Share your experiences, connect with fellow players, and stay updated with the latest sports events and offers.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'App Version: 1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Last Updated: January 2025\nBuild: 1.0.0+4',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
