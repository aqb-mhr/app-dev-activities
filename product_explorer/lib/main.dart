import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'api_service.dart';
import 'favorites_cubit.dart';
import 'home_screen.dart';
import 'product_bloc.dart';
import 'product_event.dart';

void main() {
  runApp(const ProductExplorerApp());
}

class ProductExplorerApp extends StatelessWidget {
  const ProductExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc(ApiService())..add(LoadProducts()),
        ),
        BlocProvider(create: (_) => FavoritesCubit()),
      ],
      child: MaterialApp(
        title: 'Product Explorer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo),
        home: const HomeScreen(),
      ),
    );
  }
}
