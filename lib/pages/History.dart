import 'package:flutter/material.dart';

import '../model/HistoryModel.dart';
import '../model/client.dart';

class HistoryPage extends StatefulWidget {
  final Client? client;

  const HistoryPage({Key? key, required this.client}) : super(key: key);

  @override
  _HistoryState createState() => _HistoryState();
}

class _HistoryState extends State<HistoryPage> {
  // Sample ride history data (replace with actual data fetching logic)
  final List<HistoryModel> _rideHistory = [
    HistoryModel(
      date: DateTime(2024, 10, 26),
      origin: 'Tunis City Center',
      destination: 'La Marsa Beach',
      duration: const Duration(minutes: 30),
      cost: 5.00,
    ),
    HistoryModel(
      date: DateTime(2024, 10, 25),
      origin: 'Carthage Ruins',
      destination: 'Bardo Museum',
      duration: const Duration(minutes: 20),
      cost: 3.75,
    ),
    // Add more ride history items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride history'),
      ),
      body: ListView.builder(
        itemCount: _rideHistory.length,
        itemBuilder: (context, index) {
          final ride = _rideHistory[index];
          return RideHistoryCard(ride: ride);
        },
      ),
    );
  }
}

class RideHistoryCard extends StatelessWidget {
  final HistoryModel ride;

  const RideHistoryCard({Key? key, required this.ride}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ride.date.day}/${ride.date.month}/${ride.date.year}',
              style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('From: ${ride.origin}'),
                Text('To: ${ride.destination}'),
              ],
            ),
            const SizedBox(height: 8.0),
            Row(
              children: [
                Text('Duration: ${ride.duration.inMinutes} minutes'),
                const Spacer(),
                Text('Cost: \$ ${ride.cost.toStringAsFixed(2)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
