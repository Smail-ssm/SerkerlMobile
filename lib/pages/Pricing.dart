import 'package:flutter/material.dart';
import '../services/SubscriptionService.dart';
import '../model/subscription.dart';

class PricingWidget extends StatefulWidget {
  const PricingWidget({Key? key}) : super(key: key);

  @override
  State<PricingWidget> createState() => _PricingWidgetState();
}

class _PricingWidgetState extends State<PricingWidget> {
  bool _showSubscriptionDetails = false;
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Subscription> _subscriptions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchSubscriptions();
  }

  Future<void> _fetchSubscriptions() async {
    try {
      List<Subscription> subscriptions =
          await _subscriptionService.getAllSubscriptions();
      setState(() {
        _subscriptions = subscriptions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching subscriptions: $e');
    }
  }

  Future<void> _activatePlan(Subscription subscription) async {
    try {
      await _subscriptionService.activateSubscription(subscription.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Plan activated successfully!')),
      );
    } catch (e) {
      print('Error activating plan: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to activate plan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pricing'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Pay Per Ride'),
              _buildPricingCard('E-bikes', '24/7', '1 € unlock + 0.26 €/min'),
              _buildPricingCard('Scooters', '24/7', '1 € unlock + 0.26 €/min'),
              _buildSectionTitle('Memberships'),
              _buildSubscriptionButton(),
              if (_showSubscriptionDetails)
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _buildSubscriptionDetails(),
              // Display subscription details if available
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }


  Widget _buildPricingCard(String vehicleType, String availability, String price, {VoidCallback? onTap}) {
    return Card(
      elevation: 4, // Slightly more elevation for a more pronounced shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the card
      ),
      margin: const EdgeInsets.symmetric(vertical: 8), // Vertical margin between cards
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding inside the card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    vehicleType,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              availability,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: onTap,
                child: Text('Activate'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Text color on the button
                  minimumSize: Size(120, 36), // Set a fixed size for the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 12), // Add horizontal padding
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSubscriptionButton() {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _showSubscriptionDetails = !_showSubscriptionDetails;
        });
      },
      child: Text(_showSubscriptionDetails
          ? 'Hide Details'
          : 'Check out our monthly plans'),
    );
  }

  Widget _buildSubscriptionDetails() {
    if (_subscriptions.isEmpty) {
      return Center(child: Text('No subscriptions available.'));
    }

    return Column(
      children: _subscriptions.map((subscription) {
        return _buildPricingCard(
          subscription.title,
          '${subscription.validDays} days',
          '${subscription.price} €',
          onTap: () => _showSubscriptionBottomSheet(subscription),
        );
      }).toList(),
    );
  }
  void _showSubscriptionBottomSheet(Subscription subscription) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true, // Allows the bottom sheet to resize to fit the content
      builder: (BuildContext context) {
        return Wrap( // Wrap ensures the bottom sheet sizes itself based on its content
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min, // Ensures the Column only takes up as much height as it needs
                  children: [
                    Text(
                      subscription.title,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('Company: ${subscription.company}', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Activated: ${subscription.activated ? 'Yes' : 'No'}', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Price: ${subscription.price} €', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Valid for: ${subscription.validDays} days', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Unlocks Count: ${subscription.unlocksCount}', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Ride Minutes: ${subscription.rideMinutes}', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Pause Minutes: ${subscription.pauseMinutes}', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Ride Distance: ${subscription.rideDistance} km', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Add your activation logic here
                        Navigator.pop(context); // Close the bottom sheet after activation
                      },
                      child: Text('Activate Plan'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.blueAccent, // Text color on the button
                        minimumSize: Size(double.infinity, 36), // Ensure the button spans the width
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners for the button
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 12), // Horizontal padding
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 24, color: Colors.blueGrey),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
