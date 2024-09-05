import 'dart:io';
import 'package:checkout_screen_ui/checkout_page/checkout_page.dart';
import 'package:checkout_screen_ui/models/price_item.dart';
import 'package:checkout_screen_ui/ui_components/pay_button.dart';
import 'package:flutter/material.dart';
import '../services/SubscriptionService.dart';
import '../model/subscription.dart';
import '../util/theme.dart';

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

  // GlobalKeys defined once to avoid conflicts
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<CardPayButtonState> _payBtnKey =
      GlobalKey<CardPayButtonState>();

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
      _showErrorDialog('Error fetching subscriptions');
    }
  }

  Future<void> _activatePlan(Subscription subscription) async {
    try {
      await _subscriptionService.activateSubscription(subscription.id);
      _showSuccessDialog('Plan activated successfully!');
    } catch (e) {
      _showErrorDialog('Failed to activate plan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: lightTheme,  // Force light theme
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pricing'),
        ),
        backgroundColor: Colors.white,  // Set background color to white
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
              ],
            ),
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

  Widget _buildPricingCard(String vehicleType, String availability,
      String price, {VoidCallback? onTap}) {
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
           onTap: () => _showCheckoutScreen(subscription),
        );
      }).toList(),
    );
  }

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
            title: Text('Subscription Service'),
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
              },
              onBack: () => Navigator.of(context).pop(),
              displayEmail: true,
              lockEmail: false,
              initEmail: 'user@example.com',
              initPhone: '1234567890',
              initBuyerName: 'John Doe',
              cashPrice: 19.99,
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


  // Method to show success dialog
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
              },
            ),
          ],
        );
      },
    );
  }
// Method to show error dialog
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
}
