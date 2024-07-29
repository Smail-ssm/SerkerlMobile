import 'package:cloud_firestore/cloud_firestore.dart';
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
        title: const Text('client Profile'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUserAvatar(widget.client!.profilePictureUrl.toString()),
            const SizedBox(height: 16),
            UserInfoRow(
                icon: Icons.email, label: 'Email', value: widget.client!.email),
            UserInfoRow(
                icon: Icons.person,
                label: 'Username',
                value: widget.client!.username),
            UserInfoRow(
                icon: Icons.label,
                label: 'Full Name',
                value: widget.client!.fullName),
            const Divider(),
            UserInfoRow(
                icon: Icons.phone,
                label: 'Phone Number',
                value: widget.client!.phoneNumber),
            UserInfoRow(
                icon: Icons.location_city,
                label: 'Address',
                value: widget.client!.address),
            UserInfoRow(
                icon: Icons.admin_panel_settings,
                label: 'Role',
                value: widget.client!.role),
            const Divider(),
            UserInfoRow(
              icon: Icons.calendar_today,
              label: 'Creation Date:',
              value: _formatCreationDate(widget.client!.creationDate as Timestamp),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCreationDate(Timestamp value) {
    final dateTime = value.toDate();
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  Widget _buildUserAvatar(String profilePictureUrl) {
    return CircleAvatar(
      backgroundImage: NetworkImage(profilePictureUrl),
      radius: 40,
    );
    }
}

class UserInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserInfoRow({Key? key, 
    required this.icon,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: Text(
            value,
            softWrap: true,
          ),
        ),
      ],
    );
  }
}
