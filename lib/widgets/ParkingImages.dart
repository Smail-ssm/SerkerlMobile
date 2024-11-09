// parking_images.dart

import 'package:flutter/material.dart';
import '../model/parking.dart';

class ParkingImages extends StatelessWidget {
  final Parking parking;
  final void Function(BuildContext, String) showImagePreview;
  final String Function() defaultImageUrl;

  const ParkingImages({
    Key? key,
    required this.parking,
    required this.showImagePreview,
    required this.defaultImageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (parking.images.isEmpty) {
      return const Text('No images available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Photos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: parking.images.length,
            itemBuilder: (context, index) {
              final imageUrl = parking.images[index];

              return GestureDetector(
                onTap: () => showImagePreview(context, imageUrl),
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrl.isNotEmpty ? imageUrl : defaultImageUrl(),
                      width: 300,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 300,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image,
                              size: 50, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) {
                          return child;
                        } else {
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                  (loadingProgress.expectedTotalBytes!)
                                  : null,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
