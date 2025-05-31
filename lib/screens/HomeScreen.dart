import 'package:archminton/screens/BookScreen.dart';
import 'package:archminton/screens/EventScreen.dart';
import 'package:archminton/screens/LearnScreen.dart';
import 'package:archminton/screens/LoginScreen.dart';
import 'package:archminton/screens/Notification.dart';
import 'package:archminton/screens/VenuScreen.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> exploreItems = [
    {"text": "Learn", "image": "assets/images/explore-learn.jpg"},
    {"text": "Book and Play", "image": "assets/images/explore-book.jpg"},
    {"text": "Events", "image": "assets/images/explore-events.jpg"},
  ];

  List<dynamic> venues = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";

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
  }

  Future<void> fetchVenues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');
      final name = prefs.getString('user');
      print(name);

      if (accessToken == null) {
        if (!mounted) return;
        setState(() {
          hasError = true;
          isLoading = false;
          errorMessage = 'Access token not found';
        });
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/venues'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (!mounted) return;
        setState(() {
          venues = data['data'];
          isLoading = false;
          hasError = false;
        });
        // print("Venues fetched successfully:");
        // print(venues);
      } else {
        if (!mounted) return;
        setState(() {
          hasError = true;
          isLoading = false;
          errorMessage = 'Failed to fetch venues: ${response.statusCode}';
        });
        // print(response.body);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        hasError = true;
        isLoading = false;
        errorMessage = 'Error fetching venues: $e';
      });
      // print(errorMessage);
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Home",
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications),
                            color: Colors.black87,
                            iconSize: 28,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => const NotificationScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Text(
                        "Welcome, $userName 👋",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Ready to play a Sport?",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
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
          final imageUrl = imageData is String ? imageData : imageData?['url'];

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
                        imageUrl != null
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
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: Center(
        child: Icon(Icons.broken_image, color: Colors.grey[500], size: 40),
      ),
    );
  }
}
