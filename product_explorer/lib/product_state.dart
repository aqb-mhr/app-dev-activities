import 'product.dart';

export 'product.dart';

class ProductState {
  final bool loading;
  final String? error;
  final List<Product> allProducts;
  final List<String> categories;
  final String? selectedCategory;
  final String query;

  const ProductState({
    this.loading = false,
    this.error,
    this.allProducts = const [],
    this.categories = const [],
    this.selectedCategory,
    this.query = '',
  });

  /// What the grid actually shows: category filter + search, combined.
  List<Product> get visibleProducts {
    final q = query.trim().toLowerCase();
    return allProducts.where((p) {
      final categoryOk =
          selectedCategory == null || p.category == selectedCategory;
      final queryOk = q.isEmpty || p.title.toLowerCase().contains(q);
      return categoryOk && queryOk;
    }).toList();
  }

  ProductState copyWith({
    bool? loading,
    String? error,
    bool clearError = false,
    List<Product>? allProducts,
    List<String>? categories,
    String? selectedCategory,
    bool clearCategory = false,
    String? query,
  }) {
    return ProductState(
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      allProducts: allProducts ?? this.allProducts,
      categories: categories ?? this.categories,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      query: query ?? this.query,
    );
  }
}
