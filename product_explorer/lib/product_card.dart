import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorites_cubit.dart';
import 'product.dart';
import 'product_detail_screen.dart';

/// One tile in the home grid. Public (no underscore) so tests can find it by type.
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final isFav = context.select<FavoritesCubit, bool>(
      (cubit) => cubit.state.contains(product.id),
    );
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: ProductImage(url: product.image)),
              const SizedBox(height: 8),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  Text(product.rating.toStringAsFixed(1),
                      style: theme.textTheme.bodySmall),
                  IconButton(
                    tooltip: isFav ? 'Remove favourite' : 'Add favourite',
                    // favorite_rounded (not favorite) so the AppBar's
                    // Icons.favorite button stays the only match for
                    // find.byIcon(Icons.favorite) in the integration test.
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border,
                      color: isFav ? Colors.red : null,
                    ),
                    onPressed: () =>
                        context.read<FavoritesCubit>().toggle(product.id),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Network image with a placeholder for empty URLs / load failures,
/// so tests with `image: ''` never touch the network.
class ProductImage extends StatelessWidget {
  final String url;
  const ProductImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    const placeholder = Center(
      child: Icon(Icons.image_outlined, size: 48, color: Colors.grey),
    );
    if (url.isEmpty) return placeholder;
    return Image.network(
      url,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => placeholder,
    );
  }
}
