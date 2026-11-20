import 'dart:convert';

import 'package:http/http.dart' as http;

import 'product.dart';

/// Talks to the real fakestoreapi.com. Tests replace it with a mocktail mock.
class ApiService {
  static const _base = 'https://fakestoreapi.com';
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchAllProducts() async {
    final res = await _client.get(Uri.parse('$_base/products'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load products (${res.statusCode})');
    }
    final list = jsonDecode(res.body) as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<String>> fetchCategories() async {
    final res = await _client.get(Uri.parse('$_base/products/categories'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load categories (${res.statusCode})');
    }
    return (jsonDecode(res.body) as List<dynamic>).cast<String>();
  }
}
