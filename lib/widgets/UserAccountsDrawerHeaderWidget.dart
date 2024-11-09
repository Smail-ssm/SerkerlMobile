import 'package:flutter/material.dart';
import '../model/client.dart';
import '../pages/ClientProfilePage.dart';
import '../pages/Settings.dart';


class UserAccountsDrawerHeaderWidget extends StatelessWidget {
  final Client? client;
  final VoidCallback onLogout;

  const UserAccountsDrawerHeaderWidget({
    Key? key,
    required this.client,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark or light
    bool isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    // Set text color based on the theme
    Color textColor = isDarkTheme ? Colors.white : Colors.black;

    // Set the gradient colors based on the theme
    List<Color> gradientColors = isDarkTheme
        ? [
      const Color(0xFF1A237E),
      const Color(0xFF0D47A1)
    ] // Dark theme gradient colors
        : [Colors.blue, Colors.green]; // Light theme gradient colors

    // Set the icon colors based on the theme
    Color iconColor = isDarkTheme ? Colors.white : Colors.black;

    return UserAccountsDrawerHeader(
      accountName: Text(
        client?.fullName ?? 'Guest',
        style: TextStyle(color: textColor),
      ),
      accountEmail: Text(
        client?.email ?? 'No email',
        style: TextStyle(color: textColor),
      ),
      currentAccountPicture: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ClientProfilePage(
              client: client,
            ),
          ),
        ),
        child: CircleAvatar(
          backgroundColor: Colors.grey,
          child: client?.profilePictureUrl != null &&
              client!.profilePictureUrl.isNotEmpty
              ? ClipOval(
            child: Image.network(
              client!.profilePictureUrl,
              fit: BoxFit.cover,
              width: 90.0,
              height: 90.0,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                size: 50.0,
                color: iconColor,
              ),
            ),
          )
              : Icon(
            Icons.person,
            size: 50.0,
            color: iconColor,
          ),
        ),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      otherAccountsPictures: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          },
          child: CircleAvatar(child: Icon(Icons.settings, color: iconColor)),
        ),
        GestureDetector(
          onTap: onLogout,
          child: CircleAvatar(child: Icon(Icons.logout, color: iconColor)),
        ),
      ],
    );
  }
}
