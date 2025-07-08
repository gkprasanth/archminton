import 'package:flutter/material.dart';

class ShippingPolicyScreen extends StatelessWidget {
  const ShippingPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Service Delivery Policy'),
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
              'Service Delivery Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Service Overview',
              'Archminton provides a platform for booking sports facilities and courts. As a digital service platform, we do not ship physical products but deliver digital services including booking confirmations, access codes, and related communications.',
            ),
            _buildSection(
              'Booking Confirmation Delivery',
              'Upon successful booking and payment:\n\n• Instant booking confirmation via in-app notification\n• Email confirmation sent within 2 minutes\n• SMS confirmation sent within 5 minutes\n• Booking details accessible immediately in your account\n\nAll confirmations include booking ID, venue details, timing, and access instructions.',
            ),
            _buildSection(
              'Digital Access Delivery',
              'For venues that require digital access:\n\n• Access codes delivered via SMS 30 minutes before booking time\n• QR codes available in the app 1 hour before booking\n• Special instructions sent via email 24 hours before booking\n• Emergency contact numbers provided for immediate assistance',
            ),
            _buildSection(
              'Notification Delivery',
              'We deliver various notifications to ensure smooth service:\n\n• Booking reminders 24 hours before your slot\n• Weather alerts for outdoor bookings\n• Venue-specific announcements\n• Payment receipts and invoices\n• Membership and offer notifications',
            ),
            _buildSection(
              'Service Delivery Timeline',
              'Immediate Services:\n• Booking confirmations\n• Payment receipts\n• Account access\n\nScheduled Services:\n• Reminder notifications (24 hours before)\n• Access codes (30 minutes before)\n• Weather alerts (as needed)\n\nPost-Service:\n• Feedback requests (within 2 hours)\n• Invoice delivery (within 24 hours)',
            ),
            _buildSection(
              'Physical Amenities',
              'For bookings that include physical amenities:\n\n• Equipment rental availability confirmed at booking\n• Refreshments (if included) prepared on-site\n• Locker keys provided at venue reception\n• Towels and other amenities available as per booking\n\nNote: Physical amenities are provided by venue partners and subject to their availability.',
            ),
            _buildSection(
              'Delivery Failure Protocol',
              'If you don\'t receive confirmations or access codes:\n\n• Check your spam/junk folder\n• Verify your contact information in the app\n• Contact our support team immediately\n• Use the in-app help feature for instant assistance\n\nWe guarantee alternative access methods for confirmed bookings.',
            ),
            _buildSection(
              'Contact for Delivery Issues',
              'For any service delivery issues:\n\n• In-app support chat (24/7)\n• Email: support@archminton.in\n• Phone: +91 8008871828\n• Emergency booking helpline: +91 8008814466\n\nWe are committed to ensuring smooth delivery of all our digital services.',
            ),
            _buildSection(
              'Geographic Coverage',
              'Our services are currently available in:\n\n• Major metropolitan cities across India\n• Selected suburban areas with partner venues\n• Expanding to new locations regularly\n\nService availability depends on venue partnerships in your area.',
            ),
            _buildSection(
              'Service Modifications',
              'We reserve the right to modify our service delivery methods to improve user experience. Any significant changes will be communicated through:\n\n• In-app notifications\n• Email announcements\n• SMS alerts\n• Website updates',
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