import 'package:mocktail/mocktail.dart';
import 'package:product_explorer/api_service.dart';
import 'package:product_explorer/database_helper.dart';
import 'package:product_explorer/product.dart';

class MockApiService extends Mock
    implements ApiService {}

/// In-memory stand-in for the sqflite cache (sqflite can't run in unit tests).
class FakeDb extends DatabaseHelper {
  List<Product> rows;
  FakeDb([List<Product>? initial]) : rows = [...?initial];

  @override
  Future<void> cacheProducts(List<Product> products) async =>
      rows = [...products];

  @override
  Future<List<Product>> getCachedProducts() async => [...rows];

  @override
  Future<void> clearCache() async => rows = [];
}

const mockProducts = [
  Product(id: 1, title: 'Mock Shirt',
      description: '', price: 9.99,
      category: 'clothing', image: '',
      rating: 4.0),
  Product(id: 2, title: 'Mock Watch',
      description: '', price: 49.99,
      category: 'electronics', image: '',
      rating: 4.5),
];
