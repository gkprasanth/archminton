import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'BookingSummaryScreen.dart';
import '../services/api_service.dart';

class BookingScreen extends StatefulWidget {
  final String venueId;
  const BookingScreen({super.key, required this.venueId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  List<String> sports = [];
  List<IconData> sportIcons = [];
  
  int selectedSport = 0;
  DateTime selectedDate = DateTime.now();
  int? selectedSlotIndex;
  int? selectedCourtIndex;
  
  List<Map<String, dynamic>> courts = [];
  List<Map<String, dynamic>> availableSlots = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    print('🚀 BookingScreen initialized with venueId: ${widget.venueId}');
    _loadCourts();
  }

  // Method to refresh courts and slots after a booking
  void refreshAfterBooking() {
    print('🔄 Refreshing courts and slots after booking...');
    setState(() {
      selectedSlotIndex = null;
      selectedCourtIndex = null;
      isLoading = true;
    });
    _loadCourts();
  }

  IconData _getSportIcon(String sportType) {
    final sport = sportType.toUpperCase();
    if (sport.contains('TENNIS') || sport.contains('BADMINTON')) {
      return Icons.sports_tennis;
    } else if (sport.contains('FOOTBALL') || sport.contains('SOCCER')) {
      return Icons.sports_soccer;
    } else if (sport.contains('CRICKET')) {
      return Icons.sports_cricket;
    } else if (sport.contains('BASKETBALL')) {
      return Icons.sports_basketball;
    } else if (sport.contains('VOLLEYBALL')) {
      return Icons.sports_volleyball;
    } else if (sport.contains('SWIMMING')) {
      return Icons.pool;
    } else if (sport.contains('PICKLE')) {
      return Icons.sports_tennis; // Use tennis icon for pickle ball
    } else if (sport.contains('ARCHMINTON')) {
      return Icons.sports_tennis; // Use tennis icon for archminton
    } else {
      return Icons.sports; // Default sports icon
    }
  }

  void _extractSportsFromCourts() {
    final Set<String> uniqueSports = {};
    
    for (final court in courts) {
      final sportType = court['sportType']?.toString() ?? '';
      if (sportType.isNotEmpty) {
        uniqueSports.add(sportType.toUpperCase());
      }
    }
    
    setState(() {
      sports = uniqueSports.toList()..sort();
      sportIcons = sports.map((sport) => _getSportIcon(sport)).toList();
      selectedSport = sports.isNotEmpty ? 0 : -1; // Reset to first sport or -1 if empty
    });
    
    print('🎯 Extracted ${sports.length} unique sports: $sports');
  }

  String _formatSportName(String sportType) {
    // Convert sport names to more readable format
    final sport = sportType.toUpperCase();
    if (sport.contains('TENNIS ARCHMINTON')) {
      return 'Tennis\nArchminton';
    } else if (sport.contains('PICKLE BALL')) {
      return 'Pickle\nBall';
    } else if (sport.contains('TENNIS')) {
      return 'Tennis';
    } else if (sport.contains('CRICKET')) {
      return 'Cricket';
    } else if (sport.contains('SWIMMING')) {
      return 'Swimming';
    } else if (sport.contains('FOOTBALL')) {
      return 'Football';
    } else if (sport.contains('BASKETBALL')) {
      return 'Basketball';
    } else if (sport.contains('VOLLEYBALL')) {
      return 'Volleyball';
    } else {
      // For any other sport, capitalize first letter and make it shorter if needed
      final words = sport.split(' ');
      if (words.length > 1) {
        return words.map((word) => word.substring(0, 1) + word.substring(1).toLowerCase()).join('\n');
      } else {
        return sport.substring(0, 1) + sport.substring(1).toLowerCase();
      }
    }
  }

  Future<void> _loadCourts() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      print('🔍 Loading courts for venue: ${widget.venueId}');
      final courtsList = await ApiService.getCourts(widget.venueId);
      print('📊 Courts loaded: ${courtsList.length}');
      
      // Fetch time slots for each court
      final courtsWithTimeSlots = <Map<String, dynamic>>[];
      
      for (final court in courtsList) {
        final courtId = court['id'] as int;
        print('🕐 Fetching time slots for court: ${court['name']} (ID: $courtId)');
        
        final timeSlots = await ApiService.getCourtTimeSlots(courtId);
        
        // Add time slots to court data
        final courtWithSlots = Map<String, dynamic>.from(court);
        courtWithSlots['timeSlots'] = timeSlots;
        courtsWithTimeSlots.add(courtWithSlots);
        
        print('   ✅ Added ${timeSlots.length} time slots to ${court['name']}');
      }
      
      setState(() {
        courts = courtsWithTimeSlots;
        isLoading = false;
      });
      
      print('🏟️ Total courts with time slots: ${courts.length}');
      for (int i = 0; i < courts.length; i++) {
        final court = courts[i];
        print('Court $i: ${court['name']} - Sport: ${court['sportType']} - TimeSlots: ${court['timeSlots']?.length ?? 0}');
      }
      
      _extractSportsFromCourts();
      _filterCourtsBySport();
    } catch (e) {
      print('❌ Error loading courts: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterCourtsBySport() async {
    if (sports.isEmpty || selectedSport < 0 || selectedSport >= sports.length) {
      print('⚠️ No sports available yet or invalid selection');
      setState(() {
        availableSlots = [];
      });
      return;
    }
    
    final selectedSportName = sports[selectedSport];
    print('🎯 Filtering for sport: $selectedSportName');
    print('📅 Selected date: $selectedDate (weekday: ${selectedDate.weekday})');
    
    // Check if selected date is valid based on venue type
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDateOnly = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    
    if (selectedDateOnly.isBefore(today)) {
      print('⚠️ Cannot book for past dates.');
      setState(() {
        availableSlots = [];
      });
      return;
    }
    
    final filteredCourts = courts.where((court) => 
      court['sportType'].toString().toUpperCase().contains(selectedSportName)
    ).toList();
    
    // Check if this is a private venue (check any court's venue type)
    bool isPrivateVenue = false;
    if (filteredCourts.isNotEmpty) {
      final firstCourt = filteredCourts.first;
      final venue = firstCourt['venue'];
      if (venue != null) {
        final venueType = venue['venueType']?.toString().toUpperCase();
        final societyId = venue['societyId'];
        // Private venue if venueType is PRIVATE or if it has a societyId
        isPrivateVenue = venueType == 'PRIVATE' || societyId != null;
      }
    }
    
    // For private venues, restrict to today and tomorrow only
    if (isPrivateVenue) {
      final tomorrow = today.add(const Duration(days: 1));
      if (selectedDateOnly.isAfter(tomorrow)) {
        print('⚠️ Private venues can only be booked for today or tomorrow.');
        setState(() {
          availableSlots = [];
        });
        return;
      }
    }
    
    print('🏟️ Filtered courts: ${filteredCourts.length}');
    for (final court in filteredCourts) {
      print('  - ${court['name']} (${court['sportType']})');
    }
    
    setState(() {
      isLoading = true;
    });
    
    // Group time slots by time for display
    final Map<String, List<Map<String, dynamic>>> slotsByTime = {};
    
    // Format date for API call (YYYY-MM-DD)
    final dateString = '${selectedDate.year.toString().padLeft(4, '0')}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
    
    for (final court in filteredCourts) {
      final timeSlots = court['timeSlots'] as List;
      // Note: DateTime.weekday returns 1-7 (Monday=1, Sunday=7)
      // We need to convert to 0-6 format (Sunday=0, Monday=1, etc.)
      final dayOfWeek = selectedDate.weekday == 7 ? 0 : selectedDate.weekday;
      
      print('🕐 Court ${court['name']} has ${timeSlots.length} time slots');
      print('   Looking for dayOfWeek: $dayOfWeek (original weekday: ${selectedDate.weekday})');
      
      // Get availability data for this court
      final availabilityData = await ApiService.getCourtAvailability(court['id'], dateString);
      final availableSlotIds = <int>{};
      
      if (availabilityData != null && availabilityData['availability'] is List) {
        final availabilityList = availabilityData['availability'] as List;
        for (final availSlot in availabilityList) {
          if (availSlot['isAvailable'] == true) {
            availableSlotIds.add(availSlot['id'] as int);
          }
        }
        print('   📊 Available slot IDs: $availableSlotIds');
      } else {
        print('   ⚠️ No availability data received for court ${court['id']}');
        // If we can't get availability data, assume all slots are available (fallback)
        for (final slot in timeSlots) {
          if (slot['dayOfWeek'] == dayOfWeek && slot['isActive']) {
            availableSlotIds.add(slot['id'] as int);
          }
        }
      }
      
      for (final slot in timeSlots) {
        print('   Slot: dayOfWeek=${slot['dayOfWeek']}, isActive=${slot['isActive']}, time=${slot['startTime']}-${slot['endTime']}, id=${slot['id']}');
        
        if (slot['dayOfWeek'] == dayOfWeek && slot['isActive']) {
          // Check if this is a past time slot for today (applies to all venue types)
          final isToday = selectedDateOnly.isAtSameMomentAs(today);
          if (isToday) {
            // Parse slot start time and compare with current time
            try {
              final slotStartTime = slot['startTime'] as String;
              final slotTimeParts = slotStartTime.split(':');
              final slotHour = int.parse(slotTimeParts[0]);
              final slotMinute = int.parse(slotTimeParts[1]);
              
              final slotDateTime = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                slotHour,
                slotMinute,
              );
              
              // Skip past time slots for today (add 15 minute buffer for all venues)
              if (slotDateTime.isBefore(now.add(const Duration(minutes: 15)))) {
                print('   ⏰ Skipped past slot: ${slot['startTime']}-${slot['endTime']}');
                continue;
              }
            } catch (e) {
              print('   ⚠️ Error parsing slot time: $e');
              continue;
            }
          }
          
          final slotId = slot['id'] as int;
          final isAvailable = availableSlotIds.contains(slotId);
          
          if (isAvailable) {
            final timeKey = '${slot['startTime']} - ${slot['endTime']}';
            if (!slotsByTime.containsKey(timeKey)) {
              slotsByTime[timeKey] = [];
            }
            slotsByTime[timeKey]!.add({
              'court': court,
              'slot': slot,
              'courtName': court['name'],
              'courtId': court['id'],
              'slotId': slot['id'],
              'isAvailable': true,
            });
            print('   ✅ Added available slot: $timeKey');
          } else {
            print('   🔒 Skipped booked slot: ${slot['startTime']}-${slot['endTime']}');
          }
        } else {
          print('   ❌ Skipped slot: dayOfWeek mismatch or inactive');
        }
      }
    }
    
    print('📋 Final available slots: ${slotsByTime.length}');
    slotsByTime.forEach((time, courts) {
      print('  $time: ${courts.length} courts');
    });
    
    setState(() {
      availableSlots = slotsByTime.entries.map((entry) => {
        'time': entry.key,
        'courts': entry.value,
      }).toList();
      selectedSlotIndex = null;
      selectedCourtIndex = null;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedSportName = sports.isNotEmpty && selectedSport < sports.length 
        ? sports[selectedSport] 
        : '';

        return Scaffold(
      appBar: AppBar(
        title: Text(
          'Slot Booking',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
            body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg.jpg"),
            opacity: 0.05,
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Fixed Header Section
            Container(
              color: Colors.white.withOpacity(0.9),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // Sports Tabs
                  if (sports.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(sports.length, (i) {
                          final isSelected = i == selectedSport;
                          return GestureDetector(
                            onTap: () {
                              if (i < sports.length) {
                                setState(() {
                                  selectedSport = i;
                                  selectedSlotIndex = null;
                                  selectedCourtIndex = null;
                                });
                                _filterCourtsBySport();
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary.withOpacity(0.2) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isSelected ? colorScheme.primary : Colors.grey[200],
                                    child: Icon(
                                      i < sportIcons.length ? sportIcons[i] : Icons.sports,
                                      color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    i < sports.length ? _formatSportName(sports[i]) : 'Unknown',
                                    style: GoogleFonts.poppins(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? colorScheme.primary : Colors.black,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  const SizedBox(height: 16),
                  // Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          final now = DateTime.now();
                          final today = DateTime(now.year, now.month, now.day);
                          
                          // Check if this is a private venue
                          bool isPrivateVenue = false;
                          if (courts.isNotEmpty) {
                            final selectedSportName = sports.isNotEmpty && selectedSport < sports.length 
                                ? sports[selectedSport] 
                                : '';
                            final filteredCourts = courts.where((court) => 
                              court['sportType'].toString().toUpperCase().contains(selectedSportName)
                            ).toList();
                            
                            if (filteredCourts.isNotEmpty) {
                              final firstCourt = filteredCourts.first;
                              final venue = firstCourt['venue'];
                              if (venue != null) {
                                final venueType = venue['venueType']?.toString().toUpperCase();
                                final societyId = venue['societyId'];
                                isPrivateVenue = venueType == 'PRIVATE' || societyId != null;
                              }
                            }
                          }
                          
                          final lastDate = isPrivateVenue 
                              ? today.add(const Duration(days: 1)) // Tomorrow for private venues
                              : today.add(const Duration(days: 30)); // 30 days for public venues
                          
                          final helpText = isPrivateVenue 
                              ? 'Select booking date (Today or Tomorrow only)'
                              : 'Select booking date';
                          
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: today,
                            lastDate: lastDate,
                            helpText: helpText,
                          );
                          if (picked != null) {
                            setState(() {
                              selectedDate = picked;
                              selectedSlotIndex = null;
                              selectedCourtIndex = null;
                            });
                            _filterCourtsBySport();
                          }
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('dd MMM - EEEE').format(selectedDate)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),

                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            // Scrollable Content Section
            Expanded(
              child: isLoading 
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading courts and time slots...'),
                      ],
                    ),
                  )
                : availableSlots.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            sports.isEmpty 
                              ? 'Loading sports...'
                              : 'No slots available for ${_formatSportName(sports[selectedSport])} on ${DateFormat('dd MMM').format(selectedDate)}',
                            style: GoogleFonts.poppins(),
                            textAlign: TextAlign.center,
                          ),

                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: availableSlots.length,
                        itemBuilder: (context, slotIdx) {
                          final slotData = availableSlots[slotIdx];
                          final timeSlot = slotData['time'];
                          final courts = slotData['courts'] as List;
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 100,
                                  child: Text(timeSlot, style: GoogleFonts.poppins(fontSize: 14)),
                                ),
                                Expanded(
                                  child: Wrap(
                                    spacing: 8,
                                    children: List.generate(courts.length, (courtIdx) {
                                      final courtData = courts[courtIdx];
                                      final isSelected = selectedSlotIndex == slotIdx && selectedCourtIndex == courtIdx;
                                      
                                      // Get price for this specific court/slot
                                      final slot = courtData['slot'];
                                      final court = courtData['court'];
                                      final slotPrice = slot['pricePerHour'];
                                      final courtPrice = court['pricePerHour'];
                                      final price = (slotPrice != null && slotPrice != 0) 
                                          ? slotPrice 
                                          : (courtPrice ?? 300);
                                      
                                                                            return ChoiceChip(
                                        label: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              courtData['courtName'],
                                              style: GoogleFonts.poppins(
                                                color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            Text(
                                              '₹${price}/hr',
                                              style: GoogleFonts.poppins(
                                                color: isSelected 
                                                    ? colorScheme.onPrimary.withOpacity(0.8) 
                                                    : colorScheme.primary.withOpacity(0.7),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                        selected: isSelected,
                                        onSelected: (_) {
                                          setState(() {
                                            selectedSlotIndex = slotIdx;
                                            selectedCourtIndex = courtIdx;
                                          });
                                        },
                                        selectedColor: colorScheme.primary,
                                        labelPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      );
                                    }),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
            // Fixed BOOK NOW button at the bottom
            if (!isLoading && availableSlots.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: (selectedSlotIndex != null && selectedCourtIndex != null && sports.isNotEmpty)
                          ? () {
                              // Always show sport rules as confirmation before proceeding
                              final sportName = _formatSportName(selectedSportName);
                              _showSportRules(context, sportName);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[400],
                        disabledForegroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'BOOK NOW',
                        style: GoogleFonts.poppins(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showSportRules(BuildContext context, String sportName) {
    final rules = _getSportRules(sportName);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.rule,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    '$sportName Rules',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Please read and acknowledge the following rules before proceeding with your booking.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Rules list with better styling
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: rules.map((rule) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          rule,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToSummary();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      'I Agree & Continue',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Method kept for potential future use, but currently not displayed in UI
  String _getCurrentPrice() {
    if (selectedSlotIndex != null && selectedCourtIndex != null && 
        selectedSlotIndex! < availableSlots.length) {
      final slotData = availableSlots[selectedSlotIndex!];
      final courts = slotData['courts'] as List;
      
      if (selectedCourtIndex! < courts.length) {
        final courtData = courts[selectedCourtIndex!];
        final slot = courtData['slot'];
        final court = courtData['court'];
        
        // Use slot-specific price first, then fallback to court price
        final slotPrice = slot['pricePerHour'];
        final courtPrice = court['pricePerHour'];
        
        if (slotPrice != null && slotPrice != 0) {
          return '₹${slotPrice}/hr';
        } else if (courtPrice != null && courtPrice != 0) {
          return '₹${courtPrice}/hr';
        }
      }
    }
    
    return '₹300/hr'; // Default fallback
  }

  List<String> _getSportRules(String sportName) {
    final sport = sportName.toLowerCase().replaceAll('\n', ' ');
    
    if (sport.contains('football')) {
      return [
        'Maximum of 14 players is permitted.',
        'Barefoot not allowed.',
        'All guidelines of Archminton need to be followed.',
        'Equipments are provided.',
        'Sportswear like track pants / shorts with a t-shirt is mandatory.',
      ];
    } else if (sport.contains('badminton')) {
      return [
        'Barefoot not allowed. Sportswear like track pants / shorts / skirts with a t-shirt is mandatory.',
        'Maximum of 6 players per court is permitted.',
        'Clean NON-MARKING GUMSOLE BADMINTON SHOES are mandatory.',
        'All guidelines of Archminton need to be followed.',
        'Players need to bring their own equipment – shoes and rackets.',
        'Equipment is available for lease / sale at the sports shop.',
        'Any damage to the equipment will be charged.',
        'Tournament conduction is not allowed through app booking.',
      ];
    } else if (sport.contains('tennis')) {
      return [
        'A maximum of 4 players per court is permitted. NON-MARKING TENNIS SHOES are mandatory. Sports Attire is mandatory. Players need to bring their own equipment. Equipment is available for lease/sale at the sports shop. The customer is responsible for any damage or loss incurred to the leased items. Any damage to the equipment will be charged. All safety guidelines of Archminton need to be followed.',
      ];
    } else if (sport.contains('table tennis') || sport.contains('ping pong')) {
      return [
        'Maximum of 4 players per court is permitted.',
        'Sportswear like track pants / shorts / skirts with a t-shirt is mandatory.',
        'Any damage to the equipment will be charged.',
        'All guidelines of Archminton need to be followed.',
        'Tournament conduction is not allowed through app booking.',
        'Please email us at events@nplay.in for bulk/ tournament booking.',
      ];
    } else if (sport.contains('cricket nets') || sport.contains('cricket')) {
      return [
        'Balls are provided by Archminton only for the Net with bowling machine.',
        'Customers are responsible for their safety. All customers requested to get their own protective cricket gear while playing in nets.',
        'A maximum of 3 players will be allowed to play in each slot.',
        'All children below the age of 18 years need to be accompanied by an adult while using the net facility and must use the helmet and protective gear.',
        'All players should wear suitable sportswear including footwear without spikes or any sole that damage the turf. No item including kit bags should be placed in the cricket net to avoid damage and injuries to the players.',
      ];
    } else if (sport.contains('basketball')) {
      return [
        'Maximum of 8 players per half court is permitted.',
        'Basketball shoes are mandatory.',
        'Spike shoes not allowed.',
        'Ball will be provided.',
        'Sportswear like track pants / shorts / skirts with a t-shirt is mandatory.',
        'All guidelines of Archminton need to be followed.',
        'Tournament conduction is not allowed through app booking.',
        'Please email us at events@nplay.in for bulk/ tournament booking.',
      ];
    } else if (sport.contains('swimming')) {
      return [
        'A swimming costume including a cap is mandatory.',
        'One person per one booking only.',
        'Shower before dipping into the pool.',
        'All safety guidelines of Archminton need to be followed.',
      ];
    } else if (sport.contains('squash')) {
      return [
        'A Maximum of 4 players per court is permitted.',
        'Sportswear like track pants / shorts / skirts with a t-shirt is mandatory.',
        'Clean NON-MARKING GUMSOLE SHOES are mandatory.',
        'Players need to bring their own equipment – shoes and rackets.',
        'Equipment is available for lease/sale at the sports shop.',
        'Any damage to the equipment will be charged.',
        'All guidelines of Archminton need to be followed.',
        'Tournament conduction is not allowed through app booking.',
        'Please email us at events@nplay.in for bulk/ tournament booking.',
      ];
    } else if (sport.contains('pickleball')) {
      return [
        'Barefoot not allowed. Sportswear like track pants / shorts / skirts with a t-shirt is mandatory.',
        'Maximum of 6 players per court is permitted.',
        'All guidelines of Archminton need to be followed.',
        'Players need to bring their own equipment – shoes and rackets.',
        'Equipment is available for lease / sale at the sports shop.',
        'Any damage to the equipment will be charged.',
        'Tournament conduction is not allowed through app booking.',
        'Please email us at events@nplay.in for bulk/ tournament booking.',
      ];
    } else if (sport.contains('box cricket')) {
      return [
        'Maximum of 14 players is permitted.',
        'Barefoot not allowed.',
        'All guidelines of Archminton need to be followed.',
        'Equipments are provided.',
        'Sportswear like track pants / shorts with a t-shirt is mandatory.',
      ];
    } else if (sport.contains('cue sport') || sport.contains('pool') || sport.contains('billiards')) {
      return [
        'A maximum of 6 players are allowed.',
      ];
    } else {
      return [
        'Follow all venue guidelines.',
        'Appropriate sportswear required.',
        'Equipment may be provided or rented.',
        'Respect other players and facilities.',
        'Arrive on time for your booking.',
        'All guidelines of Archminton need to be followed.',
      ];
    }
  }

  void _navigateToSummary() {
    if (selectedSlotIndex == null || selectedCourtIndex == null || sports.isEmpty) {
      print('❌ Cannot navigate: selectedSlotIndex=$selectedSlotIndex, selectedCourtIndex=$selectedCourtIndex, sports.length=${sports.length}');
      return;
    }
    
    if (selectedSlotIndex! >= availableSlots.length) {
      print('❌ Invalid slot index: $selectedSlotIndex >= ${availableSlots.length}');
      return;
    }
    
    final slotData = availableSlots[selectedSlotIndex!];
    final courts = slotData['courts'] as List;
    
    if (selectedCourtIndex! >= courts.length) {
      print('❌ Invalid court index: $selectedCourtIndex >= ${courts.length}');
      return;
    }
    
    final courtData = courts[selectedCourtIndex!];
    final court = courtData['court'];
    
    final slot = courtData['slot'];
    
    // Check if the slot is already booked
    final isBooked = slot['status']?.toString().toLowerCase() == 'booked' ||
                     slot['isBooked'] == true ||
                     slot['available'] == false;
    
    if (isBooked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This slot has already been booked. Please select another slot.'),
          backgroundColor: Colors.red,
        ),
      );
      // Refresh the slots to get updated availability
      refreshAfterBooking();
      return;
    }
    
    final slotPrice = slot['pricePerHour'];
    final courtPrice = court['pricePerHour'];
    
    final bookingData = {
      'courtId': courtData['courtId'],
      'slotId': courtData['slotId'],
      'courtName': courtData['courtName'],
      'sportType': court['sportType'],
      'venueName': court['venue']?['name'] ?? 'Unknown Venue',
      'venueLocation': court['venue']?['location'] ?? 'Unknown Location',
      'date': selectedDate,
      'timeSlot': slotData['time'],
      'price': int.tryParse(slotPrice?.toString() ?? courtPrice?.toString() ?? '0') ?? 300,
    };
    
    print('🎯 Navigating to summary with data: $bookingData');
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingSummaryScreen(
          bookingData: bookingData,
          onBookingSuccess: refreshAfterBooking,
        ),
      ),
    );
  }
}
