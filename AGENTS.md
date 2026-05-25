# AGENTS.md

## Two repos on this machine

| Project | Path | Commands |
|---------|------|----------|
| **Flutter app** | `C:\dev\projects\otomasiku-mobile` (this repo) | Flutter only |
| **Express API** | `C:\dev\projects\otomasiku-api` | pnpm, Node only |

Never cross-run commands. Flutter commands here, pnpm commands there.

---

## Agent Roles

Multiple agents run in parallel on this project. Each has a defined scope and a set of mandatory skills. Agents must not exceed their scope.

### 🏗️ Implementer Agent
**Scope:** Write production code, implement specs, create/modify files.

**Mandatory skills — use at the right moment (see trigger table below):**

| Skill | File | When to invoke |
|-------|------|----------------|
| `test-driven-development` | `C:\Users\peter\.kiro\skills\test-driven-development\SKILL.md` | Before writing ANY implementation code for a new feature or bug fix |
| `ui-ux-pro-max` | `C:\Users\peter\.kiro\skills\ui-ux-pro-max\SKILL.md` | When building or modifying any Flutter screen, widget, or visual component |
| `supabase` | `C:\Users\peter\.kiro\skills\supabase\SKILL.md` | When touching Supabase Auth, RLS, Edge Functions, Storage, or the supabase_flutter SDK |
| `verification-before-completion` | `C:\Users\peter\.kiro\skills\verification-before-completion\SKILL.md` | Before claiming any task is done — run `flutter analyze` / `flutter test`, read output, then claim |

**Workflow per spec:**
1. Create branch: `git checkout -b feat/spec-XX-short-description`
2. Read onboarding skill: `docs/skills/SKILL-onboarding.md`
3. Read the spec: `docs/specs/phase_3_integrations/XX-name.md`
4. Invoke `test-driven-development` skill before writing code
5. Invoke `ui-ux-pro-max` skill for any UI work
6. Invoke `supabase` skill for any Supabase work
7. Implement, then invoke `verification-before-completion` before marking done
8. Request code review (see Code Reviewer Agent below)

---

### 🔍 Code Reviewer Agent
**Scope:** Review PRs and completed tasks for correctness, AI_RULES.md compliance, and bugs. Never writes production code.

**Skill:** `.agents/skills/code-review/SKILL.md` — follow this skill's multi-agent parallel review process exactly.

**Also uses:** `requesting-code-review` skill (`C:\Users\peter\.kiro\skills\requesting-code-review\SKILL.md`) to structure review requests from the Implementer.

**When invoked:**
- After each spec is implemented (mandatory before merge)
- When Implementer is stuck and needs a fresh perspective
- Before any PR to `develop` or `main`

**Review checklist (in addition to `.agents/skills/code-review/SKILL.md`):**
- [ ] No `dynamic` types in Dart
- [ ] No hardcoded strings in widgets (all via `AppLocalizations`)
- [ ] All money values use `CurrencyFormatter.format(int)` — never `double`
- [ ] No `Navigator.push` — only `context.goNamed()`
- [ ] No `SharedPreferences` for tokens — only `flutter_secure_storage`
- [ ] No `print()` — only `debugPrint()` wrapped in `kDebugMode`
- [ ] All new ARB keys exist in both `app_id.arb` and `app_en.arb`
- [ ] `flutter analyze` clean

---

### 🏛️ Architect Agent
**Scope:** Identify architectural friction, propose refactors, maintain codebase health. Does not implement — proposes only.

**Mandatory skills:**

| Skill | File | When to invoke |
|-------|------|----------------|
| `improve-codebase-architecture` | `C:\Users\peter\.kiro\skills\improve-codebase-architecture\SKILL.md` | When asked to review architecture, after 2+ specs land, or when Implementer reports coupling/testability friction |
| `supabase-postgres-best-practices` | `C:\Users\peter\.kiro\skills\supabase-postgres-best-practices\SKILL.md` | When reviewing any schema design, RLS policy, or Postgres query (even if written on the Express side) |

**When invoked:**
- After every 2–3 specs complete (periodic health check)
- When Implementer flags tight coupling or hard-to-test code
- Before any major refactor

---

### 🐛 Debugger Agent
**Scope:** Diagnose bugs and performance regressions. Does not implement fixes — hands off to Implementer with a root-cause report.

**Mandatory skill:**

| Skill | File | When to invoke |
|-------|------|----------------|
| `diagnose` | `C:\Users\peter\.kiro\skills\diagnose\SKILL.md` | Always — this agent's entire workflow IS the diagnose skill |

**When invoked:**
- User says "this is broken", "diagnose this", or describes a crash/regression
- `flutter analyze` or `flutter test` fails and the cause is non-obvious

---

## Skill Usage — Sweet Spot Reference

> Skills are not used on every task. Use them when the trigger condition is met.

| Skill | Use | Skip |
|-------|-----|------|
| `test-driven-development` | New feature, bug fix, any new Dart function with logic | Config files, ARB strings, pubspec changes |
| `ui-ux-pro-max` | New screen, new widget, visual refactor, accessibility review | Pure backend/network code, model classes, providers with no UI |
| `supabase` | Supabase Auth integration, RLS, `supabase_flutter` SDK calls | Dio/Express API calls, local state, non-Supabase network code |
| `supabase-postgres-best-practices` | Schema design review, RLS policy writing, query optimization | Flutter-only code, no DB involvement |
| `improve-codebase-architecture` | Post-sprint architecture review, coupling complaints, testability issues | Single-file changes, routine spec implementation |
| `requesting-code-review` | After each spec, before merge | Trivial one-liner fixes (use judgment) |
| `diagnose` | Bug reports, test failures, performance regressions | Greenfield implementation with no existing bug |
| `verification-before-completion` | Before EVERY completion claim — no exceptions | Nothing. This one is always used. |

