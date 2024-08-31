import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ExpandableMapStyleButton extends StatefulWidget {
  @override
  _ExpandableMapStyleButtonState createState() => _ExpandableMapStyleButtonState();
}

class _ExpandableMapStyleButtonState extends State<ExpandableMapStyleButton> {
  bool _isExpanded = false; // Tracks the state of the FAB

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _showMapTypeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Map Type'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Normal'),
                onTap: () {
                  _changeMapType(MapType.normal);
                },
              ),
              ListTile(
                title: const Text('Satellite'),
                onTap: () {
                  _changeMapType(MapType.satellite);
                },
              ),
              ListTile(
                title: const Text('Terrain'),
                onTap: () {
                  _changeMapType(MapType.terrain);
                },
              ),
              ListTile(
                title: const Text('Hybrid'),
                onTap: () {
                  _changeMapType(MapType.hybrid);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _changeMapType(MapType mapType) {
    // Implement map type change
    Navigator.of(context).pop(); // Close the dialog
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return Positioned(
      top: 100,
      right: 20,
      child: Stack(
        children: [
          if (_isExpanded)
            Positioned(
              top: 60,
              right: 0,
              child: FloatingActionButton(
                onPressed: () => _showMapTypeDialog(context),
                backgroundColor: buttonColor,
                child: const Icon(Icons.map_outlined),
              ),
            ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstChild: FloatingActionButton(
              onPressed: _toggleExpansion,
              backgroundColor: buttonColor,
              child: Icon(
                _isExpanded ? Icons.close : Icons.map_outlined,
                color: iconColor,
              ),
            ),
            secondChild: FloatingActionButton.extended(
              onPressed: _toggleExpansion,
              backgroundColor: buttonColor,
              icon: Icon(
                Icons.map_outlined,
                color: iconColor,
              ),
              label: Text(
                'Map Type',
                style: TextStyle(color: iconColor),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }
}
