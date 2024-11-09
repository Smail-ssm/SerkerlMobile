import 'package:checkout_screen_ui/ui_components/pay_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For currency formatting

import '../model/client.dart';
import '../model/subscription.dart';
import '../model/userPurchase.dart';
import '../services/SubscriptionService.dart';
import '../util/theme.dart';
import '../util/util.dart';

class BalanceAndPricingPage extends StatefulWidget {
  final Client? client;

  const BalanceAndPricingPage({Key? key, required this.client})
      : super(key: key);

  @override
  _BalanceAndPricingPageState createState() => _BalanceAndPricingPageState();
}

class _BalanceAndPricingPageState extends State<BalanceAndPricingPage> {
  late double _balance;
  bool _isLoadingBalance = false;
  bool _isLoadingSubscriptions = false;
  bool _showSubscriptionDetails = false;
  final SubscriptionService _subscriptionService = SubscriptionService();
  List<Subscription> _subscriptions = [];

  // GlobalKeys for the checkout form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<CardPayButtonState> _payBtnKey =
      GlobalKey<CardPayButtonState>();

  // Cost per minute in TND
  final double costPerMinute = 0.85; // Adjusted to TND

  // Currency formatter for TND
  final NumberFormat currencyFormat =
      NumberFormat.currency(locale: 'fr_TN', symbol: 'TND ');

  @override
  void initState() {
    super.initState();
    _balance = widget.client!.balance;
    _fetchLatestBalance();
  }

  Future<void> _fetchLatestBalance() async {
    setState(() {
      _isLoadingBalance = true;
    });

    try {
      String userId = widget.client!.userId;
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        setState(() {
          _balance = (userDoc.get('balance') as num).toDouble();
          widget.client?.balance = _balance;
        });
      }
    } catch (e) {
      print('Error fetching balance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while fetching balance')),
      );
    } finally {
      setState(() {
        _isLoadingBalance = false;
      });
    }
  }

  Future<void> _fetchSubscriptions() async {
    setState(() {
      _isLoadingSubscriptions = true;
    });

    try {
      List<Subscription> subscriptions =
          await _subscriptionService.getAllSubscriptions();
      setState(() {
        _subscriptions = subscriptions;
      });
    } catch (e) {
      _showErrorDialog('Error fetching subscriptions');
    } finally {
      setState(() {
        _isLoadingSubscriptions = false;
      });
    }
  }

  // Methods to show dialogs
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Success'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                // Refresh balance or other data if needed
                _fetchLatestBalance();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Method to show a dialog and then simulate the payment process
  void _showCheckoutScreen(Subscription subscription) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Simulate Payment'),
          content: Text(
            'Do you want to simulate a payment for the ${subscription.title} plan?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _simulatePaymentProcess(subscription); // Simulate payment
              },
              child: const Text('Proceed'),
            ),
          ],
        );
      },
    );
  }

  // Simulate payment processing and update balance accordingly
// Simulate payment processing and update balance accordingly
  Future<void> _simulatePaymentProcess(Subscription subscription) async {
    // Simulate a delay for payment processing
    await Future.delayed(const Duration(seconds: 2));

    // Randomly decide if payment is successful or failed
    bool isPaymentSuccessful = true;

    if (isPaymentSuccessful) {
      // Payment succeeded
      // Create a UserPurchase object
      UserPurchase userPurchase = UserPurchase(
        id: UniqueKey().toString(),
        // Generate a unique ID for the purchase
        validFrom: DateTime.now(),
        validTill: DateTime.now().add(Duration(days: subscription.validDays)),
        subscription: subscription,
        status: 'active',
        client: widget.client?.fullName ?? 'Unknown',
        // Adjust based on your Client model
        phone: widget.client?.phoneNumber ?? 'Unknown',
        // Adjust based on your Client model
        unlocksCount: subscription.unlocksCount,
        rideMinutes: subscription.rideMinutes,
        pauseMinutes: subscription.pauseMinutes,
        rideDistance: subscription.rideDistance,
      );

      // Save the UserPurchase to Firebase
      await _saveUserPurchase(userPurchase);
      await _updateUserBalance(subscription.price);

      _showSuccessDialog('Payment successful! Your balance has been updated.');

      // Log the result
      print('Payment successful for subscription: ${subscription.title}');
      print('New balance: $_balance');
    } else {
      // Payment failed
      _showErrorDialog('Payment failed. Please try again.');

      // Log the result
      print('Payment failed for subscription: ${subscription.title}');
    }
  }

