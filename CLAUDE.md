# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Project Context

- Read `docs/PRD.md` before implementing any feature — it defines all modules, user stories, and acceptance criteria
- Follow `docs/AI_RULES.md` for **ALL** coding decisions — these rules are mandatory and override general best practices
- Consult `docs/ARCHITECTURE.md` before creating or modifying files — it defines the schema, folder structure, and tech stack
- Check `docs/PLAN.md` for the full-project execution plan (Phase 0–11)
- Check `docs/PLAN_MILESTONE_2.md` for the current milestone — Flutter UI-only with dummy data
- Check `docs/DUMMY_PRODUCT_MAPPING_PLAN.md` for the 125-product catalog, image mappings, and Product model

---

## Auto-loaded skill files
@docs/skills/SKILL-onboarding.md

## What This Project Is
B2B industrial automation marketplace. Flutter (Android) + Express.js + Supabase PostgreSQL.
...
```

**Always use Context7 MCP when I need library/API documentation, code generation, setup or configuration steps without me having to explicitly ask.**

## Skills

- For Flutter UI screens → follow `docs/skills/flutter-ui/SKILL.md`
- For database & Prisma operations → follow `docs/skills/database/SKILL.md`
- For Express API endpoints → follow `docs/skills/api/SKILL.md`
- For BCA payment integration → follow `docs/skills/payment/SKILL.md`
- For testing strategies → follow `docs/skills/testing/SKILL.md`
- For spec-driven development workflow → follow `docs/skills/sdd/SKILL.md`

---

## Project Overview

Otomasiku is a **B2B marketplace mobile app** (Android + Admin Web) for industrial automation parts (Inverter, PLC, HMI, Servo). Built with a hybrid architecture:

- **Flutter** (Dart) — Mobile app + Admin web panel
- **Express.js** (TypeScript) — Custom API layer with Prisma ORM
- **Supabase** — Managed PostgreSQL, Auth, Storage
- **BCA Developer API** — Virtual Account payment (automated callback)

**Brand:** Otomasiku · **Products:** 125 items (Mitsubishi + Danfoss) · **Language:** Bahasa Indonesia

---

## Repository Structure

```
otomasiku-mobile-app/
├── CLAUDE.md                          # ← You are here
├── docs/
│   ├── PRD.md                         # Product requirements & user stories
│   ├── ARCHITECTURE.md                # Tech architecture, DB schema, API design
│   ├── PLAN.md                        # Full project plan (Phase 0–11)
│   ├── PLAN_MILESTONE_2.md            # Current: Flutter UI-only milestone
│   ├── DUMMY_PRODUCT_MAPPING_PLAN.md  # 125-product catalog & image mappings
│   ├── AI_RULES.md                    # MANDATORY coding conventions
│   └── skills/                        # Skill files for specific domains
│       ├── flutter-ui/SKILL.md        # Flutter screen building patterns
│       ├── database/SKILL.md          # Prisma schema, migrations, seeding
│       ├── api/SKILL.md               # Express endpoint patterns
│       ├── payment/SKILL.md           # BCA VA payment integration
│       ├── testing/SKILL.md           # Testing strategies & patterns
│       └── sdd/SKILL.md              # Spec-driven development workflow
├── docs/specs/                        # SDD spec files (one per user story)
│   ├── SPEC_TEMPLATE.md               # Template for new specs
│   ├── oma-3-ui-navigation.md         # Epic-level spec: OMA-3
│   └── oma-3-3-product-catalog.md     # Sub-task spec example
├── ui-otomasiku-marketplace/          # HTML mockups (visual reference only)
│   ├── home.html, login.html, ...     # 13 screens — pixel-match these in Flutter
└── otomasiku-mobile-app/              # Flutter app (scaffolded in Phase M2-0)
```

---

## Current Status

| Milestone | Phase | Status |
|-----------|-------|--------|
| M2 — Flutter UI (Dummy Data) | M2-0: Project Setup | ⬜ Not started |
| M2 — Flutter UI (Dummy Data) | M2-1 to M2-9: Screens | ⬜ Pending |
| Full Project | Phase 0–6: Customer features | ⬜ Pending |
| Full Project | Phase 7: Admin Dashboard | ⬜ Pending |
| Full Project | Phase 8–11: QA & Release | ⬜ Pending |

**Next action:** Start `PLAN_MILESTONE_2.md` Phase M2-0 (Bootstrap)

---

## Development Commands

### Flutter
```bash
cd otomasiku-mobile-app
flutter run                    # Run on device/emulator
flutter build appbundle        # Production build
flutter test                   # Run tests
flutter analyze                # Static analysis
```

### Express API (Phase 0+)
```bash
cd otomasiku-api
npm run dev                    # Development server
npm run build                  # Production build
npx prisma studio              # Database GUI
npx prisma migrate dev         # Run migrations
npx prisma db seed             # Seed 125 products
```

---

## Troubleshooting

### Flutter Dependencies Not Resolving
If you see `SDK version solving failed` errors:
```bash
# Use full path to upgraded Flutter
"/c/Users/peter/flutter/bin/flutter" pub get
```

### Gradle Java Home Invalid
If Gradle fails with `org.gradle.java.home is invalid`:
1. Check actual JDK location: `dir "C:\Program Files\Java"`
2. Update `android/gradle.properties`:
   ```properties
   org.gradle.java.home=C:/Program Files/Java/jdk-21.0.10
   ```

### Glass Input Fields Show as White Boxes
Ensure the `_buildGlassInput` method has:
- `style: TextStyle(color: Colors.white)` — not `Colors.black87`
- `fillColor: Colors.transparent` and `filled: true` — prevents theme override
- `Scaffold(backgroundColor: Colors.black)` — prevents white background

### Dummy Login Credentials (Milestone 2)
- **Email:** `johndoe@gmail.com`
- **Password:** Any password (dummy login always succeeds)

---

## Critical Rules Summary

> Full rules in `docs/AI_RULES.md` — these are **mandatory**.

### 🚫 Never
- Use `float`/`double` for money — use `BigInt` (Prisma) / `int` (Dart) in Rupiah
- Store `SUPABASE_SERVICE_ROLE_KEY` or BCA credentials in client code
- Bypass `prisma.$transaction` for order creation
- Use `SharedPreferences` for auth tokens — use `flutter_secure_storage`
- Use `any` (TS) or `dynamic` (Dart)
- Use placeholder image URLs (`placehold.co`) — use real assets from `assets/images/products/`

### ✅ Always
- Format money: `CurrencyFormatter.format(price)` → `"Rp 19.800.000"`
- State management: Riverpod (`FutureProvider`, `StateNotifierProvider`)
- Navigation: GoRouter with named routes
- Validate endpoints: Zod schema on every POST/PUT/PATCH
- Handle all 3 states: loading, error, data (`.when()`)
- Product images: `Image.asset()` with `errorBuilder` fallback

### 🎨 UI / Brand
- Primary color: Mitsubishi Red `#E7192D`
- Font: Inter (via `google_fonts`)
- Background: `#F9FAFB`
- Bottom nav: 5 tabs — Beranda, Cari, Proyek, Keranjang, Profil
- Language: Bahasa Indonesia — all user-facing text

