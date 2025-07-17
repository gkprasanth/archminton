import 'dart:async';
import 'package:archminton/screens/BookingScreen.dart';
import 'package:archminton/screens/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart'; // Added import for BottomNavBar

class VenueScreen extends StatefulWidget {
  final Map<String, dynamic> venue;

  const VenueScreen({super.key, required this.venue});

  @override
  State<VenueScreen> createState() => _VenueScreenState();
}

class _VenueScreenState extends State<VenueScreen> {
  late final PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  final _expandDescription = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    final images = widget.venue['images'] as List<dynamic>? ?? [];
    if (images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutQuint,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    _expandDescription.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;
    final images = venue['images'] as List<dynamic>? ?? [];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final venueId = venue['id'].toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          venue['name'] ?? 'Venue Details',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              // Fallback to main app if can't pop
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const MyApp()),
              );
            }
          },
        ),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.favorite_border),
        //     onPressed: () => _toggleFavorite(),
        //   ),
        // ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.03),
              colors.primary.withOpacity(0.08),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildImageCarousel(images, colors)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 16,
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildVenueTitle(venue, colors),
                  const SizedBox(height: 24),
                  _buildDescriptionSection(venue),
                  const SizedBox(height: 32),
                  _buildLocationSection(venue, colors),
                  const SizedBox(height: 32),
                  _buildContactSection(venue, colors),
                  const SizedBox(height: 32),
                  // _buildCategorySection('Venue Type', venue['venueType'], Icons.category, colors),
                  // const SizedBox(height: 32),
                  _buildChipsSection(
                    'Available Sports',
                    venue['availableSports'],
                    Icons.sports_soccer,
                    colors,
                  ),
                  const SizedBox(height: 32),
                  _buildChipsSection(
                    'Services',
                    venue['services'],
                    Icons.room_service,
                    colors,
                  ),
                  const SizedBox(height: 32),
                  _buildChipsSection(
                    'Amenities',
                    venue['amenities'],
                    Icons.spa,
                    colors,
                  ),
                  const SizedBox(height: 20), // Reduced space
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(12.0), // Reduced padding
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colors.primary.withOpacity(0.03),
              colors.primary.withOpacity(0.08),
            ],
          ),
        ),
        child: SafeArea(
          child: _buildBookButton(colors, venueId),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(List<dynamic> images, ColorScheme colors) {
    return SizedBox(
      height: 280,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 15,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Stack(
                    children: [
                      images[index] != null && 
                      images[index].isNotEmpty &&
                      _isValidImageUrl(images[index])
                          ? Image.network(
                              images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage('https://images.unsplash.com/photo-1723633236252-eb7badabb34c?q=80&w=3024&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
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
                              ),
                            )
                          : Container(
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage('https://images.unsplash.com/photo-1723633236252-eb7badabb34c?q=80&w=3024&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: Container(
                                decoration: BoxDecoration(
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
                            ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colors.surface.withOpacity(0.6),
                              colors.surface.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == index ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color:
                          _currentPage == index
                              ? colors.primary
                              : colors.onSurface.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVenueTitle(Map<String, dynamic> venue, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          venue['name'] ?? 'Unnamed Venue',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
            letterSpacing: -0.75,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(Map<String, dynamic> venue) {
    if (venue['description'] == null) return const SizedBox.shrink();

    return ValueListenableBuilder<bool>(
      valueListenable: _expandDescription,
      builder: (context, expanded, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: Text(
                venue['description'],
                style: GoogleFonts.poppins(fontSize: 16, height: 1.5),
                maxLines: expanded ? null : 3,
                overflow: expanded ? null : TextOverflow.ellipsis,
              ),
            ),
            TextButton(
              onPressed: () => _expandDescription.value = !expanded,
              child: Text(
                expanded ? 'Read Less' : 'Read More',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLocationSection(Map<String, dynamic> venue, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Location', Icons.location_on, colors),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                venue['location'] ?? 'Not Available',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Lat: ${venue['latitude']} | Long: ${venue['longitude']}',
                style: GoogleFonts.poppins(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSection(Map<String, dynamic> venue, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Contact', Icons.contact_phone, colors),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            if (venue['contactPhone'] != null)
              _buildContactChip(Icons.phone, venue['contactPhone'], colors),
            if (venue['contactEmail'] != null)
              _buildContactChip(Icons.email, venue['contactEmail'], colors),
          ],
        ),
      ],
    );
  }

  Widget _buildContactChip(IconData icon, String text, ColorScheme colors) {
    return Chip(
      avatar: Icon(icon, size: 18, color: colors.primary),
      label: Text(
        text,
        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
      ),
      backgroundColor: colors.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  // Widget _buildCategorySection(
  //   String title,
  //   String? value,
  //   IconData icon,
  //   ColorScheme colors,
  // ) {
  //   if (value == null) return const SizedBox.shrink();

  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       _buildSectionHeader(title, icon, colors),
  //       const SizedBox(height: 12),
  //       Container(
  //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //         decoration: BoxDecoration(
  //           color: colors.secondaryContainer,
  //           borderRadius: BorderRadius.circular(12),
  //         ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Icon(icon, color: colors.onSecondaryContainer, size: 20),
  //             const SizedBox(width: 12),
  //             Text(
  //               value,
  //               style: GoogleFonts.poppins(
  //                 fontWeight: FontWeight.w600,
  //                 color: colors.onSecondaryContainer,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildChipsSection(
    String title,
    List<dynamic>? items,
    IconData icon,
    ColorScheme colors,
  ) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg.jpg"),
          opacity: 0.05,
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(title, icon, colors),
          const SizedBox(height: 16),
          if (items == null || items.isEmpty)
            Text(
              'No $title available',
              style: GoogleFonts.poppins(color: colors.onSurfaceVariant),
            )
          else
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children:
                  items.map((item) {
                    return Chip(
                      label: Text(
                        item,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      backgroundColor: colors.surfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide.none,
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, ColorScheme colors) {
    return Row(
      children: [
        Icon(icon, color: colors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBookButton(ColorScheme colors, String venueId) {
    return ElevatedButton(
      onPressed: () async {
        // Check if user is logged in before allowing booking
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('accessToken');
        
        if (token == null || token.isEmpty) {
          // User is not logged in, show login dialog
          _showLoginRequiredDialog();
        } else {
          // User is logged in, proceed to booking
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookingScreen(venueId: venueId),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14), // Reduced padding
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // Slightly smaller border radius
        elevation: 4,
        shadowColor: colors.primary.withOpacity(0.3),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 20),
          const SizedBox(width: 12),
          Text(
            'Book Now',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.login, color: Colors.green, size: 24),
              const SizedBox(width: 8),
              Text(
                'Sign In Required',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'You need to sign in to book a court. Would you like to sign in now?',
            style: GoogleFonts.poppins(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Later',
                style: GoogleFonts.poppins(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Sign In',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
