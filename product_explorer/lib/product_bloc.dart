import 'package:flutter_bloc/flutter_bloc.dart';

import 'api_service.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ApiService _api;

  ProductBloc(this._api) : super(const ProductState()) {
    on<LoadProducts>(_onLoad);
    on<FilterByCategory>((event, emit) {
      emit(event.category == null
          ? state.copyWith(clearCategory: true)
          : state.copyWith(selectedCategory: event.category));
    });
    on<SearchProducts>((event, emit) => emit(state.copyWith(query: event.query)));
  }

  Future<void> _onLoad(LoadProducts event, Emitter<ProductState> emit) async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final results = await Future.wait([
        _api.fetchAllProducts(),
        _api.fetchCategories(),
      ]);
      emit(state.copyWith(
        loading: false,
        allProducts: results[0] as List<Product>,
        categories: results[1] as List<String>,
      ));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