### 📁 Naming
- **Dart:** `snake_case.dart` files, `PascalCase` classes, `camelCase` variables
- **TypeScript:** `kebab-case.ts` files, `SCREAMING_SNAKE_CASE` constants
- **Prisma:** `snake_case` plural tables, `PascalCase` models
- **Assets:** `assets/images/products/{brand}/{category}/{filename}.{ext}`

---

## Approved Dependencies

### Flutter (M2 — UI-only phase)
`flutter_riverpod`, `go_router`, `flutter_form_builder`, `intl`, `google_fonts`, `flutter_svg`, `font_awesome_flutter`

> Do NOT add `dio`, `retrofit`, `supabase_flutter`, `flutter_secure_storage` until backend integration.

### Flutter (Full project — Phase 0+)
Add: `dio`, `retrofit`, `supabase_flutter`, `flutter_secure_storage`, `cached_network_image`, `json_serializable`, `firebase_crashlytics`

### Express
`express`, `@prisma/client`, `zod`, `@supabase/supabase-js`, `pino`, `multer`, `cors`, `express-rate-limit`, `helmet`, `axios`, `nodemailer`, `node-cron`, `json2csv`

> No additional packages without CTO approval. Every dependency is a liability.

---

## Product Catalog (125 items)

| Category | Brand | Count | ID Range |
|----------|-------|-------|----------|
| Inverter | Mitsubishi | 33 | `MIT-INV-001` – `033` |
| PLC | Mitsubishi | 32 | `MIT-PLC-001` – `032` |
| HMI | Mitsubishi | 11 | `MIT-HMI-001` – `011` |
| Servo | Mitsubishi | 20 | `MIT-SRV-001` – `020` |
| Inverter | Danfoss | 29 | `DAN-INV-001` – `029` |

