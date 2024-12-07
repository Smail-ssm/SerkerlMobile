import 'package:ebike/widgets/share_bottom_sheet.dart';
import 'package:flutter/material.dart';

import '../../model/client.dart';
import '../../pages/ClientProfilePage.dart';
import '../../pages/FeedbackPage.dart';
import '../../pages/History.dart';
import '../../pages/NotificationsList.dart';
import '../../pages/Pricing.dart';
import '../../pages/SupportPage.dart';
import '../UserAccountsDrawerHeaderWidget.dart';

class LeftDrawer extends StatelessWidget {
  final Client client;
  final VoidCallback onLogout;

  const LeftDrawer({
    Key? key,
    required this.client,
    required this.onLogout,
  }) : super(key: key);

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget buildListTile(String title, IconData icon, VoidCallback onTap,
      {String? value}) {
    return ListTile(
      title: Text(title),
      subtitle: value != null ? Text(value) : null,
      leading: Icon(icon),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeaderWidget(
            client: client,
            onLogout: onLogout,
          ),

          // Account Section
          _buildSectionHeader('Account'),
          buildListTile(
            'Balance',
            Icons.account_balance,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        BalanceAndPricingPage(client: client)),
              );
            },
            value: client.balance.toString(),
          ),
          buildListTile(
            'Profile',
            Icons.person,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ClientProfilePage(client: client)),
              );
            },
          ),
          buildListTile(
            'Share',
            Icons.share,
            () {
              // Function to share user data
              showShareBottomSheet(context, client.userId);
            },
          ),

          const Divider(),

          // Activities Section
          _buildSectionHeader('Activities'),
          buildListTile(
            'Ride History',
            Icons.history,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => HistoryPage(client: client)),
              );
            },
          ),
          buildListTile(
            'Notifications',
            Icons.notifications,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => NotificationsPage(client: client)),
              );
            },
          ),

          const Divider(),

          // Support Section
          _buildSectionHeader('Support'),
          buildListTile(
            'Support',
            Icons.support,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SupportPage(client: client)),
              );
            },
          ),
          buildListTile(
            'Feedback',
            Icons.feedback,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FeedbackPage()),
              );
            },
          ),
        ],
      ),
    );
  }
}
