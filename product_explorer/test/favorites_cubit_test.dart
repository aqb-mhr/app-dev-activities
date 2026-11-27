import 'package:flutter_test/flutter_test.dart';
import 'package:product_explorer/favorites_cubit.dart';

void main() {
  group('FavoritesCubit', () {
    late FavoritesCubit cubit;

    setUp(() => cubit = FavoritesCubit());
    tearDown(() => cubit.close());

    test('toggle adds then removes an id', () {
      // Act
      cubit.toggle(1);
      // Assert
      expect(cubit.state, {1});

      // Act again
      cubit.toggle(1);
      // Assert again
      expect(cubit.state, <int>{});
    });
  });
}
