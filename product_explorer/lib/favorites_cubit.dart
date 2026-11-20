import 'package:flutter_bloc/flutter_bloc.dart';

/// Holds the ids of favourited products.
class FavoritesCubit extends Cubit<Set<int>> {
  FavoritesCubit() : super(<int>{});

  void toggle(int id) {
    final next = Set<int>.of(state);
    if (!next.remove(id)) next.add(id);
    emit(next);
  }

  bool isFavorite(int id) => state.contains(id);
}
