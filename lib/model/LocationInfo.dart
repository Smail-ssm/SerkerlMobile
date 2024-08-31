class LocationInfo {
  final String address;

  LocationInfo({required this.address});

  factory LocationInfo.fromJson(Map<String, dynamic> json) {
    // Extract address from JSON, you might need to adjust based on actual API response
    final address = json['results'] != null && json['results'].isNotEmpty
        ? json['results'][0]['formatted_address'] ?? 'Unknown Location'
        : 'Unknown Location';
    return LocationInfo(address: address);
  }
}