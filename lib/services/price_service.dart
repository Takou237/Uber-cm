import 'dart:math' as math;

class PriceService {
  // Constantes de tarification
  static const double baseFare = 200.0;
  static const double perKmRate = 250.0;
  static const double perMinuteRate = 50.0;
  static const double minFare = 500.0;

  /// CALCULE LA DISTANCE (Méthode Haversine)
  /// Retourne la distance en KM entre deux points
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double r = 6371; // Rayon de la Terre en km
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return r * c;
  }

  static double _toRadians(double degree) {
    return degree * (math.pi / 180);
  }

  /// Calcule le prix estimé
  static double calculatePrice(double distanceEnKm, double dureeEnMinutes) {
    double total =
        baseFare +
        (distanceEnKm * perKmRate) +
        (dureeEnMinutes * perMinuteRate);

    // Retourne le total ou le prix minimum si le trajet est trop court
    return total < minFare ? minFare : total;
  }
}
