import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'api_service.dart';
import 'database_helper.dart';
import 'favorites_cubit.dart';
import 'home_screen.dart';
import 'product_bloc.dart';
import 'product_event.dart';
import 'settings_service.dart';
import 'theme_cubit.dart';

Future<void> main() async {
  // Needed because we read shared_preferences before runApp.
  WidgetsFlutterBinding.ensureInitialized();
  final settings = SettingsService();
  final startDark = await settings.isDarkMode();
  runApp(ProductExplorerApp(settings: settings, startDark: startDark));
}

class ProductExplorerApp extends StatelessWidget {
  final SettingsService settings;
  final bool startDark;

  const ProductExplorerApp({
    super.key,
    required this.settings,
    this.startDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ProductBloc(ApiService(), DatabaseHelper(), settings)
            ..add(LoadProducts()),
        ),
        BlocProvider(create: (_) => FavoritesCubit()),
        BlocProvider(
          create: (_) => ThemeCubit(settings, startDark: startDark),
        ),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) => MaterialApp(
          title: 'Product Explorer',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(colorSchemeSeed: Colors.indigo),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        ),
      ),
    );
  }
}
