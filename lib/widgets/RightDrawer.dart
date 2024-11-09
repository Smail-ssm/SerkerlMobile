import 'package:flutter/material.dart';

class RightDrawer extends StatefulWidget {
  final bool isExpanded;
  final VoidCallback onRefresh;
  final VoidCallback onFilter;

  const RightDrawer({
    Key? key,
    required this.isExpanded,
    required this.onRefresh,
    required this.onFilter,
  }) : super(key: key);

  @override
  _RightDrawerState createState() => _RightDrawerState();
}

class _RightDrawerState extends State<RightDrawer> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // Top section with buttons in ExpansionTile
          ExpansionTile(
            title: const Text('Options'),
            leading: const Icon(Icons.settings),
            initiallyExpanded: _isExpanded,
            onExpansionChanged: (bool expanding) {
              setState(() {
                _isExpanded = expanding; // Update state on expansion change
              });
            },
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onRefresh,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onFilter,
                        icon: const Icon(Icons.filter_list),
                        label: const Text('Filter'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Other tiles and content
          ..._buildRightDrawerTiles(context),
        ],
      ),
    );
  }

  // Helper function to create other tiles and content for the right drawer
  List<Widget> _buildRightDrawerTiles(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return [
      Center(
        child: Text(
          'Tutorial',
          style: TextStyle(
            fontSize: 20.0,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ExpansionTile(
        title: Text('Find a Scooter', style: TextStyle(color: textColor)),
        leading: Icon(Icons.directions_walk, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Instructions', style: TextStyle(color: textColor)),
            subtitle: Text('Steps on finding a scooter near you.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Start Ride', style: TextStyle(color: textColor)),
        leading: Icon(Icons.qr_code_scanner, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Unlock Scooter', style: TextStyle(color: textColor)),
            subtitle: Text('Scan the QR code to start your ride.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('End Ride', style: TextStyle(color: textColor)),
        leading: Icon(Icons.location_off, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Parking', style: TextStyle(color: textColor)),
            subtitle: Text('Locate a designated parking spot.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Take Photo', style: TextStyle(color: textColor)),
            subtitle: Text('Take a photo of the parked scooter.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('End Ride Confirmation',
                style: TextStyle(color: textColor)),
            subtitle: Text('Confirm ride completion in the app.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Zones on the Map', style: TextStyle(color: textColor)),
        leading: Icon(Icons.map, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Green Zone', style: TextStyle(color: textColor)),
            subtitle:
                Text('Riding allowed.', style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Red Zone', style: TextStyle(color: textColor)),
            subtitle: Text('No riding allowed.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Yellow Zone', style: TextStyle(color: textColor)),
            subtitle: Text('Reduced speed zone.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Grey Zone', style: TextStyle(color: textColor)),
            subtitle: Text('Scooter unavailable in this area.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('FAQs', style: TextStyle(color: textColor)),
        leading: Icon(Icons.question_answer, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Common Questions', style: TextStyle(color: textColor)),
            subtitle: Text('Find answers to frequently asked questions.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          // Add more ListTile widgets for other FAQs
        ],
      ),
      Divider(
        thickness: 1,
        indent: 16.0,
        endIndent: 16.0,
        color: theme.dividerColor,
      ),
      Center(
        child: Text(
          'Troubleshooting',
          style: TextStyle(
            fontSize: 20.0,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      ExpansionTile(
        title: Text('Troubleshooting', style: TextStyle(color: textColor)),
        leading: Icon(Icons.build, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Payment Issues', style: TextStyle(color: textColor)),
            subtitle: Text('Steps to resolve payment problems.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title:
                Text('Scooter Unavailable', style: TextStyle(color: textColor)),
            subtitle: Text('What to do if a scooter is unavailable.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          // Add more ListTile widgets for other troubleshooting topics
        ],
      ),
      ExpansionTile(
        title: Text('Contact Us', style: TextStyle(color: textColor)),
        leading: Icon(Icons.contact_emergency, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Email', style: TextStyle(color: textColor)),
            subtitle: Text('support@Ebike.com',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          ListTile(
            title: Text('Phone Number', style: TextStyle(color: textColor)),
            subtitle: Text('phone', style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
          // Add more ListTile widgets for other contact methods (if applicable)
        ],
      ),
      ExpansionTile(
        title: Text('Help Center', style: TextStyle(color: textColor)),
        leading: Icon(Icons.help, color: theme.iconTheme.color),
        children: [
          ListTile(
            title: Text('Visit our Help Center',
                style: TextStyle(color: textColor)),
            subtitle: Text('Detailed guides and tutorials.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      ExpansionTile(
        title: Text('Community Forum', style: TextStyle(color: textColor)),
        leading: Icon(Icons.forum, color: theme.iconTheme.color),
        children: [
          ListTile(
            title:
                Text('Join the Community', style: TextStyle(color: textColor)),
            subtitle: Text('Connect with other users and get help.',
                style: TextStyle(color: subtitleColor)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          ),
        ],
      ),
      // Add more ExpansionTiles for other support functionalities (if applicable)
    ];
  }
}
