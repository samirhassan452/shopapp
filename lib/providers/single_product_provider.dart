import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants.dart';

class SingleProductProvider with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  SingleProductProvider({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken, String userId) async {
    final oldFavStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = realtimeUrl + "userFavorites/$userId/$id.json?auth=$authToken";
    try {
      // update one single value in database
      final res = await http.put(url, body: json.encode(isFavorite));
      if (res.statusCode >= 400) {
        _setFavValue(oldFavStatus);
      }
    } catch (err) {
      _setFavValue(oldFavStatus);
      //throw err;
    }
  }
}
