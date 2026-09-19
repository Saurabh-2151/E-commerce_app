import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'fakestoreapi.com';
  List<Product>? _allProductsCache;

  Future<List<String>> fetchCategories() async {
    final uri = Uri.https(_baseUrl, '/products/categories');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load categories (${response.statusCode})');
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data.cast<String>();
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      // Explicitly encode apostrophe as %27
      final encoded = Uri.encodeComponent(category).replaceAll("'", '%27');
      final uri = Uri.https(_baseUrl, '/products/category/$encoded');
      
      if (kDebugMode) {
        print('[API] Fetching: $uri');
      }
      
      final response = await http.get(uri);
      
      if (kDebugMode) {
        print('[API] Category "$category" → Status ${response.statusCode}, Body length ${response.body.length}');
      }

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        final products = data
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
        
        if (products.isNotEmpty) {
          return products;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('[API] Error fetching category "$category": $e');
      }
    }

    // Fallback: fetch all products and filter client-side
    if (kDebugMode) {
      print('[API] Falling back to client-side filter for "$category"');
    }
    return _fetchAllAndFilter(category);
  }

  Future<List<Product>> _fetchAllAndFilter(String category) async {
    if (_allProductsCache == null) {
      final uri = Uri.https(_baseUrl, '/products');
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception('Failed to load products (${response.statusCode})');
      }

      final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
      _allProductsCache = data
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      
      if (kDebugMode) {
        print('[API] Cached ${_allProductsCache!.length} products');
      }
    }

    return _allProductsCache!
        .where((p) => p.category == category)
        .toList();
  }

  Future<Product> fetchProductById(int id) async {
    final uri = Uri.https(_baseUrl, '/products/$id');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Failed to load product $id (${response.statusCode})');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  void clearCache() {
    _allProductsCache = null;
  }
}
