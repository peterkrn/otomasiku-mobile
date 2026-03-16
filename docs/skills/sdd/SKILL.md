# Skill: Spec-Driven Development Workflow
# Otomasiku Marketplace Mobile App

> **When to use:** ALWAYS. Every user story from JIRA must go through this SDD workflow before any code is written.

---

## What Is Spec-Driven Development (SDD)?

SDD separates the **planning/design phase** from the **implementation phase**. For each user story:

1. **Spec Phase** (human-in-the-loop) — Analyze requirements → write a structured spec → review & approve
2. **Implement Phase** (AI-assisted) — Generate code from the approved spec → verify against acceptance criteria
3. **Verify Phase** — Run tests/checks defined in the spec → confirm all acceptance criteria pass

The spec is **not disposable** — it lives alongside code as a living document. But **code remains the source of truth** for behavior. Specs drive code generation and serve as documentation.

---

## Workflow: Per User Story

```
JIRA Task (e.g. OMA-3: Halaman Katalog Produk)
  │
  ├─ 1. CREATE SPEC ──→ docs/specs/{story-id}.md
  │     • Analyze JIRA task + PRD module + HTML mockup
  │     • Write structured spec using SPEC_TEMPLATE.md
  │     • Human reviews & approves (or iterates)
  │
  ├─ 2. IMPLEMENT ──→ Generate code from approved spec
  │     • Follow spec's Technical Design section
  │     • Follow spec's File Changes section (exact files to create/modify)
  │     • Follow AI_RULES.md for all code conventions
  │     • Commit with message: "feat(OMA-X): <description>"
  │
  └─ 3. VERIFY ──→ Run spec's Acceptance Criteria
        • Check every Given/When/Then scenario
        • Run tests defined in spec
        • Visual QA against HTML mockup (if applicable)
        • Mark spec status: ✅ DONE
```

---

## Spec File Naming

```
docs/specs/
├── SPEC_TEMPLATE.md              # Template for all specs
├── oma-1-project-setup.md        # OMA-1: Project Setup & Architecture
├── oma-3-product-catalog.md      # OMA-3: Halaman Katalog Produk
├── oma-3-1-grid-layout.md        # OMA-3 sub-task: Layout grid & list produk
├── oma-3-2-search-filter.md      # OMA-3 sub-task: Fitur search & filter
└── ...
```

**Convention:** `{jira-id-lowercase}-{short-description}.md`

- Epic-level specs: `oma-{N}-{description}.md`
- Sub-task specs: `oma-{N}-{sub}-{description}.md`
- Use kebab-case, lowercase

---

## When to Write a Spec

| JIRA Item | Write Spec? | Granularity |
|-----------|-------------|-------------|
| Epic (e.g. OMA-3) | ✅ Yes — one overview spec | High-level: lists all sub-tasks, overall architecture |
| Task (e.g. "Halaman Katalog Produk") | ✅ Yes — if it has sub-tasks, spec covers the task | Medium: defines screens, data flow, files |
| Sub-task (e.g. "Layout grid produk") | ✅ Yes — if it's independently implementable | Low: exact widget, exact file, exact behavior |
| Presentation milestone | ❌ No spec needed | — |

**Rule of thumb:** If a JIRA item results in code changes, it gets a spec.

---

## Spec Quality Checklist

Before approving a spec:

- [ ] **Uses domain language** — "pelanggan", "keranjang", "pesanan" — not generic terms
- [ ] **Has Given/When/Then** — at least 3 acceptance criteria in BDD format
- [ ] **Defines exact files** — which files to create, which to modify
- [ ] **References mockup** — links to the HTML file in `ui-otomasiku-marketplace/`
- [ ] **References docs** — links to PRD module, ARCHITECTURE section, AI_RULES section, PLAN_MILESTONE_2 phase
- [ ] **Covers edge cases** — empty states, error states, boundary conditions
- [ ] **Is concise** — no bloat, covers critical path without enumerating everything
- [ ] **Is deterministic** — another developer reading this spec would build the same thing
- [ ] **Aligns with Milestone 2 scope** — dummy data + BCA Sandbox only (not full backend)

---

## Spec-to-Code Mapping

The spec's `## File Changes` section is the contract:

```markdown
## File Changes

### New Files
- `lib/features/home/screens/home_screen.dart` — Home screen with product grid
- `lib/features/home/widgets/product_card.dart` — Reusable product card widget

### Modified Files
- `lib/core/router/app_router.dart` — Add `/home` route
- `lib/providers/product_provider.dart` — Add `filteredProductsProvider`

### Test Files
- `test/features/home/home_screen_test.dart` — Widget tests for home screen
```

When implementing, follow this section exactly. Don't create files not listed. Don't skip listed files.

---

## Iteration & Spec Drift

- If during implementation you discover the spec is wrong or incomplete → **update the spec first**, then continue coding
- Never write code that contradicts the spec without updating it
- Specs are versioned with git alongside code
- Mark spec changes with `> ⚠️ Updated: [reason] — [date]` at the top

---

## Integration with CLAUDE.md

When starting work on a JIRA story:

1. **Read** the JIRA task (from CSV or board)
2. **Read** the relevant PRD module (`docs/PRD.md`)
3. **Read** the HTML mockup (`ui-otomasiku-marketplace/*.html`)
4. **Create** the spec (`docs/specs/{story-id}.md`) using the template
5. **Review** the spec with the user (present it, ask for approval)
6. **Implement** once approved
7. **Verify** against spec's acceptance criteria
8. **Update** spec status to ✅ DONE
