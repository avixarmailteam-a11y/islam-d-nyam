import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mosque.dart';
import 'dart:math' show cos, sin, sqrt, atan2, pi;

class MosqueService {
  static const String _apiKey = 'BURAYA_GOOGLE_MAPS_API_KEY_YAZILACAK';

  static Future<List<Mosque>> findNearbyMosques(
    double lat, double lon, {double radius = 5000}
  ) async {
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lon'
        '&radius=${radius.toInt()}'
        '&type=mosque'
        '&keyword=cami+mosque'
        '&key=$_apiKey',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode != 200) {
        return _getFallbackMosques(lat, lon);
      }

      final data = jsonDecode(response.body);
      if (data['status'] != 'OK') {
        return _getFallbackMosques(lat, lon);
      }

      final results = data['results'] as List;
      final mosques = results.map((place) {
        final loc = place['geometry']['location'];
        return Mosque(
          id: place['place_id'] ?? '',
          name: place['name'] ?? 'Bilinmeyen Cami',
          latitude: loc['lat']?.toDouble() ?? 0.0,
          longitude: loc['lng']?.toDouble() ?? 0.0,
          address: place['vicinity'],
        );
      }).toList();

      // Mesafeye göre sırala
      mosques.sort((a, b) {
        final distA = _calculateDistance(lat, lon, a.latitude, a.longitude);
        final distB = _calculateDistance(lat, lon, b.latitude, b.longitude);
        return distA.compareTo(distB);
      });

      return mosques.take(20).map((m) => m.copyWith(
        distance: _calculateDistance(lat, lon, m.latitude, m.longitude),
      )).toList();
    } catch (e) {
      return _getFallbackMosques(lat, lon);
    }
  }

  static double _calculateDistance(
    double lat1, double lon1, double lat2, double lon2,
  ) {
    const R = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  static double _toRadians(double degree) => degree * pi / 180;

  static List<Mosque> _getFallbackMosques(double lat, double lon) {
    // API anahtarı olmadan veya hata durumunda demo veriler
    return [
      Mosque(
        id: 'demo_1',
        name: 'Sultanahmet Camii',
        latitude: 41.0054,
        longitude: 28.9768,
        address: 'Sultanahmet, İstanbul',
      ),
      Mosque(
        id: 'demo_2',
        name: 'Ayasofya Camii',
        latitude: 41.0086,
        longitude: 28.9802,
        address: 'Sultanahmet, İstanbul',
      ),
      Mosque(
        id: 'demo_3',
        name: 'Süleymaniye Camii',
        latitude: 41.0163,
        longitude: 28.9638,
        address: 'Süleymaniye, İstanbul',
      ),
    ].map((m) => m.copyWith(
      distance: _calculateDistance(lat, lon, m.latitude, m.longitude),
    )).toList()..sort((a, b) => (a.distance ?? 0).compareTo(b.distance ?? 0));
  }
}
