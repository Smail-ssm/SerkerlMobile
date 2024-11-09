import 'package:flutter/material.dart';

class ItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const ItemTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final subtitleColor = theme.textTheme.bodyMedium?.color ?? Colors.grey;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: textColor), // Adaptable to light and dark mode
      ),
      subtitle: Text(
        description,
        style:
            TextStyle(color: subtitleColor), // Adaptable to light and dark mode
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 8.0),
    );
  }
}