Full mapping: `docs/DUMMY_PRODUCT_MAPPING_PLAN.md`

---

## Security Requirements

1. Every Express endpoint: `requireAuth` by default
2. Admin endpoints: `requireAuth` + `requireAdmin`
3. Ownership check: `WHERE user_id = req.user.id` on all data access
4. Monetary transactions: `prisma.$transaction` (atomic)
5. File uploads: validate MIME (JPEG/PNG), size (≤5MB), ownership
6. BCA callback: validate HMAC-SHA256 signature — no JWT (public endpoint)
7. CORS: restrict to app domains only
8. Rate limiting: order creation, BCA callback, login

---

## Spec-Driven Development (SDD) Workflow

> Full process: `docs/skills/sdd/SKILL.md` · Template: `docs/specs/SPEC_TEMPLATE.md`

**Every user story MUST have an approved spec before any code is written.**

### Per-Story Workflow

```
1. READ spec → docs/specs/{jira-id}-{description}.md
2. VERIFY status is "✅ Approved"
3. IMPLEMENT exactly what File Changes section lists
4. VERIFY against Acceptance Criteria (Given/When/Then)
5. RUN Verification Checklist — all items must pass
6. UPDATE spec status to "✅ Done"
```

### When to Write Specs

| JIRA Level | Spec? | Example |
|------------|-------|---------|
| Epic | ✅ Overview spec (lists sub-tasks) | `oma-3-ui-navigation.md` |
| Task / Sub-task | ✅ Full detailed spec | `oma-3-3-product-catalog.md` |
| Bug / Hotfix | ❌ No spec needed | — |

### Key Rules

- **Spec = contract.** The `File Changes` section defines exactly which files to create/modify.
- **Acceptance Criteria = test plan.** Each `Given/When/Then` block is a verifiable test case.
- **Code is source of truth.** If implementation reveals the spec is wrong, update the spec AND the code.
- **No gold-plating.** Implement only what the spec says. Anything else goes in `Out of Scope`.

---

## Reference Documents

| Document | Purpose |
|----------|---------|
| `docs/PRD.md` | Product requirements, user stories, acceptance criteria |
| `docs/ARCHITECTURE.md` | Tech stack, DB schema, API design, folder structure |
| `docs/PLAN.md` | Full project plan (Phase 0–11) with entry/exit criteria |
| `docs/PLAN_MILESTONE_2.md` | **Current milestone** — Flutter UI with 125 dummy products |
| `docs/DUMMY_PRODUCT_MAPPING_PLAN.md` | 125-product catalog, image file mappings, copy script |
| `docs/AI_RULES.md` | **MANDATORY** — coding conventions, security rules, patterns |
| `docs/specs/*.md` | **SDD specs** — one per user story, read before implementing |
| `docs/specs/SPEC_TEMPLATE.md` | Template for creating new story specs |
| `ui-otomasiku-marketplace/*.html` | 13 HTML mockups — pixel-match reference for Flutter screens |

<!-- rtk-instructions v2 -->
# RTK (Rust Token Killer) - Token-Optimized Commands

## Golden Rule

**Always prefix commands with `./rtk.exe`** (Windows) or `rtk` (Unix). If RTK has a dedicated filter, it uses it. If not, it passes through unchanged. This means RTK is always safe to use.

**Important**: Even in command chains with `&&`, use `./rtk.exe`:
```bash
# ❌ Wrong
git add . && git commit -m "msg" && git push

# ✅ Correct (Windows)
./rtk.exe git add . && ./rtk.exe git commit -m "msg" && ./rtk.exe git push

# ✅ Correct (Unix/macOS)
rtk git add . && rtk git commit -m "msg" && rtk git push
```

**Note for Windows users**: RTK is installed as `rtk.exe` in your project root, so use `./rtk.exe <command>` instead of raw `rtk <command>`.

## RTK Commands by Workflow

### Build & Compile (80-90% savings)
```bash
./rtk.exe cargo build         # Cargo build output
./rtk.exe cargo check         # Cargo check output
./rtk.exe cargo clippy        # Clippy warnings grouped by file (80%)
./rtk.exe tsc                 # TypeScript errors grouped by file/code (83%)
./rtk.exe lint                # ESLint/Biome violations grouped (84%)
./rtk.exe prettier --check    # Files needing format only (70%)
./rtk.exe next build          # Next.js build with route metrics (87%)
```

