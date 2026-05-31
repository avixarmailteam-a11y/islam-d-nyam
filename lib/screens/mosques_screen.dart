import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';
import '../services/mosque_service.dart';
import '../models/mosque.dart';

class MosquesScreen extends StatefulWidget {
  const MosquesScreen({super.key});

  @override
  State<MosquesScreen> createState() => _MosquesScreenState();
}

class _MosquesScreenState extends State<MosquesScreen> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  List<Mosque> _mosques = [];
  Set<Marker> _markers = {};
  bool _isLoading = true;
  bool _showMap = true;

  @override
  void initState() {
    super.initState();
    _loadMosques();
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMosques() async {
    setState(() => _isLoading = true);

    final position = await LocationService.getCurrentPosition();
    if (position == null) {
      setState(() => _isLoading = false);
      return;
    }

    _currentPosition = position;
    final mosques = await MosqueService.findNearbyMosques(
      position.latitude,
      position.longitude,
    );

    _markers = mosques.map((mosque) {
      return Marker(
        markerId: MarkerId(mosque.id),
        position: LatLng(mosque.latitude, mosque.longitude),
        infoWindow: InfoWindow(
          title: mosque.name,
          snippet: mosque.address ??
              '${mosque.distance?.toStringAsFixed(1)} km uzaklıkta',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueGreen,
        ),
      );
    }).toSet();

    // Kullanıcı konumunu ekle
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: LatLng(position.latitude, position.longitude),
        infoWindow: const InfoWindow(title: 'Konumunuz'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    );

    setState(() {
      _mosques = mosques;
      _isLoading = false;
    });

    // Haritayı konuma git
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          14,
        ),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentPosition != null) {
      controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
          14,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Görünüm geçiş butonları
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Harita'),
                icon: Icon(Icons.map),
              ),
              ButtonSegment(
                value: false,
                label: Text('Liste'),
                icon: Icon(Icons.list),
              ),
            ],
            selected: {_showMap},
            onSelectionChanged: (Set<bool> newSelection) {
              setState(() {
                _showMap = newSelection.first;
              });
            },
          ),
        ),

        // İçerik
        Expanded(
          child: _isLoading
              ? _buildLoadingWidget()
              : _showMap
                  ? _buildMapView()
                  : _buildListView(),
        ),

        // Yenile butonu
        if (!_isLoading)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loadMosques,
                icon: const Icon(Icons.refresh),
                label: const Text('Yenile'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'En yakın camiler aranıyor...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapView() {
    if (_currentPosition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Konum erişimi gerekli',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      onMapCreated: _onMapCreated,
      initialCameraPosition: CameraPosition(
        target: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        zoom: 14,
      ),
      markers: _markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: true,
      zoomControlsEnabled: true,
    );
  }

  Widget _buildListView() {
    if (_mosques.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mosque, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Yakında cami bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      itemCount: _mosques.length,
      itemBuilder: (context, index) {
        final mosque = _mosques[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context)
                  .colorScheme
                  .primary
                  .withOpacity(0.1),
              child: Icon(
                Icons.mosque,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              mosque.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mosque.address != null)
                  Text(
                    mosque.address!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  '${mosque.distance?.toStringAsFixed(1)} km uzaklıkta',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.directions),
              color: Theme.of(context).colorScheme.primary,
              onPressed: () {
                // Google Maps ile yol tarifi
              },
            ),
          ),
        );
      },
    );
  }
}
