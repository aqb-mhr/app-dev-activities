import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:product_explorer/favorites_cubit.dart';
import 'package:product_explorer/home_screen.dart';
import 'package:product_explorer/product_bloc.dart';
import 'package:product_explorer/product_event.dart';
import 'package:product_explorer/settings_service.dart';
import 'package:product_explorer/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mocks.dart';

void main() {
  late SettingsService settings;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService();
  });

  Widget wrap(ProductBloc productBloc, ThemeCubit themeCubit) =>
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: productBloc),
          BlocProvider(create: (_) => FavoritesCubit()),
          BlocProvider.value(value: themeCubit),
        ],
        child: const MaterialApp(home: HomeScreen()),
      );

  testWidgets(
      'shows mocked products; search and favorite work',
      (tester) async {
    final mockApi = MockApiService();
    when(() => mockApi.fetchAllProducts())
        .thenAnswer((_) async => mockProducts);
    when(() => mockApi.fetchCategories()).thenAnswer(
        (_) async => ['clothing', 'electronics']);

    final productBloc = ProductBloc(mockApi, FakeDb(), settings)
      ..add(LoadProducts());

    await tester.pumpWidget(wrap(productBloc, ThemeCubit(settings)));
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

  testWidgets('offline: cached products show instead of an error',
      (tester) async {
    final mockApi = MockApiService();
    when(() => mockApi.fetchAllProducts())
        .thenThrow(Exception('No internet'));
    when(() => mockApi.fetchCategories())
        .thenThrow(Exception('No internet'));

    final productBloc = ProductBloc(mockApi, FakeDb(mockProducts), settings)
      ..add(LoadProducts());

    await tester.pumpWidget(wrap(productBloc, ThemeCubit(settings)));
    await tester.pumpAndSettle();

    expect(find.text('Mock Shirt'), findsOneWidget);
    expect(find.textContaining('Something went wrong'), findsNothing);
    expect(find.widgetWithText(ChoiceChip, 'electronics'), findsOneWidget);
  });

  testWidgets('dark mode toggle switches the theme and is saved',
      (tester) async {
    final mockApi = MockApiService();
    when(() => mockApi.fetchAllProducts())
        .thenAnswer((_) async => mockProducts);
    when(() => mockApi.fetchCategories())
        .thenAnswer((_) async => ['clothing', 'electronics']);
    final productBloc = ProductBloc(mockApi, FakeDb(), settings)
      ..add(LoadProducts());
    final themeCubit = ThemeCubit(settings);

    await tester.pumpWidget(wrap(productBloc, themeCubit));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pumpAndSettle();

    expect(themeCubit.state, isTrue);
    expect(find.byIcon(Icons.light_mode), findsOneWidget);
    expect(await settings.isDarkMode(), isTrue);
  });
}
