import 'package:flutter_bloc/flutter_bloc.dart';

import 'api_service.dart';
import 'database_helper.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'settings_service.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService _api;
  final DatabaseHelper _db;
  final SettingsService _settings;

  ProductBloc(this._api, this._db, this._settings)
      : super(const ProductState()) {
    on<LoadProducts>(_onLoad);
    on<FilterByCategory>((event, emit) async {
      emit(event.category == null
          ? state.copyWith(clearCategory: true)
          : state.copyWith(selectedCategory: event.category));
      await _settings.setLastCategory(event.category);
    });
    on<SearchProducts>((event, emit) => emit(state.copyWith(query: event.query)));
  }

  /// Step 3 -- local first, network second.
  Future<void> _onLoad(LoadProducts event, Emitter<ProductState> emit) async {
    // 1. Read what is already on the device: the product cache (sqflite) and
    //    the last category filter (shared_preferences).
    final cached = await _readCache();
    final lastCategory = await _settings.getLastCategory();

    // 2. Show it immediately. With a cache there is no spinner at all.
    var next = cached.isNotEmpty
        ? state.copyWith(
            loading: false,
            clearError: true,
            allProducts: cached,
            categories: _categoriesOf(cached),
          )
        : state.copyWith(loading: true, clearError: true);
    if (lastCategory != null) {
      next = next.copyWith(selectedCategory: lastCategory);
    }
    emit(next);

    // 3. Refresh from the network in the background, save, and update.
    try {
      final results = await Future.wait([
        _api.fetchAllProducts(),
        _api.fetchCategories(),
      ]);
      final fresh = results[0] as List<Product>;
      await _db.cacheProducts(fresh);
      emit(state.copyWith(
        loading: false,
        allProducts: fresh,
        categories: results[1] as List<String>,
      ));
    } catch (e) {
      // A failed network call only becomes a visible error when there was
      // nothing local to fall back on.
      if (cached.isEmpty) {
        emit(state.copyWith(loading: false, error: e.toString()));
      }
    }
  }

  Future<List<Product>> _readCache() async {
    try {
      return await _db.getCachedProducts();
    } catch (_) {
      return const []; // An unreadable cache is treated as an empty one.
    }
  }

  /// Offline there is no /categories call, so rebuild the chip list from the
  /// cached products (in the order they first appear).
  static List<String> _categoriesOf(List<Product> products) =>
      products.map((p) => p.category).toSet().toList();
}
