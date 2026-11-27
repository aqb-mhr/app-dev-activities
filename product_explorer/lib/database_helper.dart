import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'product.dart';

/// Step 2 -- sqflite: a real SQLite database file on the device, used here as
/// an offline cache of the product list.
class DatabaseHelper {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    final path = join(await getDatabasesPath(), 'product_explorer.db');
    _db = await openDatabase(
      path,
      version: 1,
      // Runs exactly once: the first time the file is created on this device.
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cached_products(
            id INTEGER PRIMARY KEY,
            title TEXT,
            description TEXT,
            price REAL,
            category TEXT,
            image TEXT,
            rating REAL
          )
        ''');
      },
    );
    return _db!;
  }

  /// Replaces the whole cache with [products] in one transaction, so a crash
  /// half-way never leaves an empty or half-written cache behind.
  Future<void> cacheProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('cached_products');
    for (final p in products) {
      batch.insert('cached_products', {
        'id': p.id,
        'title': p.title,
        'description': p.description,
        'price': p.price,
        'category': p.category,
        'image': p.image,
        'rating': p.rating,
      });
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getCachedProducts() async {
    final db = await database;
    final rows = await db.query('cached_products', orderBy: 'id');
    return rows
        .map((r) => Product(
              id: r['id'] as int,
              title: r['title'] as String,
              description: r['description'] as String,
              price: (r['price'] as num).toDouble(),
              category: r['category'] as String,
              image: r['image'] as String,
              rating: (r['rating'] as num).toDouble(),
            ))
        .toList();
  }

  Future<void> clearCache() async {
    final db = await database;
    await db.delete('cached_products');
  }
}
