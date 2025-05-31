import 'package:flutter/material.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<Map<String, String>> _notifications = [
    {
      'title': 'New Tournament',
      'body': 'Join the Spring Smash Open this weekend!',
      'time': '2h ago',
      'avatar': 'https://i.pravatar.cc/150?img=1'
    },
    {
      'title': 'Match Reminder',
      'body': 'Your doubles match is tomorrow at 5:30 PM.',
      'time': '1d ago',
      'avatar': 'https://i.pravatar.cc/150?img=2'
    },
    {
      'title': 'Friend Request',
      'body': 'Alex sent you a friend request.',
      'time': '3d ago',
      'avatar': 'https://i.pravatar.cc/150?img=3'
    },
  ];

  Future<void> _refresh() async {
    // Simulate refresh delay
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      // Update notification list if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
        backgroundColor: Colors.green,
      ),
      body: _notifications.isEmpty
          ? const _EmptyState()
          : RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _notifications.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notif = _notifications[index];
                  return _NotificationCard(
                    title: notif['title']!,
                    body: notif['body']!,
                    time: notif['time']!,
                    avatarUrl: notif['avatar']!,
                  );
                },
              ),
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final String avatarUrl;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.time,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(backgroundImage: NetworkImage(avatarUrl)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(body),
        trailing: Text(
          time,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 20),
            const Text(
              "No notifications yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              "When something important happens, you'll find it here.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