// Save the UserPurchase to Firebase
   Future<void> _saveUserPurchase(UserPurchase userPurchase) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Define the environment collection, replace 'preprod' with your actual environment
      String env = getFirestoreDocument();

      // Generate a Firestore-like unique ID for the purchase
      String purchaseId = firestore.collection('dummy').doc().id;

      // Construct the path to the user's purchases collection
      String userId = widget.client!.userId;
      CollectionReference purchasesCollection = firestore
          .collection(env) // 'preprod'
          .doc('UserPurchases')
          .collection('UserPurchases')
          .doc(userId)
          .collection('Purchases');

      // Convert the UserPurchase object to JSON
      Map<String, dynamic> purchaseData = userPurchase.toJson();

      // Save the purchase data with a generated purchase ID
      await purchasesCollection.doc(purchaseId).set(purchaseData);

      if (kDebugMode) {
        print('UserPurchase saved successfully under the specified path.');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving UserPurchase: $e');
      }
      // Handle the error appropriately in your app
      _showErrorDialog('An error occurred while saving your purchase.');
    }
  }

  // Update the user's balance both locally and in Firestore
  Future<void> _updateUserBalance(double amount) async {
    try {
      String userId = widget.client!.userId;
      double newBalance = _balance + amount;

// Use the same Firestore path as in fetchClientData
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      final usersCollection = firestore.collection(getFirestoreDocument());

// Update Firestore
      await usersCollection
          .doc('users')
          .collection('users')
          .doc(userId)
          .update({'balance': newBalance});
      // Update local state
      setState(() {
        _balance = newBalance;
        widget.client?.balance = newBalance;
      });
    } catch (e) {
      print('Error updating balance: $e');
      _showErrorDialog('An error occurred while updating your balance.');
    }
  }

  // UI Building Methods
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPricingCard(String title, String duration, String price,
      {VoidCallback? onTap}) {
    return Card(
      elevation: 4,
      // Slightly more elevation for a more pronounced shadow
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners for the card
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      // Vertical margin between cards
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
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  price,
                  style: const TextStyle(
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
              duration,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
            if (onTap != null) const SizedBox(height: 12),
            if (onTap != null)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: onTap,
                  child: const Text('Activate'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(120, 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionDetails() {
    if (_subscriptions.isEmpty) {
      return const Center(child: Text('No subscriptions available.'));
    }

    return Column(
      children: _subscriptions.map((subscription) {
        return _buildPricingCard(
          subscription.title,
          '${subscription.validDays} days',
          currencyFormat.format(subscription.price),
          onTap: () => _showCheckoutScreen(subscription),
        );
      }).toList(),
    );
  }

  // Calculate ride time based on balance
  double _calculateRideTime(double balance) {
    // Calculate the total minutes based on balance and cost per minute
    double totalMinutes = balance / costPerMinute;
    return totalMinutes;
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Balance with Ride Time
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Balance in TND on the left
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Balance',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormat.format(_balance),
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    // Divider between balance and ride time
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey[300],
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    // Equivalent ride time on the right
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Ride Time',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_calculateRideTime(_balance).toStringAsFixed(1)} mins',
                            style: const TextStyle(
                                fontSize: 24,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Pay Per Ride'),
            _buildPricingCard('E-bikes', '24/7', '1 TND unlock + 0.85 TND/min'),
            _buildPricingCard(
                'Scooters', '24/7', '1 TND unlock + 0.85 TND/min'),
            _buildSectionTitle('Memberships'),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _showSubscriptionDetails = !_showSubscriptionDetails;
                  if (_showSubscriptionDetails && _subscriptions.isEmpty) {
                    _fetchSubscriptions();
                  }
                });
              },
              child: Text(_showSubscriptionDetails
                  ? 'Hide Details'
                  : 'Check out our monthly plans'),
            ),
            if (_showSubscriptionDetails)
              _isLoadingSubscriptions
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSubscriptionDetails(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme, // Force light theme
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Balance & Pricing'),
        ),
        backgroundColor: Colors.white,
        // Set background color to white
        body: (_isLoadingBalance)
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _fetchLatestBalance,
                child: _buildContent(),
              ),
      ),
    );
  }
}
