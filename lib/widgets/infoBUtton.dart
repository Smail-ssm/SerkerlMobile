import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InfoButton extends StatelessWidget {
  const InfoButton({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      right: 20,
      child: Builder(
        builder: (BuildContext context) {
          final buttonColor = Theme.of(context).colorScheme.primary;
          final iconColor = Theme.of(context).colorScheme.onPrimary;

          return RawMaterialButton(
            onPressed: () {
              scaffoldKey.currentState?.openEndDrawer(); // Open the end drawer when the button is pressed
            },
            fillColor: buttonColor, // Adaptable to light and dark mode
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners for the button
            ),
            constraints: BoxConstraints.tightFor(
              width: 48.0, // Button width
              height: 48.0, // Button height
            ),
            child: Icon(
              Icons.info,
              size: 24.0, // Icon size
              color: iconColor, // Adaptable to button background
            ),
          );
        },
      ),
    );
  }
}
