# Physical Model – Ceramics World

Implementation runs on SQL Server (`CeramicsWorldDB`) using the scripts under `sql/`. Every load cycle drops and recreates the structures to keep the environment reproducible.

## Dimensions
```sql
CREATE TABLE dbo.DIM_COUNTRY (
    id_country   INT IDENTITY(1,1) PRIMARY KEY,
    country_name VARCHAR(150) NOT NULL,
    country_code CHAR(3) NOT NULL UNIQUE,
    continent    VARCHAR(50) NULL,
    region       VARCHAR(100) NULL,
    country_slug VARCHAR(150) NULL
);

CREATE TABLE dbo.DIM_PRODUCT (
    id_product    INT IDENTITY(1,1) PRIMARY KEY,
    code          VARCHAR(20) NOT NULL UNIQUE,
    product_label VARCHAR(255) NULL,
    hs_section    VARCHAR(50) NULL,
    hs_chapter    VARCHAR(10) NULL
);

CREATE TABLE dbo.DIM_DATE (
    id_date   INT IDENTITY(1,1) PRIMARY KEY,
    [year]    INT NOT NULL,
    [quarter] CHAR(2) NOT NULL,
    decade    VARCHAR(10) NOT NULL,
    CONSTRAINT UQ_DIM_DATE UNIQUE ([year], [quarter])
);
```

## Fact tables
- Surrogate keys (`id_country`, `id_product`, `id_date`) with explicit foreign keys.
- Monetary values use `DECIMAL(18,2)`; percentages use `DECIMAL(18,4)`.
- All fact tables are created in `sql/30_facts.sql` after the script drops previous versions.
- `FACT_EXP_SECTOR_BY_PT` and `FACT_IMP_SECTOR` only carry `id_date` because they represent single Portuguese/world quarterly lines mapped through `DIM_DATE`.

Example (`FACT_IMP_PROD`):
```sql
CREATE TABLE dbo.FACT_IMP_PROD (
    id_imp_prod INT IDENTITY(1,1) PRIMARY KEY,
    id_product  INT NOT NULL REFERENCES dbo.DIM_PRODUCT(id_product),
    id_date     INT NOT NULL REFERENCES dbo.DIM_DATE(id_date),
    value       DECIMAL(18,2) NULL
);
```

## Calculation tables
They share a consistent layout, where the primary key is the related dimension. Example:
```sql
CREATE TABLE dbo.CALC_IMP_PT_2024 (
    id_country INT PRIMARY KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd             DECIMAL(18,2),
    trade_balance_2024_usd     DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_imports_pct    DECIMAL(18,4),
    avg_distance_km            DECIMAL(18,2),
    concentration_index        DECIMAL(18,4),
    avg_tariff_pct             DECIMAL(18,4)
);
```

## Technical notes
1. **Percentage conversion** happens in the staging views (`value * 0.01`) so all KPIs share the same decimal representation.
2. **Q4 as yearly proxy**: annual series are stored with `quarter = 'Q4'`, simplifying joins with the date dimension.
3. **Idempotent snapshots**: every `CALC_*` table is recreated on each run of `sql/30_facts.sql`, keeping snapshots aligned with staging data.
4. **Referential integrity**: all foreign keys use `ON DELETE NO ACTION`; the scripts drop dependent tables explicitly before recreating the dimensions.
5. **Staging table naming**: `etl/ingest_csv.py` generates deterministic, SQL-safe table names (e.g., `imports_products_csv_trade_map_list_of_imported_products_for_the_selected_product_ceramic_products_xls`) to maintain traceability back to the CSV file.
