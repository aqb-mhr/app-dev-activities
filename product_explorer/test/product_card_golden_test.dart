import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:product_explorer/favorites_cubit.dart';
import 'package:product_explorer/product.dart';
import 'package:product_explorer/product_card.dart';

void main() {
  testWidgets('ProductCard matches its golden file',
      (tester) async {
    const product = Product(
      id: 1, title: 'Mock Shirt', description: '',
      price: 9.99, category: 'clothing',
      image: '', rating: 4.0,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          create: (_) => FavoritesCubit(),
          child: const Scaffold(
            body: ProductCard(product: product),
          ),
        ),
      ),
    );

    await expectLater(
      find.byType(ProductCard),
      matchesGoldenFile('goldens/product_card.png'),
    );
  });
}
