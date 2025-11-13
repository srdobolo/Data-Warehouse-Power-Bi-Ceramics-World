# Logical Model – Ceramics World

The logical view describes grain, cardinality, and business rules before physical implementation. All technical keys are integers and monetary values use `DECIMAL(18,2)` (USD); percentages are stored as `DECIMAL(18,4)` after converting to decimal form during the ETL.

## Dimensions
| Table | Description | Key fields |
| --- | --- | --- |
| `DIM_COUNTRY` | Single source of countries with ISO3, continent, region, slug. | `id_country` (PK), `country_name`, `country_code`, `continent`, `region`, `country_slug` |
| `DIM_PRODUCT` | HS 4-digit codes from the ceramic portfolio. | `id_product` (PK), `code`, `product_label`, `hs_section`, `hs_chapter` |
| `DIM_DATE` | Annual/trimestral calendar with decade label (e.g., “2010s”). | `id_date` (PK), `year`, `quarter`, `decade` |

## Fact tables
| Table | Grain | Metrics |
| --- | --- | --- |
| `FACT_EXP_PT` | (`id_country`, `id_date`) | `value` |
| `FACT_EXP` | (`id_country`, `id_date`) | `value` |
| `FACT_EXP_PROD_BY_PT` | (`id_product`, `id_date`) | `value` |
| `FACT_EXP_SECTOR_BY_PT` | (`id_date` – Portuguese quarterly line) | `value` |
| `FACT_IMP` | (`id_country`, `id_date`) | `value` |
| `FACT_IMP_PT` | (`id_country`, `id_date`) | `value` |
| `FACT_IMP_PROD` | (`id_product`, `id_date`) | `value` |
| `FACT_IMP_SEGMENT` | (`id_product`, `id_country`, `id_date`) | `value` |
| `FACT_IMP_SECTOR` | (`id_date` – world quarterly line) | `value` |
| `FACT_PIB` | (`id_country`, `id_date`) | `gdp_per_capita_usd` |
| `FACT_URBAN` | (`id_country`, `id_date`) | `urban_population_total` |
| `FACT_CONSTRUCTION` | (`id_country`, `id_date`) | `value_added_growth_pct` |

Common rules:
1. Every fact table references `DIM_DATE` (snapshots excluded).
2. Countries/products are cleansed in staging; only valid surrogate keys enter the DW.
3. Quarterly services data store four records per year yet only reference `DIM_DATE`, because they represent single Portuguese (exports) and world (imports) lines.

## Calculation tables (2024 snapshot)
| Table | Grain | Key metrics |
| --- | --- | --- |
| `CALC_EXP_PT_2024` | `id_country` | `value_2024_usd`, `trade_balance_2024_usd`, `share_portugal_exports_pct`, `growth_value_*`, `ranking_world_imports`, `share_world_imports_pct`, `partner_growth_2020_2024_pct`, `avg_distance_km`, `concentration_index`, `avg_tariff_pct`. |
| `CALC_EXP_2024`, `CALC_EXP_WORLD`, `CALC_ALL_EXP_2024` | `id_country` | Same structure (different data sources). |
| `CALC_IMP_2024`, `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024` | `id_country` | Import KPIs, including tariff averages when available. |
| `CALC_EXP_PROD_BY_PT`, `CALC_IMP_PROD_BY_PT` | `id_product` | Growth, share, ranking, distance, and concentration metrics by HS code. |

## Cardinalities
- `DIM_COUNTRY` 1:N all country-based facts and calc tables.
- `DIM_PRODUCT` 1:N product-based facts/calc tables.
- `DIM_DATE` 1:N all temporal facts.

## Business rules
1. Percentages are multiplied by 0.01 at the staging layer to keep consistent decimal storage.
2. `DIM_DATE` is populated with every year present in the staging views, so new sources only append years.
3. Snapshot tables are rebuilt on every run of `sql/30_facts.sql`, ensuring alignment with staging views.
4. The ETL harmonises country names and HS codes before loading dimensions to avoid duplicates.
