import 'package:archminton/main.dart';
import 'package:archminton/screens/LoginScreen.dart';
import 'package:archminton/screens/VenuScreen.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Bookscreen extends StatefulWidget {
  const Bookscreen({super.key});

  @override
  _BookscreenState createState() => _BookscreenState();
}

class _BookscreenState extends State<Bookscreen> {
  List<dynamic> venues = [];
  bool isLoading = true;
  bool hasError = false;
  String errorMessage = "";
  final apiUrl = "$baseUrl/venues";

  List<String> sportsList = [
    "Badminton",
    "Cricket",
    "Squash",
    "Swimming",
    "Table Tennis",
    "Tennis",
  ];

  String searchQuery = '';
  String selectedSport = '';
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchVenues();
  }

  Future<void> _fetchVenues() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('accessToken');

      if (accessToken == null) {
        if (mounted) {
          setState(() {
            hasError = true;
            isLoading = false;
            errorMessage = 'Authentication required';
          });
        }
        return;
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            venues = (data['data'] as List<dynamic>?)
                    ?.where((v) => v is Map<String, dynamic>)
                    .toList() ??
                [];
            isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            hasError = true;
            isLoading = false;
            errorMessage = 'Failed to load venues: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
          errorMessage = 'Error fetching data: $e';
        });
      }
    }
  }

  List<dynamic> get filteredVenues {
    return venues.where((venue) {
      final matchesSearch = searchQuery.isEmpty ||
          (venue["name"]?.toString().toLowerCase() ?? '')
              .contains(searchQuery.toLowerCase()) ||
          (venue["location"]?.toString().toLowerCase() ?? '')
              .contains(searchQuery.toLowerCase());

      final matchesSport = selectedSport.isEmpty ||
          ((venue["availableSports"] as List<dynamic>? ?? [])
              .contains(selectedSport));

      return matchesSearch && matchesSport;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/bg.jpg"),
              opacity: 0.05,
              fit: BoxFit.cover,
            ),
          ),
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                expandedHeight: 160, // Reduced height
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _exitScreen(context),
                  color: Colors.black87,
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.only(top: 60, left: 16, right: 16),
                    child: Column (
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Find Your Perfect Venue',
                          style: TextStyle(
                            fontSize: 24, // Reduced font size
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Explore a wide range of options',
                          style: TextStyle(
                            fontSize: 14, // Reduced font size
                            color: Colors.black.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: const Text(
                  'Book a Venue',
                  style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                    fontSize: 18, // Reduced font size
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search venue',
                        prefixIcon: Icon(
                          Icons.search,
                          color: Theme.of(context).primaryColor,
                        ),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (query) => setState(() => searchQuery = query),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 12.0),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildSportFilter('All', selectedSport.isEmpty),
                        ...sportsList.map(
                          (sport) =>
                              _buildSportFilter(sport, selectedSport == sport),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isLoading)
                SliverToBoxAdapter(
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              else if (hasError)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(Icons.error, size: 60, color: Colors.red),
                          const SizedBox(height: 12),
                          Text(
                            errorMessage,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchVenues,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else if (filteredVenues.isEmpty)
                SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 60,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No venues found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final venue = filteredVenues[index];
                      return _buildVenueCard(venue);
                    }, childCount: filteredVenues.length),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSportFilter(String sport, bool isSelected) {
    final isAllSelected = sport == 'All' && selectedSport.isEmpty;
    final isSportSelected = sport == selectedSport;

    return GestureDetector(
      onTap: () => setState(() {
        selectedSport = sport == 'All' ? '' : sport;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        margin: const EdgeInsets.only(right: 8.0),
        decoration: BoxDecoration(
          color: isAllSelected || isSportSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isAllSelected || isSportSelected)
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          sport,
          style: TextStyle(
            color: isAllSelected || isSportSelected
                ? Colors.white
                : Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 12, // Reduced font size
          ),
        ),
      ),
    );
  }

  Widget _buildVenueCard(Map<String, dynamic> venue) {
    final imageUrl =
        (venue['images'] != null && venue['images'].isNotEmpty)
            ? venue['images'][0]
            : null;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VenueScreen(venue: venue),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: imageUrl ?? '',
                height: 120, // Reduced image height
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  height: 120,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0), // Reduced padding
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    venue["name"] ?? 'Unnamed Venue',
                    style: const TextStyle(
                      fontSize: 16, // Reduced font size
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  _buildLocationRow(venue["location"] ?? 'No location'),
                  const SizedBox(height: 8),
                  Text(
                    venue["description"] ?? 'No description available',
                    style: const TextStyle(fontSize: 12), // Reduced font size
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  _buildSportsChips(venue["availableSports"] ?? []),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(String location) {
    return Row(
      children: [
        Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            location,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSportsChips(List<dynamic> sports) {
    final validSports = sports;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: validSports.take(3).map(
            (sport) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                sport.toString(),
                style: const TextStyle(fontSize: 10, color: Colors.black87),
              ),
            ),
          ).toList(),
    );
  }
}

void _exitScreen(BuildContext context) {
  if (Navigator.canPop(context)) {
    Navigator.pop(context);
  } else {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => BottomNavBar(),
      ),
      (route) => false,
    );
  }
}