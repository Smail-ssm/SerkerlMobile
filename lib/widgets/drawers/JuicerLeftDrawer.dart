import 'package:ebike/model/vehicule.dart';
import 'package:flutter/material.dart';
import '../../model/client.dart';
import '../../pages/ClientProfilePage.dart';
import '../../pages/NotificationsList.dart';
import '../../pages/juice/BatteryManagementPage.dart';
import '../../pages/juice/JuicerDashboardPage.dart';
import '../../pages/juice/JuicerEarningsPage.dart';
import '../../pages/juice/JuicerTaskListPage.dart';
import '../../pages/juice/JuicerVehicleListPage.dart';

import '../UserAccountsDrawerHeaderWidget.dart';

class JuicerLeftDrawer extends StatelessWidget {
  final Client client;
  final VoidCallback onLogout;
  final List<Vehicle> vehicles; // Pass vehicles if required

  const JuicerLeftDrawer({
    Key? key,
    required this.client,
    required this.onLogout,
    required this.vehicles,
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

  Widget buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      title: Text(title),
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

          // Dashboard Section
          _buildSectionHeader('Dashboard'),
          buildListTile(
            'Dashboard Home',
            Icons.dashboard,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JuicerDashboardPage(client: client)),
              );
            },
          ),

          const Divider(),

          // Management Section
          _buildSectionHeader('Management'),
          buildListTile(
            'Vehicle List',
            Icons.directions_car,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JuicerVehicleListPage(
                        client: client, vehicles: vehicles)),
              );
            },
          ),
          buildListTile(
            'Task List',
            Icons.list_alt,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JuicerTaskListPage(client: client)),
              );
            },
          ),
          buildListTile(
            'Battery Management',
            Icons.battery_full,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BatteryManagementPage()),
              );
            },
          ),


          const Divider(),

          // Earnings Section
          _buildSectionHeader('Earnings'),
          buildListTile(
            'Earnings',
            Icons.attach_money,
                () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => JuicerEarningsPage(client: client)),
              );
            },
          ),

          const Divider(),

          // Account Section
          _buildSectionHeader('Account'),
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
        ],
      ),
    );
  }
}
