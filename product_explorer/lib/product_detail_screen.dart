import 'package:material_ui/material_ui.dart';

import 'product.dart';
import 'product_card.dart' show ProductImage;

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Product')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SizedBox(height: 260, child: ProductImage(url: product.image)),
          const SizedBox(height: 16),
          Text(product.title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text('\$${product.price.toStringAsFixed(2)}  ·  '
              '★ ${product.rating.toStringAsFixed(1)}  ·  ${product.category}'),
          const SizedBox(height: 16),
          Text(product.description),
        ],
      ),
    );
  }
}