### Test (90-99% savings)
```bash
./rtk.exe cargo test          # Cargo test failures only (90%)
./rtk.exe vitest run          # Vitest failures only (99.5%)
./rtk.exe playwright test     # Playwright failures only (94%)
./rtk.exe test <cmd>          # Generic test wrapper - failures only
```

### Git (59-80% savings)
```bash
./rtk.exe git status          # Compact status
./rtk.exe git log             # Compact log (works with all git flags)
./rtk.exe git diff            # Compact diff (80%)
./rtk.exe git show            # Compact show (80%)
./rtk.exe git add             # Ultra-compact confirmations (59%)
./rtk.exe git commit          # Ultra-compact confirmations (59%)
./rtk.exe git push            # Ultra-compact confirmations
./rtk.exe git pull            # Ultra-compact confirmations
./rtk.exe git branch          # Compact branch list
./rtk.exe git fetch           # Compact fetch
./rtk.exe git stash           # Compact stash
./rtk.exe git worktree        # Compact worktree
```

Note: Git passthrough works for ALL subcommands, even those not explicitly listed.

### GitHub (26-87% savings)
```bash
./rtk.exe gh pr view <num>    # Compact PR view (87%)
./rtk.exe gh pr checks        # Compact PR checks (79%)
./rtk.exe gh run list         # Compact workflow runs (82%)
./rtk.exe gh issue list       # Compact issue list (80%)
./rtk.exe gh api              # Compact API responses (26%)
```

### JavaScript/TypeScript Tooling (70-90% savings)
```bash
./rtk.exe pnpm list           # Compact dependency tree (70%)
./rtk.exe pnpm outdated       # Compact outdated packages (80%)
./rtk.exe pnpm install        # Compact install output (90%)
./rtk.exe npm run <script>    # Compact npm script output
./rtk.exe npx <cmd>           # Compact npx command output
./rtk.exe prisma              # Prisma without ASCII art (88%)
```

### Files & Search (60-75% savings)
```bash
./rtk.exe ls <path>           # Tree format, compact (65%)
./rtk.exe read <file>         # Code reading with filtering (60%)
./rtk.exe grep <pattern>      # Search grouped by file (75%)
./rtk.exe find <pattern>      # Find grouped by directory (70%)
```

### Analysis & Debug (70-90% savings)
```bash
./rtk.exe err <cmd>           # Filter errors only from any command
./rtk.exe log <file>          # Deduplicated logs with counts
./rtk.exe json <file>         # JSON structure without values
./rtk.exe deps                # Dependency overview
./rtk.exe env                 # Environment variables compact
./rtk.exe summary <cmd>       # Smart summary of command output
./rtk.exe diff                # Ultra-compact diffs
```

### Infrastructure (85% savings)
```bash
./rtk.exe docker ps           # Compact container list
./rtk.exe docker images       # Compact image list
./rtk.exe docker logs <c>     # Deduplicated logs
./rtk.exe kubectl get         # Compact resource list
./rtk.exe kubectl logs        # Deduplicated pod logs
```

### Network (65-70% savings)
```bash
./rtk.exe curl <url>          # Compact HTTP responses (70%)
./rtk.exe wget <url>          # Compact download output (65%)
```

### Meta Commands
```bash
./rtk.exe gain                # View token savings statistics
./rtk.exe gain --history      # View command history with savings
./rtk.exe discover            # Analyze Claude Code sessions for missed RTK usage
./rtk.exe proxy <cmd>         # Run command without filtering (for debugging)
./rtk.exe init                # Add RTK instructions to CLAUDE.md
./rtk.exe init --global       # Add RTK to ~/.claude/CLAUDE.md
```

## Token Savings Overview

| Category | Commands | Typical Savings |
|----------|----------|-----------------|
| Tests | vitest, playwright, cargo test | 90-99% |
| Build | next, tsc, lint, prettier | 70-87% |
| Git | status, log, diff, add, commit | 59-80% |
| GitHub | gh pr, gh run, gh issue | 26-87% |
| Package Managers | pnpm, npm, npx | 70-90% |
| Files | ls, read, grep, find | 60-75% |
| Infrastructure | docker, kubectl | 85% |
| Network | curl, wget | 65-70% |

Overall average: **60-90% token reduction** on common development operations.
<!-- /rtk-instructions -->