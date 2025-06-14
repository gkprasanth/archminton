import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  List<Map<String, dynamic>> allBookings = [];
  List<Map<String, dynamic>> currentBookings = [];
  List<Map<String, dynamic>> pastBookings = [];
  
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      print('🔄 MyBookings: Starting to load bookings...');
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      print('📡 MyBookings: Calling ApiService.getUserBookings()...');
      final response = await ApiService.getUserBookings();
      
      print('📥 MyBookings: Raw API response received:');
      print('📥 Response type: ${response.runtimeType}');
      print('📥 Response content: $response');
      
      // Handle different response formats
      List<Map<String, dynamic>> bookings = [];
      
      if (response is Map<String, dynamic>) {
        print('🔍 MyBookings: Response is a Map, checking for data/bookings arrays...');
        print('🔍 Available keys: ${response.keys.toList()}');
        
        if (response.containsKey('data') && response['data'] is List) {
          print('✅ MyBookings: Found data array with ${(response['data'] as List).length} items');
          final dataList = response['data'] as List;
          bookings = dataList.map((item) => item as Map<String, dynamic>).toList();
        } else if (response.containsKey('bookings') && response['bookings'] is List) {
          print('✅ MyBookings: Found bookings array with ${(response['bookings'] as List).length} items');
          final bookingsList = response['bookings'] as List;
          bookings = bookingsList.map((item) => item as Map<String, dynamic>).toList();
        } else {
          print('📝 MyBookings: Response is a single booking object, wrapping in list');
          bookings = [response];
        }
      } else if (response is List) {
        print('✅ MyBookings: Response is a List with ${response.length} items');
        final responseList = response as List;
        bookings = responseList.map((item) => item as Map<String, dynamic>).toList();
      } else {
        print('❌ MyBookings: Unexpected response type: ${response.runtimeType}');
      }
      
      print('📊 MyBookings: Processed ${bookings.length} bookings total');

      // Separate current and past bookings
      print('📅 MyBookings: Categorizing bookings into current and past...');
      final now = DateTime.now();
      final currentList = <Map<String, dynamic>>[];
      final pastList = <Map<String, dynamic>>[];

      for (int i = 0; i < bookings.length; i++) {
        final booking = bookings[i];
        print('📋 MyBookings: Processing booking $i: ${booking['id'] ?? 'no-id'}');
        
        try {
          final bookingDateStr = booking['bookingDate']?.toString() ?? booking['date']?.toString() ?? '';
          print('📅 Booking date string: "$bookingDateStr"');
          
          if (bookingDateStr.isNotEmpty) {
            final bookingDate = DateTime.parse(bookingDateStr);
            print('📅 Parsed date: $bookingDate, Current date: $now');
            
            if (bookingDate.isAfter(now) || bookingDate.isAtSameMomentAs(DateTime(now.year, now.month, now.day))) {
              print('➡️ Adding to current bookings');
              currentList.add(booking);
            } else {
              print('⬅️ Adding to past bookings');
              pastList.add(booking);
            }
          } else {
            print('⚠️ No date found, adding to current bookings');
            currentList.add(booking);
          }
        } catch (e) {
          print('❌ Date parsing failed: $e, adding to current bookings');
          currentList.add(booking);
        }
      }

      // Sort bookings by date
      currentList.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['bookingDate']?.toString() ?? a['date']?.toString() ?? '');
          final dateB = DateTime.parse(b['bookingDate']?.toString() ?? b['date']?.toString() ?? '');
          return dateA.compareTo(dateB);
        } catch (e) {
          return 0;
        }
      });

      pastList.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['bookingDate']?.toString() ?? a['date']?.toString() ?? '');
          final dateB = DateTime.parse(b['bookingDate']?.toString() ?? b['date']?.toString() ?? '');
          return dateB.compareTo(dateA); // Reverse order for past bookings
        } catch (e) {
          return 0;
        }
      });

      print('📊 MyBookings: Final counts - Current: ${currentList.length}, Past: ${pastList.length}');
      
      setState(() {
        allBookings = bookings;
        currentBookings = currentList;
        pastBookings = pastList;
        isLoading = false;
      });
      
      print('✅ MyBookings: Successfully loaded and categorized bookings');
    } catch (e) {
      print('❌ MyBookings: Error loading bookings: $e');
      print('❌ Error type: ${e.runtimeType}');
      
      setState(() {
        errorMessage = e.toString().replaceAll('Exception: ', '');
        isLoading = false;
      });
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    try {
      await ApiService.cancelBooking(bookingId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Reload bookings
      _loadBookings();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling booking: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCancelConfirmation(int bookingId, String venueName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Cancel Booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to cancel your booking at $venueName?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep Booking',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(bookingId);
            },
            child: Text(
              'Cancel Booking',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData getSportIcon(String sport) {
    final sportLower = sport.toLowerCase();
    if (sportLower.contains('tennis')) return Icons.sports_tennis;
    if (sportLower.contains('badminton')) return Icons.sports;
    if (sportLower.contains('football')) return Icons.sports_soccer;
    if (sportLower.contains('basketball')) return Icons.sports_basketball;
    if (sportLower.contains('swimming')) return Icons.pool;
    if (sportLower.contains('cricket')) return Icons.sports_cricket;
    if (sportLower.contains('table tennis')) return Icons.table_restaurant;
    return Icons.sports;
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'active':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
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

  String _formatTime(String timeString) {
    // Handle different time formats
    if (timeString.contains(' - ')) {
      return timeString; // Already formatted
    }
    
    try {
      // Try to parse as time and format
      final time = DateFormat('HH:mm').parse(timeString);
      return DateFormat('h:mm a').format(time);
    } catch (e) {
      return timeString; // Return as is if parsing fails
    }
  }

  Widget buildBookingCard(Map<String, dynamic> booking, bool isPast) {
    final venueName = booking['court']?['venue']?['name']?.toString() ?? 
                     booking['venue']?['name']?.toString() ?? 
                     booking['venueName']?.toString() ?? 
                     'Unknown Venue';
    
    final sportType = booking['court']?['sportType']?.toString() ?? 
                     booking['sportType']?.toString() ?? 
                     'Unknown Sport';
    
    final status = booking['status']?.toString() ?? 'Unknown';
    final bookingDate = booking['bookingDate']?.toString() ?? booking['date']?.toString() ?? '';
    final timeSlot = booking['timeSlot']?.toString() ?? 
                    booking['time']?.toString() ?? 
                    '${booking['startTime'] ?? ''} - ${booking['endTime'] ?? ''}';
    
    final courtName = booking['court']?['name']?.toString() ?? 
                     booking['courtName']?.toString() ?? 
                     'Court';
    
    final bookingId = booking['id'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  getSportIcon(sportType),
                  size: 26,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      venueName,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$sportType • $courtName',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: getStatusColor(status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: getStatusColor(status).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: getStatusColor(status),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          bookingDate.isNotEmpty ? _formatDate(bookingDate) : 'No date',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 20,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Icon(Icons.access_time_outlined,
                          size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          timeSlot.isNotEmpty ? _formatTime(timeSlot) : 'No time',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Show booking ID and price if available
          if (booking['id'] != null || booking['totalAmount'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (booking['id'] != null)
                  Expanded(
                    child: Text(
                      'Booking ID: #${booking['id']}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                if (booking['totalAmount'] != null)
                  Text(
                    '₹${booking['totalAmount']}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
          
          if (!isPast && status.toLowerCase() != 'cancelled') ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement modify booking
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Modify booking feature coming soon')),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: Text(
                      'Modify',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green.shade600,
                      side: BorderSide(color: Colors.green.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showCancelConfirmation(bookingId, venueName),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget buildBookingsList(List<Map<String, dynamic>> bookings, bool isPast) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isPast ? Icons.history : Icons.event_available,
                size: 80,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 20),
              Text(
                isPast ? 'No past bookings' : 'No current bookings',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                isPast
                    ? 'Your completed bookings will appear here'
                    : 'Book a venue to see your upcoming bookings',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBookings,
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

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        return buildBookingCard(bookings[index], isPast);
      },
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
              'Error Loading Bookings',
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
              onPressed: _loadBookings,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        title: Text(
          'My Bookings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 3,
        shadowColor: Colors.green.shade200,
        actions: [
          IconButton(
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: Container(
            color: Colors.green.shade600,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.green.shade100,
              labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              tabs: [
                Tab(text: 'Current (${currentBookings.length})'),
                Tab(text: 'Past (${pastBookings.length})'),
              ],
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.green),
                  SizedBox(height: 16),
                  Text('Loading your bookings...'),
                ],
              ),
            )
          : errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      buildBookingsList(currentBookings, false),
                      buildBookingsList(pastBookings, true),
                    ],
                  ),
                ),
    );
  }
}
