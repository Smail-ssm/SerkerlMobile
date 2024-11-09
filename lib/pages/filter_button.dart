import 'package:flutter/material.dart';

class FilterButton extends StatelessWidget {
  final Function() onPressed;

  const FilterButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColor = Theme.of(context).colorScheme.primary;
    final iconColor = Theme.of(context).colorScheme.onPrimary;

    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: buttonColor,
      icon: Icon(Icons.filter_list, color: iconColor),
      label: Text('Filter', style: TextStyle(color: iconColor)),
    );
  }
}
