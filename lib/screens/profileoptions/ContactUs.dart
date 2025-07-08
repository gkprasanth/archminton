import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Contact Us'),
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
              'Get in Touch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'We\'re here to help! Contact us through any of the following channels:',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 30),
                         _buildContactCard(
               icon: Icons.phone,
               title: 'Phone Support',
               subtitle: 'Call us for immediate assistance',
               details: '+91 8008871828 / +91 8008814466',
               onTap: () => _makePhoneCall('+918008871828'),
             ),
                         _buildContactCard(
               icon: Icons.email,
               title: 'Email Support',
               subtitle: 'Send us your queries and feedback',
               details: 'support@archminton.in / archmintonsports@gmail.com',
               onTap: () => _sendEmail('support@archminton.in'),
             ),
                         _buildContactCard(
               icon: Icons.location_on,
               title: 'Office Address',
               subtitle: 'Visit our office for in-person support',
               details: 'Archminton Sports Pvt Ltd\n2-57/1/1083, S.A.Society Behind Meridian School\nSiddhi Vinayak Nagar, Madhapur, HITEC City\nHyderabad, Telangana 500081\nIndia',
               onTap: () => _openMap(),
             ),
            _buildContactCard(
              icon: Icons.access_time,
              title: 'Support Hours',
              subtitle: 'When you can reach us',
              details: 'Monday - Sunday: 6:00 AM - 10:00 PM\nEmergency Support: 24/7',
              onTap: null,
            ),
            _buildContactCard(
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle: 'Get instant help through in-app chat',
              details: 'Available 24/7 within the app',
              onTap: () => _openLiveChat(context),
            ),
                         _buildContactCard(
               icon: Icons.bug_report,
               title: 'Report Issues',
               subtitle: 'Report bugs or technical problems',
               details: 'support@archminton.in',
               onTap: () => _sendEmail('support@archminton.in'),
             ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'For immediate assistance with bookings, payments, or venue access, please use the in-app support chat or call our emergency helpline.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                                             Expanded(
                         child: ElevatedButton.icon(
                           onPressed: () => _makePhoneCall('+918008814466'),
                           icon: const Icon(Icons.phone, size: 18),
                           label: const Text('Emergency Call'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openLiveChat(context),
                          icon: const Icon(Icons.chat, size: 18),
                          label: const Text('Live Chat'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
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
              child: const Text(
                'Follow us on social media for updates and offers!\n\nFacebook: @ArchmintonSports\nTwitter: @ArchmintonApp\nInstagram: @archminton_official',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String details,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.green.shade600,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        details,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.green.shade600,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _openMap() async {
    const String address = 'Archminton Sports Pvt Ltd, 2-57/1/1083, S.A.Society Behind Meridian School, Siddhi Vinayak Nagar, Madhapur, HITEC City, Hyderabad, Telangana 500081, India';
    final Uri mapUri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(address)}');
    if (await canLaunchUrl(mapUri)) {
      await launchUrl(mapUri);
    }
  }

  void _openLiveChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text('Live chat feature will be available soon! For immediate assistance, please call our support number or send us an email.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
} 