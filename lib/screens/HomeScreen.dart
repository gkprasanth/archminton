import 'package:archminton/screens/BookScreen.dart';
import 'package:archminton/screens/EventScreen.dart';
import 'package:archminton/screens/LearnScreen.dart';
import 'package:archminton/screens/LoginScreen.dart';
import 'package:archminton/screens/Notification.dart';
import 'package:archminton/screens/VenuScreen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'dart:convert';

import '../constants/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String baseUrl = AppConstants.baseUrl;
  
  final List<Map<String, String>> exploreItems = [
    {"text": "Learn", "image": "assets/images/explore-learn.jpg"},
    {"text": "Book and Play", "image": "assets/images/explore-book.jpg"},
    {"text": "Events", "image": "assets/images/explore-events.jpg"},
  ];

  List<dynamic> venues = [];
  List<dynamic> membershipRequests = [];
  List<dynamic> bannerImages = [];
  bool isLoading = true;
  bool isLoadingMemberships = true;
  bool isLoadingBanners = true;
  bool hasError = false;
  String errorMessage = "";
  


  // Stock banner image - using single consistent image to prevent carousel crashes
  final String stockBannerImage = 'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'; // Basketball court
  
  // Create multiple slides with the same image for carousel effect
  List<String> get stockBannerImages => List.generate(3, (index) => stockBannerImage);

  final Map<String, dynamic> dummyVenue = {
    "id": 1,
    "name": "Archminton football court",
    "description": null,
    "location": "Hyderabad, India",
    "latitude": 17.516,
    "longitude": 78.4324,
    "contactPhone": "+919391527509",
    "contactEmail": "surajlohit42@gmail.com",
    "isActive": true,
    "venueType": "PUBLIC",
    "societyId": null,
    "createdAt": "2025-05-27T18:13:27.167Z",
    "updatedAt": "2025-05-27T18:13:27.167Z",
    "images": [
      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/92/Youth-soccer-indiana.jpg/1200px-Youth-soccer-indiana.jpg',
      'https://ddnews.gov.in/wp-content/uploads/2024/12/GettyImages-2162306285.jpg',
      'https://images.squarespace-cdn.com/content/v1/60228b2d4248e2593057e4f5/1612878448762-KT4KAT3KPIKG07A4JXU7/iStock-954142740.jpg?format=2500w',
    ],
    "courts": [
      {
        "id": 1,
        "name": "Court 1",
        "sportType": "FOOTBALL",
        "description": null,
        "venueId": 1,
        "pricePerHour": "300",
        "isActive": true,
        "createdAt": "2025-05-27T18:14:17.572Z",
        "updatedAt": "2025-05-27T18:14:17.572Z",
        "timeSlots": [
          {
            "id": 1,
            "courtId": 1,
            "dayOfWeek": 3,
            "startTime": "09:00",
            "endTime": "10:00",
            "isActive": true,
          },
          {
            "id": 2,
            "courtId": 1,
            "dayOfWeek": 3,
            "startTime": "10:00",
            "endTime": "11:00",
            "isActive": true,
          },
        ],
      },
    ],
    "availableSports": ["Football", "Badminton", "Basketball"],
    "services": ["Book N Play", "Coaching", "Events", "Membership"],
    "amenities": [
      "Washrooms",
      "Drinking Water",
      "Parking",
      "Seating Area",
      "First Aid",
      "Cafeteria",
      "Lighting",
    ],
    "society": null,
  };

  @override
  void initState() {
    super.initState();
    fetchVenues();
    fetchMembershipRequests();
    fetchBannerImages();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> fetchVenues() async {
    print('🚀 Starting fetchVenues...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final name = prefs.getString('user');
      final userId = prefs.getString('userId');
      
      print('📱 User data from SharedPreferences:');
      print('   - name: $name');
      print('   - userId: $userId');
      print('   - accessToken: ${accessToken != null ? "Present (${accessToken.length} chars)" : "NULL"}');
      
      if (accessToken != null) {
        print('   - Token preview: ${accessToken.substring(0, accessToken.length > 20 ? 20 : accessToken.length)}...');
      }

      if (accessToken == null) {
        print('❌ No access token found in SharedPreferences');
        if (!mounted) return;
        setState(() {
          hasError = true;
          isLoading = false;
          errorMessage = 'Access token not found';
        });
        return;
      }

      final url = '$baseUrl/venues';
      print('🌐 Making API request:');
      print('   - URL: $url');
      print('   - Headers: Authorization: Bearer ${accessToken.substring(0, 20)}...');
      print('   - Headers: Content-Type: application/json');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 API Response received:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Headers: ${response.headers}');
      print('   - Response Body Length: ${response.body.length} characters');
      print('   - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully parsed JSON response:');
        print('   - Data type: ${data.runtimeType}');
        print('   - Data keys: ${data is Map ? data.keys.toList() : "Not a Map"}');
        
        if (data is Map && data.containsKey('data')) {
          print('   - Venues count: ${data['data']?.length ?? 0}');
          print('   - Venues data: ${data['data']}');
        } else {
          print('   - Full data: $data');
        }
        
        if (!mounted) return;
        setState(() {
          venues = data['data'] ?? data; // Handle both formats
          isLoading = false;
          hasError = false;
        });
        print('✅ Venues state updated successfully');
      } else {
        print('❌ API request failed with status ${response.statusCode}');
        print('   - Error response body: ${response.body}');
        
        // Try to parse error message from response
        String detailedError = 'Failed to fetch venues: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            final message = errorData['message'] ?? errorData['error'] ?? errorData['detail'];
            if (message != null) {
              detailedError += ' - $message';
            }
          }
        } catch (e) {
          print('   - Could not parse error response as JSON: $e');
        }
        
        if (!mounted) return;
        setState(() {
          hasError = true;
          isLoading = false;
          errorMessage = detailedError;
        });
      }
    } catch (e, stackTrace) {
      print('💥 Exception in fetchVenues:');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
        errorMessage = 'Error fetching venues: $e';
      });
    }
  }

  Future<void> fetchMembershipRequests() async {
    print('🚀 Starting fetchMembershipRequests...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      
      if (accessToken == null) {
        print('❌ No access token found for membership requests');
        if (!mounted) return;
        setState(() {
          isLoadingMemberships = false;
        });
        return;
      }

      final url = '$baseUrl/membership-requests';
      print('🌐 Making membership API request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Membership API Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully parsed membership JSON response');
        
        if (!mounted) return;
        setState(() {
          membershipRequests = data is List ? data : (data['data'] ?? []);
          isLoadingMemberships = false;
        });
        print('✅ Membership requests state updated successfully');
      } else {
        print('❌ Membership API request failed with status ${response.statusCode}');
        if (!mounted) return;
        setState(() {
          isLoadingMemberships = false;
        });
      }
    } catch (e, stackTrace) {
      print('💥 Exception in fetchMembershipRequests:');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      
      if (!mounted) return;
      setState(() {
        isLoadingMemberships = false;
      });
    }
  }

  Future<void> fetchBannerImages() async {
    print('🚀 Starting fetchBannerImages...');
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      
      if (accessToken == null) {
        print('❌ No access token found for banner images');
        print('   - Using stock images as fallback');
        if (!mounted) return;
        setState(() {
          bannerImages = stockBannerImages;
          isLoadingBanners = false;
        });
        return;
      }

      final url = '$baseUrl/banners';
      print('🌐 Making banner API request to: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      print('📡 Banner API Response:');
      print('   - Status Code: ${response.statusCode}');
      print('   - Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully parsed banner JSON response');
        
        final apiImages = data is List ? data : (data['data'] ?? []);
        
        if (!mounted) return;
        setState(() {
          // Use API images if available, otherwise use stock images
          bannerImages = apiImages.isNotEmpty ? apiImages : stockBannerImages;
          isLoadingBanners = false;
        });
        print('✅ Banner images state updated successfully');
      } else {
        print('❌ Banner API request failed with status ${response.statusCode}');
        print('   - Using stock images as fallback');
        if (!mounted) return;
        setState(() {
          bannerImages = stockBannerImages;
          isLoadingBanners = false;
        });
      }
    } catch (e, stackTrace) {
      print('💥 Exception in fetchBannerImages:');
      print('   - Error: $e');
      print('   - Stack trace: $stackTrace');
      print('   - Using stock images as fallback');
      
      if (!mounted) return;
              setState(() {
          bannerImages = stockBannerImages;
          isLoadingBanners = false;
        });
            }
  }



  Future<String?> _getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<String?>(
        future: _getUserName(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userName = snapshot.data ?? "User";

          return SafeArea(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/bg.jpg"),
                  opacity: 0.05,
                  fit: BoxFit.cover,
                ),
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Enhanced Header Section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.green.shade600,
                              Colors.green.shade400,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Home",
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.notifications_outlined),
                                    color: Colors.white,
                                    iconSize: 24,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const NotificationScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(
                                    Icons.sports_tennis,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Welcome, $userName! 👋",
                                        style: GoogleFonts.poppins(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Ready to play a Sport?",
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: Colors.white.withOpacity(0.9),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "Book courts, play with friends, and improve your game!",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildBannerCarousel(),
                      const SizedBox(height: 24),
                      _buildSubscriptionsSection(),
                      const SizedBox(height: 32),
                      sectionTitle("Explore"),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          itemCount: exploreItems.length,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final item = exploreItems[index];
                            return buildExploreCard(
                              context,
                              item["image"]!,
                              item["text"]!,
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 32),
                      sectionTitle("Sports Centers"),
                      const SizedBox(height: 12),
                      _buildVenuesSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget sectionTitle(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget buildExploreCard(
    BuildContext context,
    String imagePath,
    String label,
  ) {
    Widget? destination;

    switch (label.toLowerCase()) {
      case 'learn':
        destination = LearnScreen();
        break;
      case 'book and play':
        destination = const Bookscreen();
        break;
      case 'events':
        destination = const EventScreen();
        break;
    }

    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination!),
          );
        }
      },
      child: Container(
        width: 180,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

      Widget _buildBannerCarousel() {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          stockBannerImage,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
          errorBuilder: (_, __, ___) => _buildBannerPlaceholder(),
        ),
      ),
    );
  }

  Widget _buildBannerPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.blue.shade400,
            Colors.purple.shade400,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_tennis,
              size: 48,
              color: Colors.white.withOpacity(0.8),
            ),
            const SizedBox(height: 12),
            Text(
              "Sports Events & Activities",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Stay updated with latest events",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildSubscriptionsSection() {
    // Don't show anything if loading is complete and there are no memberships
    if (!isLoadingMemberships && membershipRequests.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "SUBSCRIPTIONS",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
                letterSpacing: 0.5,
              ),
            ),
            if (!isLoadingMemberships && membershipRequests.isNotEmpty)
              TextButton(
                onPressed: () {
                  // Navigate to full subscriptions page
                  // TODO: Implement navigation to subscriptions page
                },
                child: Text(
                  "View All",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green[600],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSubscriptionsList(),
      ],
    );
  }

  Widget _buildSubscriptionsList() {
    if (isLoadingMemberships) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: membershipRequests.length,
        itemBuilder: (context, index) {
          final membership = membershipRequests[index];
          return _buildSubscriptionCard(membership);
        },
      ),
    );
  }

  Widget _buildSubscriptionCard(Map<String, dynamic> membership) {
    final status = membership['status'] ?? 'UNKNOWN';
    final societyId = membership['societyId'];
    final createdAt = membership['createdAt'];
    final reviewNote = membership['reviewNote'];
    
    // Parse date
    String dateText = 'Unknown Date';
    if (createdAt != null) {
      try {
        final date = DateTime.parse(createdAt);
        dateText = '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year.toString().substring(2)}';
      } catch (e) {
        print('Error parsing date: $e');
      }
    }

    // Determine status color and text
    Color statusColor;
    String statusText;
    IconData statusIcon;
    
    switch (status.toUpperCase()) {
      case 'PENDING':
        statusColor = Colors.orange;
        statusText = 'PENDING';
        statusIcon = Icons.hourglass_empty;
        break;
      case 'APPROVED':
        statusColor = Colors.green;
        statusText = 'ACTIVE';
        statusIcon = Icons.check_circle;
        break;
      case 'REJECTED':
        statusColor = Colors.red;
        statusText = 'REJECTED';
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'INACTIVE';
        statusIcon = Icons.help_outline;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Swimming Coaching", // Default title, could be dynamic
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                "P Sathya Krishiv", // Could be dynamic from user data
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.confirmation_number,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                "PSA${membership['id']?.toString().padLeft(5, '0') ?? '00000'}",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.sports_tennis,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Text(
                "Swimming",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.location_on,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  "Rainbow Vistas...", // Could be dynamic from society data
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    dateText,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              if (status.toUpperCase() == 'PENDING')
                ElevatedButton(
                  onPressed: () {
                    // TODO: Implement renew functionality
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    "Renew",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVenuesSection() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (hasError) {
      return Column(
        children: [
          Text(errorMessage, style: GoogleFonts.poppins(color: Colors.red)),
          const SizedBox(height: 10),
          ElevatedButton(onPressed: fetchVenues, child: const Text('Retry')),
        ],
      );
    }

    if (venues.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No venues available',
            style: GoogleFonts.poppins(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: venues.length,
        itemBuilder: (context, index) {
          final venue = venues[index];
          final dynamic imageData =
              (venue['images'] != null && venue['images'].isNotEmpty)
                  ? venue['images'][0]
                  : null;

          // Handle both string and map-type image data
          final rawImageUrl = imageData is String ? imageData : imageData?['url'];
          final imageUrl = _getFullImageUrl(rawImageUrl);
          
          // Debug image data
          print('🖼️ Venue: ${venue['name']} - Image data: $imageData');
          print('🖼️ Raw URL: $rawImageUrl');
          print('🖼️ Full URL: $imageUrl');

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => VenueScreen(venue: venue)),
              );
            },
            child: Container(
              width: 200,
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with loading and error states
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child:
                        imageUrl != null && _isValidImageUrl(imageUrl)
                            ? Image.network(
                              imageUrl,
                              height: 120,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value:
                                        loadingProgress.expectedTotalBytes !=
                                                null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                  ),
                                );
                              },
                              errorBuilder:
                                  (_, __, ___) => _buildImagePlaceholder(),
                            )
                            : _buildImagePlaceholder(),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    venue['name'] ?? 'Unknown Venue',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    venue['location'] ?? 'No location specified',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    // Use a nice stock sports facility image
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1723633236252-eb7badabb34c?q=80&w=3024&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: const Center(
          child: Icon(
            Icons.sports_tennis,
            color: Colors.white,
            size: 40,
          ),
        ),
      ),
    );
  }

  bool _isValidImageUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    
    // Check if URL has a valid protocol
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      print('⚠️ Invalid image URL (no protocol): $url');
      return false;
    }
    
    // Check if URL has a host
    try {
      final uri = Uri.parse(url);
      if (uri.host.isEmpty) {
        print('⚠️ Invalid image URL (no host): $url');
        return false;
      }
      return true;
    } catch (e) {
      print('⚠️ Invalid image URL (parse error): $url - $e');
      return false;
    }
  }

  String? _getFullImageUrl(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return null;
    
    // If it's already a full URL, return as is
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    
    // If it's a relative URL, construct full URL with base URL
    if (imageUrl.startsWith('/')) {
      return '$baseUrl$imageUrl';
    } else {
      return '$baseUrl/$imageUrl';
    }
  }
}
