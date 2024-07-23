import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class DistanceBasedClustering<T extends ClusterItem> {
  final double thresholdDistance;

  DistanceBasedClustering({
    required this.thresholdDistance,
  });

  List<Cluster<T>> cluster(List<T> items) {
    List<Cluster<T>> clusters = [];
    Set<T> unvisitedItems = items.toSet();

    while (unvisitedItems.isNotEmpty) {
      T item = unvisitedItems.first;
      unvisitedItems.remove(item);

      List<T> clusterItems = [item];
      for (T otherItem in unvisitedItems.toList()) {
        if (_distanceBetween(item.location, otherItem.location) < thresholdDistance) {
          clusterItems.add(otherItem);
          unvisitedItems.remove(otherItem);
        }
      }

      clusters.add(Cluster<T>.fromItems(clusterItems));
    }

    return clusters;
  }

  double _distanceBetween(LatLng start, LatLng end) {
    var earthRadius = 6371000.0; // en metros
    double dLat = _deg2rad(end.latitude - start.latitude);
    double dLng = _deg2rad(end.longitude - start.longitude);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(start.latitude)) * cos(_deg2rad(end.latitude)) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) {
    return deg * (pi / 180);
  }
}
