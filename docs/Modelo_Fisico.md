# Modelo Físico – Data Warehouse Ceramics World

- **SGBD**: SQL Server  
- **Codificação**: UTF-8  
- **Tipos**: `INT` para chaves, `DECIMAL(18,2)` para valores em USD, `DECIMAL(18,4)` para percentagens/índices  
- **Naming**: `DIM_*`, `FACT_*`, `CALC_*`  
- **Integridade**: PK em todas as tabelas, FK para dimensões onde aplicável.

## Dimensões

```sql
CREATE TABLE DIM_COUNTRY (
    id_country   INT IDENTITY(1,1) PRIMARY KEY,
    country_name VARCHAR(150) NOT NULL UNIQUE,
    country_code CHAR(3)      NOT NULL UNIQUE
);

CREATE TABLE DIM_PRODUCT (
    id_product   INT IDENTITY(1,1) PRIMARY KEY,
    code         VARCHAR(20)  NOT NULL UNIQUE,
    product_label VARCHAR(255)
);

CREATE TABLE DIM_DATE (
    id_date  INT IDENTITY(1,1) PRIMARY KEY,
    [year]   INT NOT NULL,
    [quarter] CHAR(2) NOT NULL,
    decade   VARCHAR(10) NOT NULL,
    CONSTRAINT UQ_DIM_DATE UNIQUE ([year], [quarter])
);
```

## Fact tables

```sql
CREATE TABLE FACT_EXP_PT (
    id_exp_pt  INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL REFERENCES DIM_COUNTRY(id_country),
    id_date    INT NOT NULL REFERENCES DIM_DATE(id_date),
    value      DECIMAL(18,2)
);

CREATE TABLE FACT_EXP (
    id_exp     INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL REFERENCES DIM_COUNTRY(id_country),
    id_date    INT NOT NULL REFERENCES DIM_DATE(id_date),
    value      DECIMAL(18,2)
);

CREATE TABLE FACT_EXP_PROD_BY_PT (
    id_exp_prod_pt INT IDENTITY(1,1) PRIMARY KEY,
    id_product     INT NOT NULL REFERENCES DIM_PRODUCT(id_product),
    id_date        INT NOT NULL REFERENCES DIM_DATE(id_date),
    value          DECIMAL(18,2)
);

CREATE TABLE FACT_EXP_SECTOR_BY_PT (
    id_exp_sector INT IDENTITY(1,1) PRIMARY KEY,
    id_date       INT NOT NULL REFERENCES DIM_DATE(id_date),
    value         DECIMAL(18,2)
);

CREATE TABLE FACT_IMP_PT (
    id_imp_pt  INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL REFERENCES DIM_COUNTRY(id_country),
    id_date    INT NOT NULL REFERENCES DIM_DATE(id_date),
    value      DECIMAL(18,2)
);

CREATE TABLE FACT_IMP_PROD_BY_PT (
    id_imp_prod_pt INT IDENTITY(1,1) PRIMARY KEY,
    id_product     INT NOT NULL REFERENCES DIM_PRODUCT(id_product),
    id_date        INT NOT NULL REFERENCES DIM_DATE(id_date),
    value          DECIMAL(18,2)
);

CREATE TABLE FACT_IMP_SECTOR (
    id_imp_sector INT IDENTITY(1,1) PRIMARY KEY,
    id_date       INT NOT NULL REFERENCES DIM_DATE(id_date),
    value         DECIMAL(18,2)
);
```

## Tabelas de KPIs (snapshot 2024)