---

## Ramp-up reading order

1. `docs/PRD.md` — product requirements, user stories
2. `docs/ARCHITECTURE.md` — schema, folder structure, tech stack
3. `docs/AI_RULES.md` — **mandatory** coding conventions (overrides general best practices)
4. `docs/PLAN_MILESTONE_2.md` or `docs/specs/phase_3_integrations/00-index.md` — current work
5. The specific spec in `docs/specs/` before implementing

---

## Developer commands

```bash
flutter analyze           # static analysis (must be clean before commit)
flutter test              # run all tests
flutter run               # run on device/emulator
flutter build appbundle   # production build
flutter pub get           # install dependencies
```

No CI workflows — lint/analyze/test must pass locally.

## RTK (token-saving command wrapper)

Project root has `rtk.exe` — prefix all commands with `./rtk.exe` to reduce output tokens (60-90% savings):
```bash
./rtk.exe flutter analyze
./rtk.exe git status
./rtk.exe git commit -m "msg"
```

---

## Architecture

```
lib/
├── main.dart             # entrypoint: init Supabase, ApiClient, then runApp
├── app.dart              # OtomasikuApp (MaterialApp.router, theme, locale)
├── core/                 # shared infra (config, constants, errors, network, router, utils)
├── models/               # typed Dart models (Product, Order, Address, CartItem, etc.)
├── providers/            # Riverpod providers (auth, cart, locale, order, payment, api, connectivity)
├── features/auth/        # login/register screens
├── features/splash/      # splash screen
├── shared/widgets/       # reusable widgets (offline_banner)
├── data/dummy/           # Milestone 2 dummy data (6 files)
└── l10n/                 # ARB localization files (app_id.arb, app_en.arb)
```

---

## Non-obvious conventions

- **Money = `int` only** in Rupiah (19800000 = Rp 19.800.000). Never double/float.
- **CurrencyFormatter.format(int)** is the only way to display prices.
- **Riverpod** for all business state. Never `setState` outside local UI.
- **GoRouter named routes** (`context.goNamed('routeName')`). Never `Navigator.push`.
- **AppLocalizations.of(context)** (non-nullable) for all user-facing strings. Define in both `app_id.arb` + `app_en.arb` before using. No hardcoded strings in widgets.
- **Image.asset()** with `errorBuilder` for product images. Never `Image.network()` or placeholder URLs.
- **flutter_secure_storage** for tokens. Never SharedPreferences.
- **No `dynamic`** in Dart. Parse JSON to typed models.
- **`l10n.yaml`** has `nullable-getter: false`, so `AppLocalizations.of(context)` returns non-nullable.

---

## Networking (Phase 3)

- `ApiClient` is a singleton — configure once in `main.dart` via `ApiClient().configure(supabase: ...)`.
- `ApiInterceptor` injects auth token, `Accept-Language`, and `x-correlation-id` on every request.
- On 401: one retry attempt via `supabase.auth.refreshSession()`. If refresh fails, fires `onSessionExpired` callback.
- DioException mapped to typed exceptions: `NetworkException`, `TimeoutException`, `SessionExpiredException`, `ApiException(code, statusCode)`, `ServerException(correlationId)`.
- `connectivity_plus` via `connectivityProvider` StreamProvider; `OfflineBanner` widget in `shared/widgets/`.
- Error codes from Express (`"code": "INSUFFICIENT_STOCK"`) must be translated via `translateErrorCode()` — never display raw server strings.

---

## i18n

- `flutter pub get` auto-generates `lib/l10n/app_localizations.dart` from ARB files.
- If an ARB key is missing from either file, the build fails.
- Locale persisted to `flutter_secure_storage` by `LocaleNotifier`.

---

## Spec-driven development (SDD)

- Every user story **must** have an approved spec before coding.
- Specs live in `docs/specs/` (Phase 3: `docs/specs/phase_3_integrations/`).
- Workflow: create branch → read spec → implement → verify → run `flutter analyze` → update spec status to ✅ Done → request code review.
- Branch naming: `feat/spec-XX-description` (one branch per spec, always).
- Commit style: Conventional Commits (`feat(scope): msg`, `chore(scope): msg`).

---

## Product catalog (125 items)

| Cat | Brand | Count |
|-----|-------|-------|
| Inverter | Mitsubishi | 33 (MIT-INV-001–033) |
| PLC | Mitsubishi | 32 (MIT-PLC-001–032) |
| HMI | Mitsubishi | 11 (MIT-HMI-001–011) |
| Servo | Mitsubishi | 20 (MIT-SRV-001–020) |
| Inverter | Danfoss | 29 (DAN-INV-001–029) |

Full mapping: `docs/DUMMY_PRODUCT_MAPPING_PLAN.md`

---

## Brand colors

- Primary: `#E7192D` (Mitsubishi Red)
- Background: `#F9FAFB`
- BCA Blue: `#0066AE`
- Danfoss Blue: `#005A8C`
- Font: Inter (via `google_fonts`)
- Card radius: 16px, Button radius: 12px, Input radius: 8px
- Min touch target: 44×44dp
- Bottom padding: 96px on scrollable screens
