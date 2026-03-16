# Spec Template — Otomasiku Marketplace
# Copy this file as `docs/specs/{jira-id}-{short-description}.md`

---

## Story: {JIRA-ID} — {Title}

| Field | Value |
|-------|-------|
| **JIRA ID** | {OMA-X / OMA-X sub-task} |
| **Epic** | {Parent epic name} |
| **Sprint** | {Sprint N} |
| **Milestone** | {Milestone N} |
| **Priority** | {High / Medium / Low} |
| **Story Points** | {N} |
| **Status** | ⬜ Draft / 🔄 In Review / ✅ Approved / ✅ Done |

---

## User Story

> **Sebagai** {persona — pelanggan / admin / sistem},
> **Saya ingin** {apa yang dilakukan},
> **Sehingga** {mengapa / value yang didapat}.

---

## Context & References

| Reference | Link |
|-----------|------|
| PRD Module | `docs/PRD.md` § Module {N}: {Name} |
| Architecture | `docs/ARCHITECTURE.md` § {relevant section} |
| HTML Mockup | `ui-otomasiku-marketplace/{file}.html` |
| AI Rules | `docs/AI_RULES.md` § {relevant section} |
| Plan Phase | `docs/PLAN_MILESTONE_2.md` § Phase {M2-N} |
| Parent Spec | `docs/specs/{parent-spec}.md` (if sub-task) |

---

## Functional Requirements

### Behavior Description

{Describe what the feature does in domain language. Use Bahasa Indonesia terms where appropriate (pelanggan, keranjang, pesanan). Be specific about input/output mappings.}

### UI/UX Specification

{Describe the screen layout, components, interactions. Reference the HTML mockup. Include:}

- **Screen layout:** {what the user sees}
- **Interactive elements:** {buttons, inputs, gestures}
- **Navigation:** {where this screen comes from, where it goes}
- **States:** {loading, empty, error, success}

---

## Acceptance Criteria (Given/When/Then)

### AC-1: {Happy path scenario name}
```gherkin
Given {precondition — initial state}
When {action — what the user does}
Then {expected result — what should happen}
And {additional assertions}
```

### AC-2: {Alternative/secondary scenario}
```gherkin
Given {precondition}
When {action}
Then {expected result}
```

### AC-3: {Edge case / error scenario}
```gherkin
Given {precondition}
When {action}
Then {expected result — error handling}
```

{Add more ACs as needed. Cover: happy path, alternative paths, error states, empty states, boundary conditions.}

---

## Technical Design

### Architecture Decisions

- **State management:** {Riverpod provider type — StateProvider / FutureProvider / StateNotifierProvider}
- **Data source:** {dummy data file / Express API endpoint / Supabase SDK}
- **Navigation:** {GoRouter route name and path}

### Data Model

```dart
// Relevant model classes or fields used in this story
// Reference: docs/DUMMY_PRODUCT_MAPPING_PLAN.md § 7 (for Product model)
```

### Component Tree

```
{ScreenWidget}
├── {HeaderWidget}
├── {ContentWidget}
│   ├── {SubWidget1}
│   └── {SubWidget2}
└── {BottomActionBar}
```

### Constraints (from AI_RULES.md)

- {List specific rules that apply to this story}
- {e.g. "CurrencyFormatter for all prices", "Image.asset() for product images"}

---

## File Changes

### New Files
- `lib/features/{feature}/screens/{screen}.dart` — {description}
- `lib/features/{feature}/widgets/{widget}.dart` — {description}

### Modified Files
- `lib/core/router/app_router.dart` — {what changes}
- `lib/providers/{provider}.dart` — {what changes}

### Test Files
- `test/features/{feature}/{test}.dart` — {what is tested}

---

## Out of Scope

- {Explicitly list what this story does NOT cover}
- {Prevents scope creep during implementation}

---

## Verification Checklist

- [ ] All acceptance criteria (Given/When/Then) pass
- [ ] Visual match against HTML mockup ({file}.html)
- [ ] No lint errors (`flutter analyze` clean)
- [ ] No runtime errors on device/emulator
- [ ] Follows AI_RULES.md conventions
- [ ] Prices displayed with `CurrencyFormatter`
- [ ] Product images use `Image.asset()` (not placeholder URLs)
- [ ] Navigation works (forward and back)

---

## Notes

{Any additional context, open questions, or decisions made during spec review.}

> ⚠️ Updated: {reason} — {date} (add this line if spec is modified after approval)
