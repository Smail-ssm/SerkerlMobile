import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:checkout_screen_ui/checkout_page/checkout_page.dart';
import 'package:checkout_screen_ui/models/price_item.dart';
import 'package:checkout_screen_ui/ui_components/pay_button.dart';
import '../services/SubscriptionService.dart';
import '../model/subscription.dart';
import '../model/client.dart';
import '../util/theme.dart';

class BalanceAndPricingPage extends StatefulWidget {
  final Client? client;

  const BalanceAndPricingPage({Key? key, required this.client}) : super(key: key);

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
  final GlobalKey<CardPayButtonState> _payBtnKey = GlobalKey<CardPayButtonState>();

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
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (userDoc.exists) {
        setState(() {
          _balance = (userDoc.get('balance') as num).toDouble();
          widget.client?.balance = _balance;
        });
      }
    } catch (e) {
      print('Error fetching balance: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred while fetching balance')),
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
      List<Subscription> subscriptions = await _subscriptionService.getAllSubscriptions();
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

  Future<void> _activatePlan(Subscription subscription) async {
    try {
      await _subscriptionService.activateSubscription(subscription.id);
      _showSuccessDialog('Plan activated successfully!');
      // Optionally, update balance or other user data here
      _fetchLatestBalance(); // Refresh balance
    } catch (e) {
      _showErrorDialog('Failed to activate plan');
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

  // Method to show the checkout screen
  void _showCheckoutScreen(Subscription subscription) {
    final List<PriceItem> priceItems = [
      PriceItem(
          name: subscription.title,
          quantity: 1,
          itemCostCents: (subscription.price * 100).toInt()),
    ];

    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => Theme(
        data: lightTheme,  // Force light theme
        child: Scaffold(
          backgroundColor: Colors.white,  // Set background color to white
          appBar: AppBar(
            title: const Text('Subscription Service'),
          ),
          body: CheckoutPage(
            data: CheckoutData(
              priceItems: priceItems,
              taxRate: 0.07,
              payToName: '',
              displayNativePay: false,
              isApple: Platform.isIOS,
              onCardPay: (paymentInfo, checkoutResults) {
                print('Card Payment Clicked');
                _activatePlan(subscription);
                Navigator.of(context).pop(); // Close checkout page after payment
              },
              onBack: () => Navigator.of(context).pop(),
              displayEmail: true,
              lockEmail: false,
              initEmail: 'user@example.com',
              initPhone: '1234567890',
              initBuyerName: 'John Doe',
              cashPrice: subscription.price,
              formKey: _formKey,
              payBtnKey: _payBtnKey,
            ),
            footer: _buildFooter(context),
          ),
        ),
      ),
    ));
  }

  Widget _buildFooter(BuildContext context) {
    final theme = Theme.of(context);
    final cancelColor = theme.colorScheme.error;
    final confirmColor = theme.colorScheme.secondary;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Cancel', style: theme.textTheme.bodyMedium),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: cancelColor,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Implement confirmation logic if needed
              print('Confirm clicked');
            },
            child: Text('Confirm', style: theme.textTheme.bodyMedium),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: confirmColor,
            ),
          ),
        ],
      ),
    );
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

  Widget _buildPricingCard(String title, String duration, String price, {VoidCallback? onTap}) {
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
            if (onTap != null)
              const SizedBox(height: 12),
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
          '${subscription.price} €',
          onTap: () => _showCheckoutScreen(subscription),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display Balance
            Card(
              elevation: 4,
              child: ListTile(
                leading: Icon(Icons.account_balance_wallet, size: 50),
                title: Text(
                  'Current Balance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '\$${_balance.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 24, color: Colors.green),
                ),
                trailing: IconButton(
                  icon: Icon(Icons.refresh, color: Colors.blue, size: 30),
                  onPressed: _fetchLatestBalance,
                  tooltip: 'Refresh Balance',
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionTitle('Pay Per Ride'),
            _buildPricingCard('E-bikes', '24/7', '1 € unlock + 0.26 €/min'),
            _buildPricingCard('Scooters', '24/7', '1 € unlock + 0.26 €/min'),
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
              child: Text(_showSubscriptionDetails ? 'Hide Details' : 'Check out our monthly plans'),
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
      data: lightTheme,  // Force light theme
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Balance & Pricing'),
        ),
        backgroundColor: Colors.white,  // Set background color to white
        body: (_isLoadingBalance)
            ? Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _fetchLatestBalance,
          child: _buildContent(),
        ),
      ),
    );
  }
}
