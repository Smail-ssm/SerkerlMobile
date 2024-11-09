import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapWidget extends StatelessWidget {
  final LatLng currentLocation;
  final Set<Polygon> polygons;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final Function(LatLng) onLongPress;
  final GoogleMapController? mapController;

  const GoogleMapWidget({Key? key, 
    required this.currentLocation,
    required this.polygons,
    required this.markers,
    required this.polylines,
    required this.onLongPress,
    this.mapController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(target: currentLocation, zoom: 15.0),
      onMapCreated: (controller) => mapController,
      polygons: polygons,
      markers: markers,
      polylines: polylines,
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onLongPress: onLongPress,
    );
  }
}
