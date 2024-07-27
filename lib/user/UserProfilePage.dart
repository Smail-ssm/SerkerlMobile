import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'UserProfileEditPage.dart';

class UserProfilePage extends StatefulWidget {
  final user;

  UserProfilePage({required this.user});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileEditPage(user: widget.user),
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
            _buildUserAvatar(widget.user.profilePictureUrl.toString()),
            const SizedBox(height: 16),
            UserInfoRow(
                icon: Icons.email, label: 'Email', value: widget.user.email),
            UserInfoRow(
                icon: Icons.person,
                label: 'Username',
                value: widget.user.username),
            UserInfoRow(
                icon: Icons.label,
                label: 'Full Name',
                value: widget.user.fullName),
            const Divider(),
            UserInfoRow(
                icon: Icons.phone,
                label: 'Phone Number',
                value: widget.user.phoneNumber),
            UserInfoRow(
                icon: Icons.location_city,
                label: 'Address',
                value: widget.user.address),
            const Divider(),
            UserInfoRow(
              icon: Icons.calendar_today,
              label: 'Creation Date:',
              value: _formatCreationDate(widget.user.creationDate),
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
    if (profilePictureUrl != null) {
      return CircleAvatar(
        backgroundImage: NetworkImage(profilePictureUrl),
        radius: 40,
      );
    } else {
      return CircleAvatar(
        child: Text(widget.user.username[0].toUpperCase()),
        radius: 40,
      );
    }
  }
}

class UserInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

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
