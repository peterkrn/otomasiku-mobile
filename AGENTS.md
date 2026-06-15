# AGENTS.md

## Commands

```bash
flutter pub get                # install deps + generate ARB localization code
dart run build_runner build    # regenerate .g.dart after model changes
flutter analyze                # must be clean before commit
flutter test                   # run all tests
flutter run                    # run on device/emulator
flutter build appbundle        # production build
```

Always prefix commands with `./rtk.exe` (token-saving wrapper):
```bash
./rtk.exe flutter analyze
./rtk.exe git diff
```

No CI — analyze and test must pass locally.

## Entry & Wiring

`lib/main.dart` → initializes Firebase, loads `.env` (flutter_dotenv), initializes Supabase (PKCE auth), configures `ApiClient` singleton, initializes `NotificationService`, then `runApp(ProviderScope(child: OtomasikuApp()))`.

`lib/app.dart` → `MaterialApp.router(routerConfig: appRouter, ...)` with light/dark theme, GoRouter, and `AppLocalizations`.

## Architecture

```
lib/main.dart             # entrypoint
lib/app.dart              # MaterialApp.router + theme
lib/core/                 # auth, config, constants, errors, network, router, notifications, utils
lib/models/               # @JsonSerializable() Dart models + generated .g.dart
lib/providers/            # Riverpod providers for all business state
lib/data/repositories/    # data access layer
lib/features/             # per-screen feature folders
lib/shared/widgets/       # reusable widgets (OfflineBanner, ProductImage, ShimmerGrid)
lib/l10n/                 # app_id.arb + app_en.arb → auto-generated AppLocalizations
```

## GoRouter (named routes only)

Route names are constants in `lib/core/router/app_router.dart` — `AppRoute` abstract class. Never use raw path strings.

```
context.goNamed(AppRoute.productDetail, pathParameters: {'id': product.id})
context.pushNamed(AppRoute.cart)
```

Never `Navigator.push`. Never raw path strings like `context.go('/home')`.

StatefulShellRoute wraps 4 bottom tabs (home, search, projects, profile). Back button on non-home tabs goes to home via `PopScope`. Auth redirect in GoRouter guards login state.

## Non-obvious conventions

- **Money = `int` only** (Rupiah). `CurrencyFormatter.format(int)`. Always multiply before divide, use `~/`.
- **i18n**: `AppLocalizations.of(context)!` (non-nullable — `nullable-getter: false` in `l10n.yaml`). Define every key in BOTH `app_id.arb` + `app_en.arb`. `flutter pub get` triggers ARB codegen.
- **Riverpod** for all business state. `setState` only for local UI affordances.
- **Models are pure Dart**: no `import 'package:flutter/material.dart'`, no hardcoded UI strings. Use `@JsonSerializable()` + `dart run build_runner build`.
- **JSON type mismatches are silent**: if `@JsonSerializable` field types don't match API response types, the provider's error resilience silently swallows the error and returns empty data. Always verify model types against actual API shapes.
- **Tokens**: `flutter_secure_storage` only. `shared_preferences` exists but only for non-sensitive cache.
- **Images**: `Image.asset()` with `errorBuilder`. Every asset subfolder in `pubspec.yaml` assets list. After adding folders: `flutter pub get` (hot reload won't pick up new assets).
- **Back button (Instagram-like)**: `PopScope` in `StatefulShellRoute` — home tab exits app; other tabs navigate to home tab first.
- **Cards**: `childAspectRatio: 0.58`, bottom padding 96px, `Spacer()` before action button.
- **No `dynamic`** types. Parse JSON to typed models.
- **`.env`** loaded via `flutter_dotenv`, committed to pubspec assets. Contains `API_BASE_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`.
- **Supabase PKCE** auth flow (`AuthFlowType.pkce`).
- **401 handling**: `ApiInterceptor` refreshes token once, fires `onSessionExpired` → `appRouter.goNamed(AppRoute.login)`.
- **Error codes** from Express (e.g. `INSUFFICIENT_STOCK`) must be translated via `translateErrorCode()` in `core/utils/error_handler.dart` — never display raw server strings.

## Mandatory reading

- `docs/AI_RULES.md` — 548-line mandatory conventions (overrides everything else)
- `docs/ARCHITECTURE.md` — DB schema, tech stack, API design
- `CONVENTIONS.md` — proven patterns, known pitfalls (updates when bugs are fixed)
- `docs/PRD.md` — product requirements
