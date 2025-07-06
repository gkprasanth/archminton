import 'package:flutter/material.dart';

class TermsAndConditionsScreen extends StatelessWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Terms and Conditions'),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms and Conditions',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Acceptance of Terms',
              'By accessing and using the Archminton mobile application and services, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            _buildSection(
              'Use License',
              'Permission is granted to temporarily download one copy of the Archminton application for personal, non-commercial transitory viewing only. This is the grant of a license, not a transfer of title, and under this license you may not:\n\n• modify or copy the materials\n• use the materials for any commercial purpose or for any public display\n• attempt to reverse engineer any software contained in the application\n• remove any copyright or other proprietary notations from the materials',
            ),
            _buildSection(
              'Booking and Payment Terms',
              'All bookings made through the Archminton platform are subject to availability and confirmation. Payment must be made in full at the time of booking. We accept various payment methods including credit/debit cards, UPI, and digital wallets through our secure payment gateway.\n\nBooking confirmations will be sent via email and SMS. It is your responsibility to ensure that your contact information is accurate and up to date.',
            ),
            _buildSection(
              'Cancellation and Refund Policy',
              'Cancellations must be made at least 24 hours before the scheduled booking time for a full refund. Cancellations made less than 24 hours before the booking time will incur a 50% cancellation fee. No-shows will result in forfeiture of the full booking amount.\n\nRefunds, where applicable, will be processed within 7-10 business days to the original payment method.',
            ),
            _buildSection(
              'User Responsibilities',
              'Users are responsible for:\n\n• Providing accurate personal information during registration\n• Maintaining the confidentiality of their account credentials\n• Following all venue rules and regulations\n• Reporting any issues or concerns promptly to our support team\n• Ensuring they are physically fit to participate in booked activities',
            ),
            _buildSection(
              'Liability Limitations',
              'Archminton acts as a platform connecting users with sports venues. While we strive to ensure the quality of our partner venues, we are not liable for any injuries, damages, or losses that may occur during the use of booked facilities. Users participate in sports activities at their own risk.',
            ),
            _buildSection(
              'Privacy and Data Protection',
              'We are committed to protecting your privacy and personal data. Please refer to our Privacy Policy for detailed information about how we collect, use, and protect your personal information.',
            ),
            _buildSection(
              'Modifications to Terms',
              'Archminton reserves the right to revise these terms at any time without notice. By using this application, you are agreeing to be bound by the current version of these terms and conditions.',
            ),
            _buildSection(
              'Contact Information',
              'For any questions regarding these terms and conditions, please contact us at:\n\nEmail: support@archminton.com\nPhone: +91 9876543210\nAddress: Archminton Sports Private Limited\n123 Sports Complex Road\nBangalore, Karnataka 560001',
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: const Text(
                'Last Updated: January 2025',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.green,
                  fontStyle: FontStyle.italic,
                ),
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