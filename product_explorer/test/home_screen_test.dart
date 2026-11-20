import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_explorer/favorites_cubit.dart';
import 'package:product_explorer/home_screen.dart';
import 'package:product_explorer/product_bloc.dart';
import 'package:product_explorer/product_event.dart';
import 'package:product_explorer/product_state.dart';
import 'mocks.dart';

void main() {
  testWidgets(
      'shows mocked products; search and favorite work',
      (tester) async {
    final mockApi = MockApiService();
    when(() => mockApi.fetchAllProducts()).thenAnswer(
        (_) async => const [
              Product(id: 1, title: 'Mock Shirt',
                  description: '', price: 9.99,
                  category: 'clothing', image: '',
                  rating: 4.0),
              Product(id: 2, title: 'Mock Watch',
                  description: '', price: 49.99,
                  category: 'electronics', image: '',
                  rating: 4.5),
            ]);
    when(() => mockApi.fetchCategories()).thenAnswer(
        (_) async => ['clothing', 'electronics']);

    final productBloc = ProductBloc(mockApi)
      ..add(LoadProducts());
    final favoritesCubit = FavoritesCubit();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider.value(value: favoritesCubit),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mock Shirt'), findsOneWidget);
    expect(find.text('Mock Watch'), findsOneWidget);

    await tester.enterText(
        find.byType(TextField), 'watch');
    await tester.pumpAndSettle();
    expect(find.text('Mock Watch'), findsOneWidget);
    expect(find.text('Mock Shirt'), findsNothing);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap(
        find.byIcon(Icons.favorite_border).first);
    await tester.pump();
    expect(find.byIcon(Icons.favorite), findsWidgets);
  });
}
