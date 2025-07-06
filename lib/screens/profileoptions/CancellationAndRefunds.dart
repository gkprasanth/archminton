import 'package:flutter/material.dart';

class CancellationAndRefundsScreen extends StatelessWidget {
  const CancellationAndRefundsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F5F5),
      appBar: AppBar(
        backgroundColor: Colors.green.shade600,
        title: const Text('Cancellation & Refunds'),
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
              'Cancellation & Refunds Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),
            _buildSection(
              'Cancellation Policy',
              'We understand that plans can change. Our cancellation policy is designed to be fair to both our users and venue partners:\n\n• Free cancellation: 24+ hours before booking time\n• 50% refund: 2-24 hours before booking time\n• No refund: Less than 2 hours before booking time\n• No refund: No-show without cancellation',
            ),
            _buildSection(
              'How to Cancel',
              'You can cancel your booking through multiple channels:\n\n• Archminton mobile app (recommended)\n• Website login portal\n• Phone call to customer support\n• Email to support@archminton.com\n\nCancellation confirmation will be sent via email and SMS within 5 minutes of processing.',
            ),
            _buildSection(
              'Refund Timeline',
              'Refunds are processed according to the following timeline:\n\n• Credit/Debit Cards: 5-7 business days\n• UPI/Digital Wallets: 1-3 business days\n• Net Banking: 3-5 business days\n• Bank Account Transfer: 7-10 business days\n\nRefund processing begins immediately after cancellation approval.',
            ),
            _buildSection(
              'Refund Calculation',
              'Refund amounts are calculated based on the cancellation timing:\n\n• 24+ hours before: 100% refund minus payment gateway charges\n• 2-24 hours before: 50% refund minus payment gateway charges\n• Weather cancellation: 100% refund (outdoor bookings only)\n• Venue closure: 100% refund or free rescheduling',
            ),
            _buildSection(
              'Special Circumstances',
              'Full refunds are provided in the following cases:\n\n• Medical emergencies (valid medical certificate required)\n• Venue cancellation or closure\n• Severe weather conditions (outdoor bookings)\n• Technical issues on our platform\n• Overbooking by venue partners\n\nDocumentary proof may be required for special circumstance refunds.',
            ),
            _buildSection(
              'Membership Cancellations',
              'For membership cancellations:\n\n• Monthly memberships: 7 days notice required\n• Quarterly memberships: 15 days notice required\n• Annual memberships: 30 days notice required\n• Unused portion refunded proportionally\n• Processing fee may apply based on membership type',
            ),
            _buildSection(
              'Rescheduling Options',
              'Instead of cancellation, you can reschedule your booking:\n\n• Free rescheduling: 24+ hours before booking\n• One-time rescheduling: 2-24 hours before booking\n• Subject to venue availability\n• Same venue, same sport, different time slot\n• Valid for 30 days from original booking date',
            ),
            _buildSection(
              'Group Booking Cancellations',
              'Special rules apply for group bookings (5+ people):\n\n• 48 hours notice required for full refund\n• Partial cancellations allowed with 24 hours notice\n• Group leader responsible for all cancellations\n• Refund processed to original payment method\n• Individual member refunds not available',
            ),
            _buildSection(
              'Promotional Bookings',
              'Bookings made using promotional codes or discounts:\n\n• Standard cancellation policy applies\n• Promotional value may not be refundable\n• Original payment amount refunded\n• Promotional credits may be forfeited\n• Special terms may apply for specific promotions',
            ),
            _buildSection(
              'Refund Process',
              'Our refund process follows these steps:\n\n1. Cancellation request received and verified\n2. Refund eligibility calculated based on timing\n3. Refund amount determined minus applicable fees\n4. Refund initiated to original payment method\n5. Confirmation sent via email and SMS\n6. Refund reflected in account within stated timeline',
            ),
            _buildSection(
              'Dispute Resolution',
              'For refund disputes:\n\n• Contact customer support within 7 days\n• Provide booking ID and transaction details\n• Allow 48 hours for initial response\n• Escalation to management if needed\n• Final resolution within 15 business days\n• Email: disputes@archminton.com',
            ),
            _buildSection(
              'Contact for Cancellations',
              'For cancellation assistance:\n\n• Phone: +91 9876543210\n• Email: support@archminton.com\n• Emergency cancellation: +91 9876543211\n• In-app support chat (24/7)\n• Support hours: 6:00 AM - 10:00 PM daily',
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Text(
                'Important: Cancellation and refund policies are subject to venue-specific terms and conditions. Some venues may have different policies which will be clearly mentioned during booking.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.orange,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 20),
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