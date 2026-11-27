import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_explorer/product_bloc.dart';
import 'package:product_explorer/product_event.dart';
import 'package:product_explorer/product_state.dart';
import 'package:product_explorer/settings_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mocks.dart';

void main() {
  group('ProductBloc', () {
    late MockApiService mockApi;
    late SettingsService settings;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      settings = SettingsService();
      mockApi = MockApiService();
      when(() => mockApi.fetchAllProducts())
          .thenAnswer((_) async => mockProducts);
      when(() => mockApi.fetchCategories()).thenAnswer(
        (_) async => ['clothing', 'electronics'],
      );
    });

    test('LoadProducts loads 2 mocked products', () async {
      // Arrange
      final bloc = ProductBloc(mockApi, FakeDb(), settings);
      // Act
      bloc.add(LoadProducts());
      // Assert
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<ProductState>(
          (s) => !s.loading && s.allProducts.length == 2,
        )),
      );
      verify(() => mockApi.fetchAllProducts()).called(1);
      await bloc.close();
    });

    test('FilterByCategory narrows visibleProducts',
        () async {
      final bloc = ProductBloc(mockApi, FakeDb(), settings);
      bloc.add(LoadProducts());
      await expectLater(bloc.stream,
          emitsThrough(
              predicate<ProductState>((s) => !s.loading)));

      bloc.add(FilterByCategory('electronics'));
      await expectLater(
        bloc.stream,
        emitsThrough(predicate<ProductState>((s) =>
            s.visibleProducts
                .every((p) => p.category == 'electronics'))),
      );
      await bloc.close();
    });
  });

  group('ProductBloc offline storage', () {
    late MockApiService mockApi;
    late SettingsService settings;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      settings = SettingsService();
      mockApi = MockApiService();
    });

    void networkUp() {
      when(() => mockApi.fetchAllProducts())
          .thenAnswer((_) async => mockProducts);
      when(() => mockApi.fetchCategories())
          .thenAnswer((_) async => ['clothing', 'electronics']);
    }

    void networkDown() {
      when(() => mockApi.fetchAllProducts())
          .thenThrow(Exception('No internet'));
      when(() => mockApi.fetchCategories())
          .thenThrow(Exception('No internet'));
    }

    test('a successful load saves the products to the cache', () async {
      networkUp();
      final db = FakeDb();
      final bloc = ProductBloc(mockApi, db, settings)..add(LoadProducts());
      await expectLater(bloc.stream,
          emitsThrough(predicate<ProductState>(
              (s) => !s.loading && s.allProducts.length == 2)));
      expect(db.rows.map((p) => p.title), ['Mock Shirt', 'Mock Watch']);
      await bloc.close();
    });

    test('offline with a cache: shows cached products, no spinner, no error',
        () async {
      networkDown();
      final db = FakeDb(mockProducts);
      final bloc = ProductBloc(mockApi, db, settings);
      final states = <ProductState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(LoadProducts());
      await Future<void>.delayed(Duration.zero);
      await bloc.close();
      await sub.cancel();

      expect(states, isNotEmpty);
      expect(states.any((s) => s.loading), isFalse); // never a spinner
      expect(states.last.error, isNull);
      expect(states.last.allProducts.length, 2);
      // Chips are rebuilt from the cache when /categories can't be reached.
      expect(states.last.categories, ['clothing', 'electronics']);
    });

    test('offline with no cache: shows the error', () async {
      networkDown();
      final bloc = ProductBloc(mockApi, FakeDb(), settings)
        ..add(LoadProducts());
      await expectLater(bloc.stream,
          emitsThrough(predicate<ProductState>(
              (s) => !s.loading && s.error != null)));
      await bloc.close();
    });

    test('the last category filter is saved and restored on the next launch',
        () async {
      networkUp();
      final db = FakeDb();
      final first = ProductBloc(mockApi, db, settings)..add(LoadProducts());
      await expectLater(first.stream,
          emitsThrough(predicate<ProductState>((s) => !s.loading)));
      first.add(FilterByCategory('electronics'));
      await expectLater(first.stream,
          emitsThrough(predicate<ProductState>(
              (s) => s.selectedCategory == 'electronics')));
      await first.close();

      // "Relaunch": a brand-new Bloc reading the same storage.
      final second = ProductBloc(mockApi, db, settings)..add(LoadProducts());
      await expectLater(second.stream,
          emitsThrough(predicate<ProductState>((s) =>
              !s.loading &&
              s.selectedCategory == 'electronics' &&
              s.visibleProducts.map((p) => p.title).toList()
                  .toString() == '[Mock Watch]')));
      await second.close();
    });

    test('choosing "All" clears the saved category', () async {
      networkUp();
      await settings.setLastCategory('clothing');
      final bloc = ProductBloc(mockApi, FakeDb(), settings)
        ..add(LoadProducts());
      await expectLater(bloc.stream,
          emitsThrough(predicate<ProductState>((s) => !s.loading)));
      bloc.add(FilterByCategory(null));
      await expectLater(bloc.stream,
          emitsThrough(predicate<ProductState>(
              (s) => s.selectedCategory == null)));
      await bloc.close();
      expect(await settings.getLastCategory(), isNull);
    });
  });
}
