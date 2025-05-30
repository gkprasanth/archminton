import 'package:flutter/material.dart';

class MyBookingsScreen extends StatelessWidget {
  const MyBookingsScreen({super.key});

  final List<Map<String, String>> sampleBookings = const [
    {
      "venue": "City Sports Complex",
      "sport": "Tennis",
      "date": "2025-06-01",
      "time": "10:00 AM - 11:00 AM"
    },
    {
      "venue": "Elite Gym & Arena",
      "sport": "Badminton",
      "date": "2025-06-03",
      "time": "5:00 PM - 6:00 PM"
    },
    {
      "venue": "Sunrise Stadium",
      "sport": "Football",
      "date": "2025-06-05",
      "time": "7:00 PM - 9:00 PM"
    },
    {
      "venue": "Greenfield Courts",
      "sport": "Basketball",
      "date": "2025-06-07",
      "time": "6:00 AM - 7:30 AM"
    },
  ];

  IconData getSportIcon(String sport) {
    switch (sport.toLowerCase()) {
      case 'tennis':
        return Icons.sports_tennis;
      case 'badminton':
        return Icons.sports;
      case 'football':
        return Icons.sports_soccer;
      case 'basketball':
        return Icons.sports_basketball;
      default:
        return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sampleBookings.length,
        itemBuilder: (context, index) {
          final booking = sampleBookings[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [Colors.deepPurple.shade300, Colors.deepPurple.shade500],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            margin: const EdgeInsets.only(bottom: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {}, // Add tap behavior if needed
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['venue']!,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(getSportIcon(booking['sport']!), color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                            booking['sport']!,
                            style: const TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            booking['date']!,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            booking['time']!,
                            style: const TextStyle(fontSize: 14, color: Colors.white),
                          ),
                        ],
                      ),
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
}
