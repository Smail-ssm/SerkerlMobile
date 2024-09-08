import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../model/client.dart';
import '../pages/ClientProfileEditPage.dart';

class ClientProfilePage extends StatefulWidget {
  final Client? client;

  const ClientProfilePage({Key? key, required this.client}) : super(key: key);

  @override
  State<ClientProfilePage> createState() => _ClientProfilePageState();
}

class _ClientProfilePageState extends State<ClientProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileEditPage(client: widget.client),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: _buildUserAvatar(widget.client?.profilePictureUrl),
            ),
            const SizedBox(height: 24),
            if (widget.client != null)
              ..._buildClientDetails(widget.client!),
            if (widget.client == null)
              Center(
                child: Text(
                  'No client data available',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildClientDetails(Client client) {
    return [
      UserInfoRow(
        icon: Icons.email,
        label: 'Email',
        value: client.email,
      ),
      UserInfoRow(
        icon: Icons.person,
        label: 'Username',
        value: client.username,
      ),
      UserInfoRow(
        icon: Icons.label,
        label: 'Full Name',
        value: client.fullName,
      ),
      const Divider(height: 30, thickness: 1),
      UserInfoRow(
        icon: Icons.phone,
        label: 'Phone Number',
        value: client.phoneNumber,
      ),
      UserInfoRow(
        icon: Icons.location_city,
        label: 'Address',
        value: client.address,
      ),
      UserInfoRow(
        icon: Icons.admin_panel_settings,
        label: 'Role',
        value: client.role,
      ),
      const Divider(height: 30, thickness: 1),
      UserInfoRow(
        icon: Icons.calendar_today,
        label: 'Creation Date',
        value: _formatCreationDate(client.creationDate.toLocal()),
      ),
    ];
  }

  String _formatCreationDate(DateTime value) {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(value);
  }

  Widget _buildUserAvatar(String? profilePictureUrl) {
    if (profilePictureUrl == null || profilePictureUrl.isEmpty || profilePictureUrl == 'NO IMAGE') {
      return CircleAvatar(
        radius: 50,
        backgroundColor: Colors.grey[300],
        child: const Icon(Icons.person, size: 50, color: Colors.grey),
      );
    } else {
      return CircleAvatar(
        backgroundImage: NetworkImage(profilePictureUrl),
        radius: 50,
      );
    }
  }
}

class UserInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserInfoRow({
    Key? key,
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}
