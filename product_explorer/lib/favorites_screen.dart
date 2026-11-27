import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'favorites_cubit.dart';
import 'product_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ids = context.watch<FavoritesCubit>().state;
    final favs = context
        .watch<ProductBloc>()
        .state
        .allProducts
        .where((p) => ids.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: favs.isEmpty
          ? const Center(child: Text('No favourites yet'))
          : ListView.builder(
              itemCount: favs.length,
              itemBuilder: (context, i) {
                final p = favs[i];
                return ListTile(
                  title: Text(p.title,
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('\$${p.price.toStringAsFixed(2)}'),
                  trailing: IconButton(
                    tooltip: 'Remove favourite',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () =>
                        context.read<FavoritesCubit>().toggle(p.id),
                  ),
                );
              },
            ),
    );
  }
}
