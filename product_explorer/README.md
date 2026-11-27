# Product Explorer – Offline Storage (Class Activity, CSE-450)

The Product Explorer BLoC app (search + category chips + grid, fakestoreapi.com) with the offline storage
from `OfflineStorage-Class-Activity-ProductExplorer.pdf` added.
Starting point: a copy of `../../testing-activity/product_explorer` (that folder is unchanged).

## Run
```
flutter pub get
flutter emulators --launch Pixel_8
flutter run -d emulator-5554
flutter test
```

## What was added
| File | Role |
|---|---|
| `lib/settings_service.dart` | **shared_preferences** wrapper: `dark_mode` (bool) and `last_category` (String) |
| `lib/database_helper.dart` | **sqflite**: `product_explorer.db` with a `cached_products` table; `cacheProducts`, `getCachedProducts`, `clearCache` |
| `lib/theme_cubit.dart` | Holds dark mode (`bool`) and saves every change through `SettingsService` |
| `lib/product_bloc.dart` | `LoadProducts` is now **local first, network second**; `FilterByCategory` saves the choice |
| `lib/main.dart` | Reads dark mode **before** `runApp`, so the first frame already has the right theme |
| `lib/home_screen.dart` | Sun/moon button in the AppBar toggles dark mode |

## How `LoadProducts` works now
1. Read the cache (sqflite) and the last category (shared_preferences).
2. If the cache has products, show them **immediately** – `loading: false`, so no spinner. Otherwise show the spinner.
3. Fetch products + categories from the API, save the products to the cache, and update the screen.
4. If the network fails: show an error **only if there was nothing cached**. Otherwise keep showing the cached products.

## Differences from the PDF listings
- **Last category is restored inside the Bloc, not in `HomeScreen.initState`.** In the manual, `initState` adds
  `LoadProducts` and then (asynchronously) `FilterByCategory`. Bloc runs those handlers concurrently, so the filter
  could be applied and then overwritten when products load. Restoring it in the `LoadProducts` handler avoids that
  race, and `HomeScreen` stays a `StatelessWidget`.
- **Category chips work offline.** The original app gets chips from `/products/categories`; offline, they're rebuilt
  from the cached products.
- **Dark mode uses a `ThemeCubit`** instead of `setState` in `MyApp`, so the toggle can live in `HomeScreen`'s AppBar.
- `cacheProducts` puts the `DELETE` and the inserts in **one batch** (one transaction), so a crash half-way can't
  leave an empty cache. Prices/ratings are read with `(… as num).toDouble()` in case SQLite hands back an int.
- `state.error` stays a `String?` (as in the existing app) rather than the PDF's `bool`.
- Product **images** are not cached (neither is that in the manual); offline they show a placeholder.

## Tests (`flutter test`, 12 total)
The existing tests were updated for the new constructor `ProductBloc(api, db, settings)`. They use `FakeDb`
(in-memory, in `test/mocks.dart`) and `SharedPreferences.setMockInitialValues`. New tests cover: products saved to
the cache, offline + cache (no spinner, no error, chips rebuilt), offline + no cache (error), last category restored
after a "relaunch", "All" clears the saved category, the offline widget path, and the dark-mode toggle.

## Live demo checklist (from the manual) – verified on the Pixel 8 emulator
1. Online launch → `cached_products` filled with all 20 products.
2. Airplane mode + kill + reopen → products appear from the cache, no error.
   *(On the emulator, airplane mode alone may not cut the network – also turn off Wi-Fi and mobile data.)*
3. Pick a category offline, relaunch → still filtered.
4. Toggle dark mode, relaunch → already dark on the first frame.
5. Back online, relaunch → list refreshes silently (chip order switches to the API's order, images load).

Note: a **debug** build started from the app icon (not via `flutter run`) takes a few seconds on the splash
screen while Dart code is compiled – that's debug mode, not the app logic.
