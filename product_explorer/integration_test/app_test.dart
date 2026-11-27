import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:product_explorer/main.dart' as app;
import 'package:product_explorer/product_card.dart';
import 'package:product_explorer/product_detail_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding
      .ensureInitialized();

  testWidgets('search, filter, favorite, and find it again',
      (tester) async {
    app.main(); // drive: open the real app
    await tester.pumpAndSettle();

    await tester.enterText( // drive: type a search
        find.byType(TextField), 'shirt');
    await tester.pumpAndSettle();
    expect(find.byType(ProductCard), findsWidgets);

    await tester.enterText(find.byType(TextField), '');
    await tester.pumpAndSettle();
    await tester.tap( // drive: tap a chip
        find.text('electronics'));
    await tester.pumpAndSettle();

    await tester.tap( // drive: open a product
        find.byType(ProductCard).first);
    await tester.pumpAndSettle();
    expect(find.byType(ProductDetailScreen),
        findsOneWidget);

    await tester.pageBack(); // drive: the back arrow
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(
        Icons.favorite_border).first);
    await tester.pumpAndSettle();

    await tester.tap( // drive: open Favorites
        find.byIcon(Icons.favorite));
    await tester.pumpAndSettle();
    expect(find.byType(ListTile), findsWidgets);
  });
}
