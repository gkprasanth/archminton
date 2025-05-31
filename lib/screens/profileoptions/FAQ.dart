import 'package:flutter/material.dart';

class FAQ {
  final String question;
  final String answer;
  final IconData icon;

  FAQ(this.question, this.answer, this.icon);
}

class FAQScreen extends StatefulWidget {
  const FAQScreen({super.key});

  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FAQScreen> {
  final List<FAQ> allFAQs = [
    FAQ('How do I book a court?', 'To book a court, go to the \'Book\' section in the app, select the date and time, and choose the court you want to book. Follow the prompts to complete the booking.', Icons.calendar_today),
    FAQ('What are the pricing options?', 'We offer various pricing options including pay-per-session, monthly memberships, and annual memberships. You can view the details in the \'Pricing\' section of the app.', Icons.attach_money),
    FAQ('Can I cancel a booking?', 'Yes, you can cancel a booking up to 24 hours before the scheduled time. Go to \'My Bookings\' and select the booking you want to cancel.', Icons.cancel),
    FAQ('What equipment do I need to bring?', 'For badminton, you need to bring your own racket. We provide shuttlecocks. For other sports, please check the specific requirements in the \'Sports\' section.', Icons.sports_tennis),
    FAQ('Are the coaches certified?', 'Yes, all our coaches are certified and have extensive experience in their respective sports.', Icons.verified_user),
    FAQ('What are the hours of operation?', 'We are open from 6 AM to 10 PM every day.', Icons.access_time),
    FAQ('What safety measures are in place for COVID-19?', 'We follow all local health guidelines, including regular sanitization, mandatory masks, and social distancing.', Icons.health_and_safety),
  ];

  List<FAQ> filteredFAQs = [];
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredFAQs = allFAQs;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FAQs'),
          backgroundColor: Colors.green[800],
          foregroundColor: Colors.white,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search FAQs',
                  prefixIcon: const Icon(Icons.search, color: Colors.green),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              searchQuery = '';
                              filteredFAQs = allFAQs;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.green, width: 2),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    filteredFAQs = allFAQs
                        .where((faq) => faq.question.toLowerCase().contains(searchQuery.toLowerCase()))
                        .toList();
                  });
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredFAQs.length,
                itemBuilder: (context, index) {
                  final faq = filteredFAQs[index];
                  return Card(
                    color: Colors.green[50],
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      leading: Icon(faq.icon, color: Colors.green),
                      title: Text(
                        faq.question,
                        style: TextStyle(color: Colors.green[900], fontWeight: FontWeight.bold),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            faq.answer,
                            style: TextStyle(color: Colors.green[900], fontSize: 16, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Still have questions? Contact us at support@archminton.com',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}