import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';

class KMeansClustering<T extends ClusterItem> {
  final int k;

  KMeansClustering({
    required this.k,
  });

  List<Cluster<T>> cluster(List<T> items) {
    List<LatLng> centroids = _initializeCentroids(items, k);
    Map<int, List<T>> clusterMap = {};

    bool centroidsChanged;
    do {
      centroidsChanged = false;

      clusterMap = {for (int i = 0; i < k; i++) i: []};
      for (var item in items) {
        int closestCentroidIndex = _findClosestCentroid(item.location, centroids);
        clusterMap[closestCentroidIndex]!.add(item);
      }

      for (int i = 0; i < k; i++) {
        if (clusterMap[i]!.isNotEmpty) {
          LatLng newCentroid = _calculateCentroid(clusterMap[i]!);
          if (newCentroid != centroids[i]) {
            centroids[i] = newCentroid;
            centroidsChanged = true;
          }
        }
      }
    } while (centroidsChanged);

    return clusterMap.values.map((items) => Cluster<T>.fromItems(items)).toList();
  }

  List<LatLng> _initializeCentroids(List<T> items, int k) {
    items.shuffle();
    return items.take(k).map((item) => item.location).toList();
  }

  int _findClosestCentroid(LatLng location, List<LatLng> centroids) {
    double minDistance = double.infinity;
    int closestIndex = 0;

    for (int i = 0; i < centroids.length; i++) {
      double distance = _distanceBetween(location, centroids[i]);
      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    return closestIndex;
  }

  LatLng _calculateCentroid(List<T> items) {
    double latSum = 0;
    double lngSum = 0;
    for (var item in items) {
      latSum += item.location.latitude;
      lngSum += item.location.longitude;
    }
    return LatLng(latSum / items.length, lngSum / items.length);
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
