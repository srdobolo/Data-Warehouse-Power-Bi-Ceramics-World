# Data Warehouse & Power BI – Ceramics World

Final project that blends Trade Map and World Bank data to evaluate how Portuguese ceramics compete worldwide. The repository ships a SQL Server data warehouse, a Python ingestion pipeline, and Power BI assets ready for executive storytelling.

---

## Overview
- **Scope**: imports and exports for HS 69xx ceramic products plus macro indicators (GDP per capita, urbanisation, industry growth).
- **Time coverage**: annual series from 2005–2024 (Q4 used as the yearly representative) and 2024 KPI snapshots.
- **Goal**: highlight priority markets, measure Portugal’s share, and connect macro drivers with global demand.

```
Trade Map / World Bank CSVs
          │
          ▼
Python ETL (etl/ingest_csv.py) → Staging Views (sql/10_staging.sql)
          │
          ▼
Dimensions & Facts (sql/20_dimensions.sql + sql/30_facts.sql)
          │
          ▼
Power BI (Power BI/DAX.md + Dashboard.pbix)
```

---

## Data Sources
| Source | Dataset | Warehouse usage |
| --- | --- | --- |
| Trade Map | Exporters 2024 (Ceramic products) | `CALC_EXP_2024`, exporter rankings. |
| Trade Map | Exporters 2024 (All products) | `CALC_EXP_WORLD`, `CALC_ALL_EXP_2024`, `CALC_IMP_2024`. |
| Trade Map | Importers 2024 (Ceramic products) | `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024`. |
| Trade Map | Importers historic (Ceramic products) | `FACT_IMP`. |
| Trade Map | Importers by segment (HS 6907/6908/6910) | `FACT_IMP_SEGMENT`. |
| Trade Map | Construction services (imports/exports) | `FACT_IMP_SECTOR`, `FACT_EXP_SECTOR_BY_PT`. |
| World Bank | GDP per capita (NY.GDP.PCAP.CD) | `FACT_PIB`. |
| World Bank | Urban population (SP.URB.TOTL) | `FACT_URBAN`. |
| World Bank | Industry incl. construction (NV.IND.TOTL.KD.ZG) | `FACT_CONSTRUCTION`. |

---

## Dimensional Model
### Dimensions
`DIM_COUNTRY`, `DIM_PRODUCT`, `DIM_DATE` with surrogate integer keys and normalised attributes (ISO3, HS code, decade, etc.).

### Fact tables
- **Trade**: `FACT_EXP_PT`, `FACT_EXP`, `FACT_IMP`, `FACT_IMP_PT`, `FACT_EXP_PROD_BY_PT`, `FACT_IMP_PROD`, `FACT_IMP_SEGMENT`.
- **Services**: `FACT_EXP_SECTOR_BY_PT`, `FACT_IMP_SECTOR`.
- **Macro**: `FACT_PIB`, `FACT_URBAN`, `FACT_CONSTRUCTION`.

### Calculation tables (2024 snapshots)
`CALC_EXP_PT_2024`, `CALC_EXP_2024`, `CALC_EXP_WORLD`, `CALC_ALL_EXP_2024`, `CALC_IMP_2024`, `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024`, `CALC_EXP_PROD_BY_PT`, `CALC_IMP_PROD_BY_PT`. They store metrics already converted to decimals so Power BI can consume them without extra logic.

Full specs live inside `docs/Modelo_Conceptual.md`, `docs/Modelo_Logico.md`, `docs/Modelo_Fisico.md`, and `docs/Modelo_Relacional.md` (now available in English as well).

---

## Load Pipeline
1. **Configure environment**: update `docker/.env` or local variables (`MSSQL_HOST`, `MSSQL_DB`, `MSSQL_USER`, `MSSQL_PASSWORD`, `DATA_PATH`).
2. **Ingest raw CSVs** with `python etl/ingest_csv.py`. The script scans `data/**.csv`, derives safe table names, and loads staging tables.
3. **Create staging views** via `sql/10_staging.sql` (trimming names, unpivoting, converting percentages, mapping ISO3/HS codes).
4. **Rebuild dimensions** (`sql/20_dimensions.sql`).
5. **Recreate fact & calc tables** (`sql/30_facts.sql`).
6. **Refresh Power BI** so Dashboard.pbix points to `CeramicsWorldDB`.

---

## Dashboards & Analytics
- `Power BI/DAX.md` holds reusable measures (shares, rankings, clustering, outlier detection).
- `Power BI/Dashboard.pbix` showcases:
  - Import vs. export growth by country.
  - Segment analysis for HS 6907/6908/6910.
  - Correlations between GDP/urbanisation and ceramic demand.

---

## Repository Layout
```
data/            # Source CSVs (Trade Map, World Bank)
docker/          # Environment variables / compose
Docs/            # Conceptual, logical, physical, relational models
etl/             # Python ingestion (pandas + SQLAlchemy)
img/             # Report visuals
Power BI/        # DAX measures + Dashboard.pbix
powerbi/         # Exploratory Python (PCA, clustering, etc.)
sql/             # 10_staging, 20_dimensions, 30_facts scripts
```

---

## How to Reproduce
1. `pip install -r etl/requirements.txt`
2. Provide credentials in `.env`.
3. Run `python etl/ingest_csv.py`.
4. Execute `sqlcmd -d CeramicsWorldDB -i sql/10_staging.sql`, then `20_dimensions.sql` and `30_facts.sql`.
5. Open Power BI, refresh connections, publish.

---

## License
Educational project released under the MIT License.
