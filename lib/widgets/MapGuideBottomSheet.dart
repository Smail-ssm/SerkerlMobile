import 'package:flutter/material.dart';

import 'ItemTile.dart';

class MapGuideBottomSheet extends StatelessWidget {
  const MapGuideBottomSheet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final backgroundColor = theme.colorScheme.surface;
    final surfaceColor = theme.colorScheme.surface;
    final dividerColor = theme.dividerColor;

    return Wrap(
      children: [
        Container(
          decoration: BoxDecoration(
            color: surfaceColor, // Adaptable to light and dark mode
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: dividerColor, // Color for the drag handle
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const ItemTile(
                  icon: Icons.stop_circle,
                  title: 'No-go zone',
                  description:
                      'Don\'t ride or park in red areas. We\'ll stop your vehicle and you risk a fine.',
                  color: Colors.red,
                ),
                const ItemTile(
                  icon: Icons.speed_sharp,
                  title: 'Low-speed zone',
                  description:
                      'We\'ll automatically slow your speed in yellow areas.',
                  color: Colors.yellow,
                ),
                const ItemTile(
                  icon: Icons.local_parking,
                  title: 'No-park zone',
                  description:
                      'To avoid a parking fine, end your ride outside of gray areas.',
                  color: Colors.grey,
                ),
                const ItemTile(
                  icon: Icons.electric_scooter,
                  title: 'Scooter parking',
                  description:
                      'Park scooters in circle spots, or diamond for all vehicles in blue areas.',
                  color: Colors.blue,
                ),
                const ItemTile(
                  icon: Icons.pedal_bike,
                  title: 'Bike parking',
                  description:
                      'Park bikes in square spots, or diamond for all vehicles in blue areas.',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
