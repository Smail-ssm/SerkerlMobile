import 'package:flutter/material.dart';

import 'NotificationItem.dart';

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;

  const NotificationCard({required this.notification});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Set width and potentially height constraints as needed
      width: double.infinity, // Ensures card takes full width
      constraints: BoxConstraints(
        minHeight: 20.0, // Adjust minimum height if desired
      ),
      margin: EdgeInsets.symmetric(
          horizontal: 8.0, vertical: 8.0), // Remove horizontal margin
      decoration: BoxDecoration(
        color: Colors.white, // Set background color
        borderRadius: BorderRadius.circular(8.0), // Apply border radius
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(1), // Add subtle shadow
            spreadRadius: 1.0, // Adjust shadow spread
            blurRadius: 2.0, // Adjust shadow blur
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${notification.title}',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text('Message: ${notification.message}'),
            SizedBox(height: 8.0),
            Text(
              'Received: ${notification.date.day}/${notification.date.month}/${notification.date.year}',
              style: TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
