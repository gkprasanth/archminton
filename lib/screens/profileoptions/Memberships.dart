import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class MembershipsScreen extends StatefulWidget {
  const MembershipsScreen({super.key});

  @override
  State<MembershipsScreen> createState() => _MembershipsScreenState();
}

class _MembershipsScreenState extends State<MembershipsScreen> {

  List<Map<String, dynamic>> userMemberships = [];
  List<Map<String, dynamic>> courseEnrollments = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllSubscriptions();
  }

  Future<void> _loadAllSubscriptions() async {
    try {
      print('🚀 MembershipsScreen: Starting _loadAllSubscriptions...');
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Load only memberships and courses (no membership requests)
      await Future.wait([
        _loadUserMemberships(),
        _loadCourseEnrollments(),
      ]).timeout(
        const Duration(seconds: 90), // 90 seconds total timeout
        onTimeout: () {
          print('⏰ MembershipsScreen: _loadAllSubscriptions timed out after 90 seconds');
          throw Exception('Request timed out');
        },
      );
      
      setState(() {
        isLoading = false;
      });
      print('✅ MembershipsScreen: _loadAllSubscriptions completed successfully');
    } catch (e) {
      print('❌ MembershipsScreen: Error in _loadAllSubscriptions: $e');
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }



  Future<void> _loadUserMemberships() async {
    try {
      print('🔄 MembershipsScreen: Starting to load user memberships...');
      final memberships = await ApiService.getUserMemberships();
      setState(() {
        userMemberships = memberships;
      });
      print('✅ MembershipsScreen: Successfully loaded ${memberships.length} user memberships');
    } catch (e) {
      print('❌ MembershipsScreen: Error loading user memberships: $e');
      setState(() {
        userMemberships = [];
      });
    }
  }

  Future<void> _loadCourseEnrollments() async {
    try {
      print('🔄 MembershipsScreen: Starting to load course enrollments...');
      final enrollments = await ApiService.getUserCourseEnrollments();
      setState(() {
        courseEnrollments = enrollments;
      });
      print('✅ MembershipsScreen: Successfully loaded ${enrollments.length} course enrollments');
    } catch (e) {
      print('❌ MembershipsScreen: Error loading course enrollments: $e');
      setState(() {
        courseEnrollments = [];
      });
    }
  }



  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'APPROVED':
      case 'ACTIVE':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      case 'COMPLETED':
        return Colors.blue;
      case 'CANCELLED':
        return Colors.red;
      case 'EXPIRED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'APPROVED':
      case 'ACTIVE':
        return Icons.check_circle;
      case 'REJECTED':
      case 'CANCELLED':
        return Icons.cancel;
      case 'COMPLETED':
        return Icons.check_circle;
      case 'EXPIRED':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'membership':
        return Icons.card_membership;
      case 'membership_request':
        return Icons.pending;
      case 'course':
        return Icons.school;
      default:
        return Icons.sports_tennis;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  List<Map<String, dynamic>> _getAllSubscriptions() {
    List<Map<String, dynamic>> allSubscriptions = [];
    
    // Add active memberships
    for (var membership in userMemberships) {
      allSubscriptions.add({
        'type': 'membership',
        'data': membership,
        'title': membership['package']?['name'] ?? 'Membership Package',
        'status': membership['status'] ?? 'ACTIVE',
        'id': membership['id'],
        'createdAt': membership['createdAt'],
        'canDelete': false,
      });
    }
    
    // Add course enrollments
    for (var enrollment in courseEnrollments) {
      allSubscriptions.add({
        'type': 'course',
        'data': enrollment,
        'title': enrollment['course']?['name'] ?? 'Course Enrollment',
        'status': enrollment['status'] ?? 'ACTIVE',
        'id': enrollment['id'],
        'createdAt': enrollment['createdAt'],
        'canDelete': false,
      });
    }

    // Sort by creation date (newest first)
    allSubscriptions.sort((a, b) {
      try {
        final dateA = DateTime.parse(a['createdAt'] ?? '');
        final dateB = DateTime.parse(b['createdAt'] ?? '');
        return dateB.compareTo(dateA);
      } catch (e) {
        return 0;
      }
    });

    return allSubscriptions;
  }

  String _getSubscriptionTypeText(String type, Map<String, dynamic> data) {
    switch (type) {
      case 'membership':
        final packageName = data['package']?['name'] ?? 'Membership';
        final venue = data['venue']?['name'] ?? data['package']?['venue']?['name'];
        return venue != null ? '$packageName at $venue' : packageName;
      case 'course':
        final courseName = data['course']?['name'] ?? 'Course';
        final venue = data['course']?['venue']?['name'];
        return venue != null ? '$courseName at $venue' : courseName;
      default:
        return 'Subscription';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Subscriptions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllSubscriptions,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadAllSubscriptions,
          child: isLoading 
              ? _buildLoadingState()
              : errorMessage != null
                  ? _buildErrorState()
                  : _buildSubscriptionsList(),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading subscriptions...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Subscriptions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllSubscriptions,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionsList() {
    final allSubscriptions = _getAllSubscriptions();
    
    if (allSubscriptions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: allSubscriptions.length,
      itemBuilder: (context, index) {
        final subscription = allSubscriptions[index];
        return _buildSubscriptionCard(subscription);
      },
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> subscription) {
    final type = subscription['type'] ?? 'unknown';
    final data = subscription['data'] ?? {};
    final title = subscription['title'] ?? 'Subscription';
    final status = subscription['status'] ?? 'UNKNOWN';
    final createdAt = subscription['createdAt'];
    final canDelete = subscription['canDelete'] ?? false;
    
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final typeIcon = _getTypeIcon(type);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        typeIcon,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Subscription details
            _buildDetailRow('Type', _getSubscriptionTypeText(type, data)),
            _buildDetailRow('ID', "${type.toUpperCase().substring(0, 3)}${subscription['id']?.toString().padLeft(5, '0') ?? '00000'}"),
            _buildDetailRow('Created', _formatDate(createdAt?.toString() ?? '')),
            
            // Additional details based on type
            if (type == 'membership_request' && data['reviewNote'] != null && data['reviewNote'].toString().isNotEmpty)
              _buildDetailRow('Review Note', data['reviewNote'].toString()),
            
            if (type == 'membership' && data['endDate'] != null)
              _buildDetailRow('Expires', _formatDate(data['endDate'].toString())),
            
            if (type == 'course' && data['course']?['endDate'] != null)
              _buildDetailRow('Course Ends', _formatDate(data['course']['endDate'].toString())),
            
            const SizedBox(height: 16),
            

          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_membership,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Subscriptions',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You don\'t have any active subscriptions, membership requests, or course enrollments yet.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAllSubscriptions,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
