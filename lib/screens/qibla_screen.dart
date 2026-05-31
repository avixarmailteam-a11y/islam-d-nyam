import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/location_service.dart';
import '../services/prayer_times_service.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen>
    with SingleTickerProviderStateMixin {
  double? _compassHeading;
  double? _qiblaDirection;
  double? _distanceToKaaba;
  bool _hasPermission = false;
  bool _isLoading = true;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _initializeCompass();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _initializeCompass() async {
    await _checkPermissions();

    if (_hasPermission) {
      _getLocationAndCalculateQibla();

      FlutterCompass.events?.listen((event) {
        if (mounted) {
          setState(() {
            _compassHeading = event.heading;
          });
        }
      });
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.sensors.request();
    setState(() {
      _hasPermission = status.isGranted;
      _isLoading = false;
    });
  }

  Future<void> _getLocationAndCalculateQibla() async {
    final position = await LocationService.getCurrentPosition();
    if (position == null) return;

    setState(() {
      _qiblaDirection = PrayerTimesService.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );
      _distanceToKaaba = PrayerTimesService.calculateDistanceToKaaba(
        position.latitude,
        position.longitude,
      );
    });
  }

  bool get _isFacingQibla {
    if (_compassHeading == null || _qiblaDirection == null) return false;
    final diff = (_compassHeading! - _qiblaDirection!).abs();
    final normalizedDiff = diff > 180 ? 360 - diff : diff;
    return normalizedDiff < 5;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Bilgi kartı
            Padding(
              padding: const EdgeInsets.all(16),
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            'Kıble Yönü',
                            _qiblaDirection != null
                                ? '${_qiblaDirection!.toStringAsFixed(1)}°'
                                : '--',
                            Icons.navigation,
                          ),
                          Container(
                            height: 40,
                            width: 1,
                            color: Colors.grey[300],
                          ),
                          _buildInfoItem(
                            'Kabe Mesafe',
                            _distanceToKaaba != null
                                ? '${_distanceToKaaba!.toStringAsFixed(0)} km'
                                : '--',
                            Icons.location_on,
                          ),
                        ],
                      ),
                      if (_isFacingQibla) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Kıble Yönündesiniz!',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Pusula
            Expanded(
              child: Center(
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : !_hasPermission
                        ? _buildPermissionRequest()
                        : _buildCompass(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionRequest() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.sensors, size: 64, color: Colors.grey[400]),
        const SizedBox(height: 16),
        Text(
          'Pusula erişimi gerekli',
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _checkPermissions,
          child: const Text('İzin Ver'),
        ),
      ],
    );
  }

  Widget _buildCompass() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Dış halka
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isFacingQibla
                      ? Colors.green.withOpacity(
                          0.3 + _pulseController.value * 0.4,
                        )
                      : Colors.grey[300]!,
                  width: _isFacingQibla ? 3 : 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isFacingQibla
                        ? Colors.green.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),

            // Yön işaretleri
            _buildDirectionMarkers(),

            // Kıble yönü göstergesi
            if (_qiblaDirection != null)
              Transform.rotate(
                angle: _qiblaDirection! * 3.14159 / 180,
                child: Container(
                  width: 280,
                  height: 280,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.green[700],
                        size: 32,
                      ),
                      Text(
                        'Kıble',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Pusula iğnesi (cihazın baktığı yön)
            if (_compassHeading != null)
              Transform.rotate(
                angle: -(_compassHeading! * 3.14159 / 180),
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: CustomPaint(
                    painter: CompassNeedlePainter(
                      isFacingQibla: _isFacingQibla,
                    ),
                  ),
                ),
              ),

            // Merkez nokta
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isFacingQibla ? Colors.green : Colors.red,
                boxShadow: [
                  BoxShadow(
                    color: (_isFacingQibla ? Colors.green : Colors.red)
                        .withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDirectionMarkers() {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kuzey
          Positioned(top: 8, child: _buildMarker('K', true)),
          // Güney
          Positioned(bottom: 8, child: _buildMarker('G', false)),
          // Doğu
          Positioned(right: 8, child: _buildMarker('D', false)),
          // Batı
          Positioned(left: 8, child: _buildMarker('B', false)),
        ],
      ),
    );
  }

  Widget _buildMarker(String label, bool isPrimary) {
    return Text(
      label,
      style: TextStyle(
        fontSize: isPrimary ? 18 : 14,
        fontWeight: isPrimary ? FontWeight.bold : FontWeight.w500,
        color: isPrimary ? Colors.red[700] : Colors.grey[600],
      ),
    );
  }
}

class CompassNeedlePainter extends CustomPainter {
  final bool isFacingQibla;

  CompassNeedlePainter({required this.isFacingQibla});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.width / 2 - 20;

    // Kırmızı uç (Kuzey)
    final northPaint = Paint()
      ..color = isFacingQibla ? Colors.green : Colors.red
      ..style = PaintingStyle.fill;

    // Beyaz uç (Güney)
    final southPaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.fill;

    final northPath = Path()
      ..moveTo(center.dx, center.dy - needleLength)
      ..lineTo(center.dx - 12, center.dy + 5)
      ..lineTo(center.dx + 12, center.dy + 5)
      ..close();

    final southPath = Path()
      ..moveTo(center.dx, center.dy + needleLength)
      ..lineTo(center.dx - 12, center.dy - 5)
      ..lineTo(center.dx + 12, center.dy - 5)
      ..close();

    canvas.drawPath(northPath, northPaint);
    canvas.drawPath(southPath, southPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
