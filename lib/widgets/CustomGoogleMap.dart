// custom_google_map.dart

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CustomGoogleMap extends StatelessWidget {
  final LatLng? currentLocation;
  final MapType mapType;
  final Set<Polygon> polygons;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final void Function(GoogleMapController) onMapCreated;
  final VoidCallback applyMapTheme;
  final void Function(LatLng) onLongPress;

  const CustomGoogleMap({
    Key? key,
    required this.currentLocation,
    required this.mapType,
    required this.polygons,
    required this.markers,
    required this.polylines,
    required this.onMapCreated,
    required this.applyMapTheme,
    required this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return Container(); // Or any placeholder widget
    }

    return GoogleMap(
      mapType: mapType,
      initialCameraPosition: CameraPosition(
        target: currentLocation!,
        zoom: 15.0,
      ),
      onMapCreated: (GoogleMapController controller) {
        onMapCreated(controller);
        applyMapTheme();
      },
      polygons: polygons,
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onLongPress: onLongPress,
      mapToolbarEnabled: false,
    );
  }
}
