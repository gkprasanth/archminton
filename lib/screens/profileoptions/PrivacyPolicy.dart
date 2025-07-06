import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Privacy Policy'),
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
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Introduction',
              'Archminton Sports Private Limited ("Archminton," the "Company," "we," "us," and "our,") respects your privacy and is committed to protecting it through our compliance with this privacy policy. This policy describes:\n\n• The types of information that we may collect from you when you access or use our mobile application and services\n• Our practices for collecting, using, maintaining, protecting and disclosing that information\n\nBy accessing or using our services, you agree to this privacy policy.',
            ),
            _buildSection(
              'Information We Collect',
              'We collect several types of information from and about users of our services, including:\n\n• Personal identification information (name, email address, phone number, date of birth)\n• Payment information (credit/debit card details, UPI IDs, wallet information)\n• Location data (to find nearby venues and provide relevant services)\n• Usage information (booking history, preferences, app usage patterns)\n• Device information (device type, operating system, unique device identifiers)\n• Photos and profile information (if you choose to provide them)',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use the information you provide to us to:\n\n• Process your bookings and payments\n• Communicate with you about your bookings and account\n• Provide customer support\n• Improve our services and user experience\n• Send you promotional offers and notifications (with your consent)\n• Comply with legal obligations\n• Prevent fraud and ensure security of our platform',
            ),
            _buildSection(
              'Information Sharing',
              'We may share your information with:\n\n• Sports venues and facilities for booking purposes\n• Payment processors for secure transaction processing\n• Service providers who assist us in operating our platform\n• Legal authorities when required by law or to protect our rights\n• Business partners with your explicit consent\n\nWe do not sell, trade, or otherwise transfer your personal information to third parties for their marketing purposes without your consent.',
            ),
            _buildSection(
              'Data Security',
              'We implement appropriate physical, electronic, and managerial procedures to safeguard and help prevent unauthorized access to your information. We use industry-standard encryption for payment processing and maintain secure servers for data storage.\n\nHowever, no method of transmission over the internet or method of electronic storage is 100% secure. We cannot guarantee absolute security.',
            ),
            _buildSection(
              'Your Rights',
              'You have the right to:\n\n• Access, update, or delete your personal information\n• Opt-out of promotional communications\n• Request a copy of your data\n• Withdraw consent for data processing\n• Request restriction of processing\n• Lodge a complaint with relevant authorities\n\nTo exercise these rights, please contact us at privacy@archminton.com.',
            ),
            _buildSection(
              'Data Retention',
              'We retain your personal information for as long as necessary to provide our services and comply with legal obligations. Account information is retained until you request deletion or as required by law. Payment information is retained according to regulatory requirements.',
            ),
            _buildSection(
              'Children\'s Privacy',
              'Our services are not intended for children under the age of 13. We do not knowingly collect personal information from children under 13. If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately.',
            ),
            _buildSection(
              'Changes to Privacy Policy',
              'We reserve the right to amend this privacy policy from time to time. We will notify you of any material changes by posting the new privacy policy on our application. Your continued use of our services after such changes constitutes acceptance of the updated policy.',
            ),
            _buildSection(
              'Contact Information',
              'If you have any questions about this privacy policy, please contact us at:\n\nEmail: privacy@archminton.com\nPhone: +91 9876543210\nAddress: Archminton Sports Private Limited\n123 Sports Complex Road\nBangalore, Karnataka 560001',
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