```sql
CREATE TABLE CALC_EXP_PT_2024 (
    id_country INT PRIMARY KEY REFERENCES DIM_COUNTRY(id_country),
    value_2024_usd              DECIMAL(18,2),
    trade_balance_2024_usd      DECIMAL(18,2),
    share_portugal_exports_pct  DECIMAL(18,4),
    growth_value_2020_2024_pct  DECIMAL(18,4),
    growth_value_2023_2024_pct  DECIMAL(18,4),
    ranking_world_imports       INT,
    share_world_imports_pct     DECIMAL(18,4),
    partner_growth_2020_2024_pct DECIMAL(18,4),
    avg_distance_km             DECIMAL(18,2),
    concentration_index         DECIMAL(18,4),
    avg_tariff_pct              DECIMAL(18,4)
);

CREATE TABLE CALC_EXP_2024 (
    id_country INT PRIMARY KEY REFERENCES DIM_COUNTRY(id_country),
    value_2024_usd             DECIMAL(18,2),
    trade_balance_2024_usd     DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_exports_pct    DECIMAL(18,4),
    avg_distance_km            DECIMAL(18,2),
    concentration_index        DECIMAL(18,4)
);

CREATE TABLE CALC_EXP_PROD_BY_PT (
    id_product INT PRIMARY KEY REFERENCES DIM_PRODUCT(id_product),
    value_2024_usd                  DECIMAL(18,2),
    trade_balance_2024_usd          DECIMAL(18,2),
    growth_value_2020_2024_pct      DECIMAL(18,4),
    growth_quantity_2020_2024_pct   DECIMAL(18,4),
    growth_value_2023_2024_pct      DECIMAL(18,4),
    world_import_growth_2020_2024_pct DECIMAL(18,4),
    share_world_exports_pct         DECIMAL(18,4),
    ranking_world_exports           INT,
    avg_distance_km                 DECIMAL(18,2),
    concentration_index             DECIMAL(18,4)
);

CREATE TABLE CALC_IMP_PT_2024 (
    id_country INT PRIMARY KEY REFERENCES DIM_COUNTRY(id_country),
    value_2024_usd             DECIMAL(18,2),
    trade_balance_2024_usd     DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_imports_pct    DECIMAL(18,4),
    avg_distance_km            DECIMAL(18,2),
    concentration_index        DECIMAL(18,4),
    avg_tariff_pct             DECIMAL(18,4)
);

CREATE TABLE CALC_IMP_PROD_BY_PT (
    id_product INT PRIMARY KEY REFERENCES DIM_PRODUCT(id_product),
    value_2024_usd                 DECIMAL(18,2),
    trade_balance_2024_usd         DECIMAL(18,2),
    growth_value_2020_2024_pct     DECIMAL(18,4),
    growth_quantity_2020_2024_pct  DECIMAL(18,4),
    growth_value_2023_2024_pct     DECIMAL(18,4),
    world_export_growth_2020_2024_pct DECIMAL(18,4),
    avg_distance_km                DECIMAL(18,2),
    concentration_index            DECIMAL(18,4)
);
```

## Resumo Estrutural

| Tipo  | Tabela                    | Chaves/FKs principais                                               |
| ----- | ------------------------- | ------------------------------------------------------------------- |
| Dim   | `DIM_COUNTRY`             | PK `id_country`                                                     |
| Dim   | `DIM_PRODUCT`             | PK `id_product`                                                     |
| Dim   | `DIM_DATE`                | PK `id_date`, UNIQUE (`year`,`quarter`)                             |
| Fato  | `FACT_EXP_PT`             | FK `id_country`, FK `id_date`                                       |
| Fato  | `FACT_EXP`                | FK `id_country`, FK `id_date`                                       |
| Fato  | `FACT_EXP_PROD_BY_PT`     | FK `id_product`, FK `id_date`                                       |
| Fato  | `FACT_EXP_SECTOR_BY_PT`   | FK `id_date`                                                        |
| Fato  | `FACT_IMP_PT`             | FK `id_country`, FK `id_date`                                       |
| Fato  | `FACT_IMP_PROD_BY_PT`     | FK `id_product`, FK `id_date`                                       |
| Fato  | `FACT_IMP_SECTOR`         | FK `id_date`                                                        |
| Calc  | `CALC_EXP_PT_2024`        | FK `id_country`                                                     |
| Calc  | `CALC_EXP_2024`           | FK `id_country`                                                     |
| Calc  | `CALC_EXP_PROD_BY_PT`     | FK `id_product`                                                     |
| Calc  | `CALC_IMP_PT_2024`        | FK `id_country`                                                     |
| Calc  | `CALC_IMP_PROD_BY_PT`     | FK `id_product`                                                     |
