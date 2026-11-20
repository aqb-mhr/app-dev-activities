sealed class ProductEvent {}

/// Fetch products + categories from the API.
class LoadProducts extends ProductEvent {}

/// Narrow the grid to one category. `null` means "All".
class FilterByCategory extends ProductEvent {
  final String? category;
  FilterByCategory(this.category);
}

/// Narrow the grid by a free-text search on the title.
class SearchProducts extends ProductEvent {
  final String query;
  SearchProducts(this.query);
}
