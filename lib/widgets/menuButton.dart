import 'package:flutter/material.dart';

class menuButton extends StatelessWidget {
  const menuButton({
    Key? key,
    required this.scaffoldKey,
  }) : super(key: key);

  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 50,
      left: 20,
      child: Builder(
        builder: (BuildContext context) {
          final buttonColor = Theme.of(context).colorScheme.primary;
          final iconColor = Theme.of(context).colorScheme.onPrimary;

          return RawMaterialButton(
            onPressed: () {
              scaffoldKey.currentState?.openDrawer(); // Open the drawer when the button is pressed
            },
            fillColor: buttonColor, // Adaptable to light and dark mode
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            constraints: BoxConstraints.tightFor(
              width: 48.0, // Square button width
              height: 48.0, // Square button height
            ),
            child: Icon(
              Icons.menu,
              size: 24.0, // Icon size
              color: iconColor, // Adaptable to button background
            ),
          );
        },
      ),
    );
  }

}
