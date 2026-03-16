# 📦 Dummy Product Mapping Plan (10 Products)
# Otomasiku Marketplace — Milestone 2

> **Purpose:** Define the 10 dummy products for Flutter UI development in Milestone 2. These products are referenced in the HTML mockups (`ui-otomasiku-marketplace/`) plus additional products to ensure category diversity.
>
> **Source of Truth:**
> - Product images → `docs/dummy-products/` (10 images, 1 per product)
> - Original images sourced from `C:\Users\Peter\Downloads\ALL_FOTO_PRODUK_OTOMASIKU\`
> - HTML mockups → `ui-otomasiku-marketplace/*.html`
> - **Feature Inventory:** See `PLAN_MILESTONE_2.md` § "HTML Mockup Feature Inventory" for complete feature breakdown of all 18 screens
> - **Architecture:** See `ARCHITECTURE.md` for hybrid Supabase + Express.js design
> - **Coding Rules:** See `AI_RULES.md` for i18n, monetary, and security patterns
>
> **HTML Product Display Status:**
> - ✅ All 10 products displayed across HTML mockups
> - ✅ Product images applied to all product cards
> - ✅ Fallback pattern implemented (`<img>` with `onerror` → FontAwesome icon)

---

## 📊 1. Product Selection Summary

### Selection Criteria
1. **HTML-referenced products (5)** — Products explicitly referenced in `home.html`, `product-detail.html`, `search-results.html`, `checkout.html`, `compare.html`
2. **Category diversity (5 additional)** — Ensure representation across Inverter, PLC, HMI, Servo, and Danfoss brands

### Final 10 Products

| # | Product ID | Name | Category | Brand | Price (Rp) | Image File | Source |
|---|-----------|------|----------|-------|------------|------------|--------|
| 1 | `MIT-INV-001` | FR-A820-0.4K-1 | Inverter | Mitsubishi | 5.200.000 | `01-fr-a820-0.4k.jpg` | HTML (home, product-detail, search, checkout, order-detail, compare) |
| 2 | `MIT-INV-002` | FR-A820-2.2K-1 | Inverter | Mitsubishi | 12.500.000 | `02-fr-a820-2.2k.jpg` | HTML (search-results, compare) |
| 3 | `MIT-PLC-001` | FX5U-32MT/ES | PLC | Mitsubishi | 8.800.000 | `03-fx5u-32mt-es.jpg` | HTML (home as FX5U-32MT/ESS, checkout) |
| 4 | `MIT-SRV-001` | MR-J4-10B | Servo | Mitsubishi | 6.800.000 | `04-mr-j4-10b.jpg` | HTML (home) |
| 5 | `DAN-INV-001` | FC 302 131B0078 | Inverter | Danfoss | 12.500.000 | `05-fc-302-1.5kw.jpg` | HTML (home as FC-302P1K5) |
| 6 | `MIT-INV-003` | FR-D720-0.75K | Inverter | Mitsubishi | 3.200.000 | `06-fr-d720-0.75k.jpg` | Category diversity (FR-D700 series) |
| 7 | `MIT-PLC-002` | FX3G-24MR/ES-A | PLC | Mitsubishi | 5.800.000 | `07-fx3g-24mr-es.jpg` | Category diversity (FX3 series) |
| 8 | `MIT-HMI-001` | GT2103-PMBDS | HMI | Mitsubishi | 6.500.000 | `08-gt2103-pmbds.jpg` | Category diversity (HMI category) |
| 9 | `MIT-SRV-002` | MR-J4-10A | Servo | Mitsubishi | 6.200.000 | `09-mr-j4-10a.jpg` | Category diversity (standalone servo) |
| 10 | `DAN-INV-002` | FC 051 132F0003 | Inverter | Danfoss | 3.200.000 | `10-fc-051-0.75kw.jpg` | Category diversity (entry-level Danfoss) |

---

## 📊 2. Category Distribution

| Category | Count | Products |
|----------|-------|----------|
| Inverter | 5 | FR-A820-0.4K, FR-A820-2.2K, FR-D720-0.75K, FC 302, FC 051 |
| PLC | 2 | FX5U-32MT, FX3G-24MR |
| Servo | 2 | MR-J4-10B, MR-J4-10A |
| HMI | 1 | GT2103-PMBDS |
| **Total** | **10** | |

### Brand Distribution
| Brand | Count | Percentage |
|-------|-------|------------|
| Mitsubishi | 8 | 80% |
| Danfoss | 2 | 20% |

---

## 📁 3. Image Files

All 10 product images are stored in `docs/dummy-products/`:

```
docs/dummy-products/
├── 01-fr-a820-0.4k.jpg       # 134 KB — Mitsubishi FR-A820-0.4K (HTML primary)
├── 02-fr-a820-2.2k.jpg       # 27 KB  — Mitsubishi FR-A820-2.2K (HTML search/compare)
├── 03-fx5u-32mt-es.jpg       # 140 KB — Mitsubishi FX5U-32MT/ES (HTML PLC)
├── 04-mr-j4-10b.png          # 241 KB — Mitsubishi MR-J4-10B (HTML servo)
├── 05-fc-302-1.5kw.jpg       # 340 KB — Danfoss FC 302 1.5kW (HTML Danfoss)
├── 06-fr-d720-0.75k.jpg      # 308 KB — Mitsubishi FR-D720-0.75K (diversity)
├── 07-fx3g-24mr-es.jpg       # 19 KB  — Mitsubishi FX3G-24MR/ES-A (diversity)
├── 08-gt2103-pmbds.jpg       # 9 KB   — Mitsubishi GT2103-PMBDS (HMI)
├── 09-mr-j4-10a.jpg          # 26 KB  — Mitsubishi MR-J4-10A (diversity servo)
└── 10-fc-051-0.75kw.jpg      # 146 KB — Danfoss FC 051 0.75kW (diversity)
```

### Source Image Mapping
| Image File | Original Source Path |
|------------|---------------------|
| `01-fr-a820-0.4k.jpg` | `Inverter/F820-5.5K-1.jpeg` (proxy for 0.4K) |
| `02-fr-a820-2.2k.jpg` | `Inverter/fr-a840-2.2k.jpg` |
| `03-fx5u-32mt-es.jpg` | `PLC/FX5U-32MT ES.jpeg` |
| `04-mr-j4-10b.jpg` | `SERVO/MR-J4-10B.png` |
| `05-fc-302-1.5kw.jpg` | `FC 302/131B0078.jpg` |
| `06-fr-d720-0.75k.jpg` | `Inverter/FR-D720-0.75K 2.jpg` |
| `07-fx3g-24mr-es.jpg` | `PLC/FX3G-24MR ES.jpg` |
| `08-gt2103-pmbds.jpg` | `HMI/GT2103-PMBDS HMI - TOUCH SCREEN MITSUBISHI ELECTRIC.jpg` |
| `09-mr-j4-10a.jpg` | `SERVO/MR-J4-10A.jpg` |
| `10-fc-051-0.75kw.jpg` | `FC 051/132F0003.jpg` |

---

## 📝 4. Product Details (for Dummy Data)

### 1. MIT-INV-001: FR-A820-0.4K-1
- **Category:** Inverter
- **Series:** FR-A800
- **Description:** Mitsubishi Inverter FR-A800 Series, 0.4kW, 200V, 3-phase
- **Price:** Rp 5.200.000
- **Stock:** 24 unit (Ready Stock)
- **Image:** `01-fr-a820-0.4k.jpg`
- **HTML References:** `home.html`, `product-detail.html`, `search-results.html`, `checkout.html`, `order-detail.html`, `compare.html`

### 2. MIT-INV-002: FR-A820-2.2K-1
- **Category:** Inverter
- **Series:** FR-A800
- **Description:** Mitsubishi Inverter FR-A800 Series, 2.2kW, 200V, 3-phase
- **Price:** Rp 12.500.000
- **Stock:** Indent 14 Hari
- **Image:** `02-fr-a820-2.2k.jpg`
- **HTML References:** `search-results.html`, `compare.html`

### 3. MIT-PLC-001: FX5U-32MT/ES
- **Category:** PLC
- **Series:** FX5
- **Description:** Mitsubishi PLC CPU 32 I/O, Transistor Output, 24VDC
- **Price:** Rp 8.800.000
- **Stock:** 8 unit (Ready Stock)
- **Image:** `03-fx5u-32mt-es.jpg`
- **HTML References:** `home.html` (as FX5U-32MT/ESS), `checkout.html`

### 4. MIT-SRV-001: MR-J4-10B
- **Category:** Servo
- **Series:** MR-J4
- **Description:** Mitsubishi Servo Amplifier 100W, SSCNET III/H
- **Price:** Rp 6.800.000
- **Stock:** 3 unit (Low Stock)
- **Image:** `04-mr-j4-10b.jpg`
- **HTML References:** `home.html`

### 5. DAN-INV-001: FC 302 131B0078
- **Category:** Inverter
- **Series:** FC300 (Danfoss)
- **Description:** Danfoss VLT AutomationDrive, 1.5kW, 380-480V
- **Price:** Rp 12.500.000
- **Stock:** 8 unit (Ready Stock)
- **Image:** `05-fc-302-1.5kw.jpg`
- **HTML References:** `home.html` (as FC-302P1K5)

### 6. MIT-INV-003: FR-D720-0.75K
- **Category:** Inverter
- **Series:** FR-D700
- **Description:** Mitsubishi Inverter FR-D700 Series, 0.75kW, 200V, 3-phase
- **Price:** Rp 3.200.000
- **Stock:** 24 unit (Ready Stock)
- **Image:** `06-fr-d720-0.75k.jpg`
- **HTML References:** `home.html`, `search-results.html`

### 7. MIT-PLC-002: FX3G-24MR/ES-A
- **Category:** PLC
- **Series:** FX3
- **Description:** Mitsubishi PLC CPU 24 I/O, Relay Output, 100-240VAC
- **Price:** Rp 5.800.000
- **Stock:** 10 unit (Ready Stock)
- **Image:** `07-fx3g-24mr-es.jpg`
- **HTML References:** `home.html`, `search-results.html`

### 8. MIT-HMI-001: GT2103-PMBDS
- **Category:** HMI
- **Series:** GT2000
- **Description:** Mitsubishi HMI GOT2000, 3.8" TFT, 256 colors
- **Price:** Rp 6.500.000
- **Stock:** 12 unit (Ready Stock)
- **Image:** `08-gt2103-pmbds.jpg`
- **HTML References:** `home.html`, `search-results.html`

### 9. MIT-SRV-002: MR-J4-10A
- **Category:** Servo
- **Series:** MR-J4
- **Description:** Mitsubishi Servo Amplifier 100W, Standalone (non-SSCNET)
- **Price:** Rp 6.200.000
- **Stock:** 10 unit (Ready Stock)
- **Image:** `09-mr-j4-10a.jpg`
- **HTML References:** `home.html`, `search-results.html`

### 10. DAN-INV-002: FC 051 132F0003
- **Category:** Inverter
- **Series:** FC51 (Danfoss)
- **Description:** Danfoss VLT Micro Drive, 0.75kW, 1-phase 200-240V
- **Price:** Rp 3.200.000
- **Stock:** 25 unit (Ready Stock)
- **Image:** `10-fc-051-0.75kw.jpg`
- **HTML References:** `home.html`, `search-results.html`

---

## 🎯 5. Usage Guidelines

### For Flutter UI Development
1. Copy images from `docs/dummy-products/` to `otomasiku-mobile-app/assets/images/products/`
2. Organize by category:
   ```
   assets/images/products/
   ├── inverters/
   │   ├── fr-a820-0.4k.jpg
   │   ├── fr-a820-2.2k.jpg
   │   ├── fr-d720-0.75k.jpg
   │   ├── fc-302-1.5kw.jpg
   │   └── fc-051-0.75kw.jpg
   ├── plc/
   │   ├── fx5u-32mt-es.jpg
   │   └── fx3g-24mr-es.jpg
   ├── servo/
   │   ├── mr-j4-10b.jpg
   │   └── mr-j4-10a.jpg
   └── hmi/
       └── gt2103-pmbds.jpg
   ```

### For HTML Mockup Matching
- The 5 HTML-referenced products should match exactly with `home.html`, `product-detail.html`, `search-results.html`, `checkout.html`, and `compare.html`
- The 5 additional products provide category diversity for testing filters, search, and navigation

---

## 📌 6. Notes

1. **Price Format:** All prices are in Indonesian Rupiah (Rp) — stored as integers (no decimals)
2. **Stock Status:**
   - "Ready Stock" = available immediately
   - "Indent" = requires ordering from supplier (14+ days)
   - "Low Stock" = less than 5 units available
3. **Image Naming:** Numbered prefix (01-, 02-, etc.) ensures consistent ordering
4. **Future Expansion:** This 10-product set can be expanded to the full 125-product catalog when moving beyond Milestone 2

---

## 📊 7. Summary Table (Quick Reference)

| ID | Name | Category | Brand | Price | Stock | Image |
|----|------|----------|-------|-------|-------|-------|
| MIT-INV-001 | FR-A820-0.4K-1 | Inverter | Mitsubishi | 5.2jt | 24 | ✅ |
| MIT-INV-002 | FR-A820-2.2K-1 | Inverter | Mitsubishi | 12.5jt | Indent | ✅ |
| MIT-PLC-001 | FX5U-32MT/ES | PLC | Mitsubishi | 8.8jt | 8 | ✅ |
| MIT-SRV-001 | MR-J4-10B | Servo | Mitsubishi | 6.8jt | 3 | ✅ |
| DAN-INV-001 | FC 302 131B0078 | Inverter | Danfoss | 12.5jt | 8 | ✅ |
| MIT-INV-003 | FR-D720-0.75K | Inverter | Mitsubishi | 3.2jt | 24 | ✅ |
| MIT-PLC-002 | FX3G-24MR/ES-A | PLC | Mitsubishi | 5.8jt | 10 | ✅ |
| MIT-HMI-001 | GT2103-PMBDS | HMI | Mitsubishi | 6.5jt | 12 | ✅ |
| MIT-SRV-002 | MR-J4-10A | Servo | Mitsubishi | 6.2jt | 10 | ✅ |
| DAN-INV-002 | FC 051 132F0003 | Inverter | Danfoss | 3.2jt | 25 | ✅ |

---

*Last updated: 2026-03-12*
*Document version: 2.0 (10 products only)*
