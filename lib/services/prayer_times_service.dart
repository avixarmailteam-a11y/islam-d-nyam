import 'dart:math' show sin, cos, tan, asin, atan2, pi;

class PrayerTimesService {
  static const double _kibleLatitude = 21.4225;  // Kabe enlem
  static const double _kibleLongitude = 39.8262; // Kabe boylam

  static double calculateQiblaDirection(double lat, double lon) {
    final latRad = _toRadians(lat);
    final lonRad = _toRadians(lon);
    final kibleLatRad = _toRadians(_kibleLatitude);
    final kibleLonRad = _toRadians(_kibleLongitude);

    final dLon = kibleLonRad - lonRad;
    final y = sin(dLon) * cos(kibleLatRad);
    final x = cos(latRad) * sin(kibleLatRad) -
        sin(latRad) * cos(kibleLatRad) * cos(dLon);

    double qibla = _toDegrees(atan2(y, x));
    if (qibla < 0) qibla += 360;
    return qibla;
  }

  static double calculateDistanceToKaaba(double lat, double lon) {
    const R = 6371.0;
    final dLat = _toRadians(_kibleLatitude - lat);
    final dLon = _toRadians(_kibleLongitude - lon);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat)) *
            cos(_toRadians(_kibleLatitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final c = 2 * asin(sqrt(a));
    return R * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }

  static double _toDegrees(double radian) {
    return radian * 180 / pi;
  }

  // Basit namaz vakitleri hesaplama (Diyanet metodu - yaklaşık)
  static Map<String, DateTime> calculatePrayerTimes(
    double lat, double lon, DateTime date,
  ) {
    // Gerçek bir uygulamada Aladhan API'i veya Diyanet API'i kullanılır
    // Burada basit bir demo hesaplama sunulmaktadır
    // Üretimde bu API'e sorulmalıdır
    final times = <String, DateTime>{};

    // Basit hesaplama (demo amaçlı)
    // Gerçek uygulamada AlAdhan API: https://api.aladhan.com/v1/timings kullanılır
    final year = date.year;
    final month = date.month;
    final day = date.day;

    // Güneşin doğuş ve batışı için basit hesaplama
    final julianDay = _julianDay(year, month, day);
    final sunDeclination = _sunDeclination(julianDay);
    final equationOfTime = _equationOfTime(julianDay);
    final longitudeTime = lon / 15.0;

    // Fecr (sabah) : güneş doğumundan -18° güneş açısı
    final fajrAngle = -18.0;
    // İsha: güneş batımından -17° güneş açısı
    final ishaAngle = -17.0;

    final latRad = _toRadians(lat);
    final decRad = _toRadians(sunDeclination);

    // Öğle vakti (güneş tepe noktası)
    final zuhrTime = 12.0 + equationOfTime - longitudeTime;

    // Sabah (Fecr)
    final fajrH = _hourAngle(latRad, decRad, _toRadians(fajrAngle));
    final fajrTime = zuhrTime - fajrH;

    // İkindi (Asr)
    final asrShadow = 1.0; // Hanefi mezhebi
    final asrAngle = atan(1.0 / (tan(abs(latRad - decRad)) + asrShadow));
    // Basit hesaplama
    final asrH = _hourAngle(latRad, decRad, asrAngle);
    final asrTime = zuhrTime + asrH;

    // Akşam (Magrip)
    final magribH = _hourAngle(latRad, decRad, _toRadians(-0.833));
    final magribTime = zuhrTime + magribH;

    // Yatsı (Isha)
    final ishaH = _hourAngle(latRad, decRad, _toRadians(ishaAngle));
    final ishaTime = zuhrTime + ishaH;

    times['Sabah'] = _timeToDateTime(date, fajrTime);
    times['Öğle'] = _timeToDateTime(date, zuhrTime);
    times['İkindi'] = _timeToDateTime(date, asrTime);
    times['Akşam'] = _timeToDateTime(date, magribTime);
    times['Yatsı'] = _timeToDateTime(date, ishaTime);

    return times;
  }

  static double abs(double v) => v < 0 ? -v : v;

  static double _julianDay(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  static double _sunDeclination(double julianDay) {
    final n = julianDay - 2451545.0;
    final L = (280.460 + 0.9856474 * n) % 360;
    final g = _toRadians((357.528 + 0.9856003 * n) % 360);
    final lambda = _toRadians(L + 1.915 * sin(g) + 0.020 * sin(2 * g));
    final epsilon = _toRadians(23.439 - 0.0000004 * n);
    return _toDegrees(asin(sin(epsilon) * sin(lambda)));
  }

  static double _equationOfTime(double julianDay) {
    final n = julianDay - 2451545.0;
    final L = (280.460 + 0.9856474 * n) % 360;
    final g = _toRadians((357.528 + 0.9856003 * n) % 360);
    return 4 * (L - _toDegrees(atan2(
      sin(g) * (1.915 * cos(g) + 0.020 * cos(2 * g)),
      cos(g) - 0.020 * sin(2 * g),
    )));
  }

  static double _hourAngle(double latRad, double decRad, double angleRad) {
    final cosH = (cos(angleRad) - sin(latRad) * sin(decRad)) /
        (cos(latRad) * cos(decRad));
    if (cosH < -1 || cosH > 1) return 0;
    return _toDegrees(acos(cosH)) / 15.0;
  }

  static double acos(double x) {
    if (x <= -1.0) return pi;
    if (x >= 1.0) return 0.0;
    return atan2(sqrt(1.0 - x * x), x);
  }

  static DateTime _timeToDateTime(DateTime baseDate, double timeDecimal) {
    final hour = timeDecimal.floor();
    final minute = ((timeDecimal - hour) * 60).floor();
    return DateTime(baseDate.year, baseDate.month, baseDate.day, hour, minute);
  }
}
