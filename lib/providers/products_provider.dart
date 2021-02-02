import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../providers/single_product_provider.dart';
import '../constants.dart';

class ProductsProvider with ChangeNotifier {
  List<SingleProductProvider> _products = [] /*listOfProducts*/;
  String authToken;
  String userId;

  getData(
      String userAuthToken, String uId, List<SingleProductProvider> products) {
    authToken = userAuthToken;
    userId = uId;
    _products = products;

    notifyListeners();
  }

  List<SingleProductProvider> get products {
    return [..._products];
  }

  List<SingleProductProvider> get favoritesProducts {
    return _products.where((product) => product.isFavorite).toList();
  }

  SingleProductProvider findProductById(String productId) {
    return _products.firstWhere((product) => product.id == productId);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    // we have 2 options
    // 1. show all products of all users in main screen without any filters
    // 2. filter products to show only products of that user

    // in case of filteration
    // return products in order to creatorId which this creatorId equal to userId
    // otherwise put an empty value
    final filteredProducts =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url = realtimeUrl + "products.json?auth=$authToken&$filteredProducts";

    try {
      final prodRes = await http.get(url);
      //print(prodRes.statusCode);
      final extractedProdData =
          json.decode(prodRes.body) as Map<String, dynamic>;

      if (extractedProdData == null) {
        return;
      }

      // get favorite products for specific user
      url = realtimeUrl + "userFavorites/$userId.json?auth=$authToken";
      final favRes = await http.get(url);
      final extractedFavData = json.decode(favRes.body);
      final List<SingleProductProvider> loadedProducts = [];
      extractedProdData.forEach((prodId, prodData) {
        loadedProducts.add(
          SingleProductProvider(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            // it is possible that extractedFavData may be null
            // and also extractedFavData[prodId]
            // so give default value if these values are null
            isFavorite: extractedFavData == null
                ? false
                : extractedFavData[prodId] ?? false,
          ),
        );
      });

      _products = loadedProducts;
      //print(_products);
      notifyListeners();
    } catch (err) {
      print(err.toString());
    }
  }

  Future<void> addProduct(SingleProductProvider product) async {
    final url = realtimeUrl + "products.json?auth=$authToken";

    try {
      final encodedProduct = json.encode({
        'title': product.title,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'creatorId': userId,
      });
      final addDataRes = await http.post(url, body: encodedProduct);
      final newProduct = SingleProductProvider(
        id: json.decode(addDataRes.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _products.add(newProduct);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> updateProduct(
      String prodId, SingleProductProvider newProduct) async {
    final prodIndex =
        _products.indexWhere((productId) => productId.id == prodId);
    if (prodIndex >= 0) {
      final url = realtimeUrl + "products/$prodId.json?auth=$authToken";
      final encodedData = json.encode({
        'title': newProduct.title,
        'description': newProduct.description,
        'price': newProduct.price,
        'imageUrl': newProduct.imageUrl,
      });
      await http.patch(url, body: encodedData);
      _products[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print("...");
    }
  }

  Future<void> deleteProduct(String prodId) async {
    final url = realtimeUrl + "products/$prodId.json?auth=$authToken";
    final existProdIndex =
        _products.indexWhere((productId) => productId.id == prodId);
    var existingProduct = _products[existProdIndex];

    _products.removeAt(existProdIndex);
    notifyListeners();

    //print(url);

    final delRes = await http.delete(url);

    if (delRes.statusCode >= 400) {
      //print(delRes.body);
      _products.insert(existProdIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }

    existingProduct = null;
  }
}
