class Mosque {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String? address;
  final double? distance;

  const Mosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.address,
    this.distance,
  });

  Mosque copyWith({double? distance}) {
    return Mosque(
      id: id,
      name: name,
      latitude: latitude,
      longitude: longitude,
      address: address,
      distance: distance ?? this.distance,
    );
  }
}
