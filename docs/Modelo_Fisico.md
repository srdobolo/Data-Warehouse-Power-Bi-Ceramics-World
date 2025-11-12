# Modelo Físico – Ceramics World

O modelo físico é implementado em SQL Server (`CeramicsWorldDB`). Abaixo estão os DDLs
consolidados das principais tabelas, incluindo as novas estruturas adicionadas ao repositório.

## Dimensões
```sql
CREATE TABLE dbo.DIM_COUNTRY (
    id_country     INT IDENTITY(1,1) PRIMARY KEY,
    country_name   VARCHAR(150) NOT NULL,
    country_code   CHAR(3)      NOT NULL,
    continent      VARCHAR(50)  NULL,
    region         VARCHAR(100) NULL,
    country_slug   VARCHAR(150) NULL
);

CREATE TABLE dbo.DIM_PRODUCT (
    id_product   INT IDENTITY(1,1) PRIMARY KEY,
    code         VARCHAR(10)  NOT NULL,
    product_label VARCHAR(200) NOT NULL,
    hs_section   VARCHAR(50)  NULL
);

CREATE TABLE dbo.DIM_DATE (
    id_date      INT IDENTITY(1,1) PRIMARY KEY,
    [year]       INT NOT NULL,
    [quarter]    CHAR(2) NOT NULL,
    decade       VARCHAR(10) NULL
);
```

## Fatos
Todas as fact tables usam `DECIMAL(18,2)` para valores monetários e `DECIMAL(18,4)` para percentagens.

```sql
CREATE TABLE dbo.FACT_EXP_PT (
    id_exp_pt  INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date    INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value      DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_EXP (
    id_exp INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_EXP_PROD_BY_PT (
    id_exp_prod_pt INT IDENTITY(1,1) PRIMARY KEY,
    id_product INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_PRODUCT(id_product),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_EXP_SECTOR_BY_PT (
    id_exp_sector INT IDENTITY(1,1) PRIMARY KEY,
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_IMP (
    id_imp INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_IMP_SEGMENT (
    id_imp_segment INT IDENTITY(1,1) PRIMARY KEY,
    id_product INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_PRODUCT(id_product),
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_IMP_PT (
    id_imp_pt INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_IMP_PROD_BY_PT (
    id_imp_prod_pt INT IDENTITY(1,1) PRIMARY KEY,
    id_product INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_PRODUCT(id_product),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_IMP_SECTOR (
    id_imp_sector INT IDENTITY(1,1) PRIMARY KEY,
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_PIB (
    id_pib INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    gdp_per_capita_usd DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_URBAN (
    id_urban INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    urban_population_total DECIMAL(18,2) NULL
);

CREATE TABLE dbo.FACT_CONSTRUCTION (
    id_construction INT IDENTITY(1,1) PRIMARY KEY,
    id_country INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    id_date INT NOT NULL FOREIGN KEY REFERENCES dbo.DIM_DATE(id_date),
    value_added_growth_pct DECIMAL(18,4) NULL
);
```

## Tabelas de Cálculo 2024

```sql
CREATE TABLE dbo.CALC_EXP_PT_2024 (
    id_country INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    share_portugal_exports_pct DECIMAL(18,4),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    ranking_world_imports INT,
    share_world_imports_pct DECIMAL(18,4),
    partner_growth_2020_2024_pct DECIMAL(18,4),
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4),
    avg_tariff_pct DECIMAL(18,4)
);

CREATE TABLE dbo.CALC_EXP_2024 (
    id_country INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_exports_pct DECIMAL(18,4),
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4)
);

CREATE TABLE dbo.CALC_EXP_WORLD (
    id_country INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_exports_pct DECIMAL(18,4),
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4)
);

CREATE TABLE dbo.CALC_ALL_EXP_2024 (... mesmo layout de `CALC_EXP_WORLD` ...);

CREATE TABLE dbo.CALC_IMP_2024 (
    id_country INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_imports_pct DECIMAL(18,4),
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4)
);

CREATE TABLE dbo.CALC_IMP_PT_2024 (
    id_country INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_imports_pct DECIMAL(18,4),
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4),
    avg_tariff_pct DECIMAL(18,4)
);

CREATE TABLE dbo.CALC_IMP_CER_2024 (
    id_country INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_imports_pct DECIMAL(18,4),
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4),
    avg_tariff_pct DECIMAL(18,4)
);

CREATE TABLE dbo.CALC_EXP_PROD_BY_PT (
    id_product INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_PRODUCT(id_product),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_quantity_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    world_import_growth_2020_2024_pct DECIMAL(18,4),
    share_world_exports_pct DECIMAL(18,4),
    ranking_world_exports INT,
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4)
);

CREATE TABLE dbo.CALC_IMP_PROD_BY_PT (
    id_product INT PRIMARY KEY FOREIGN KEY REFERENCES dbo.DIM_PRODUCT(id_product),
    value_2024_usd DECIMAL(18,2),
    trade_balance_2024_usd DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_quantity_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    world_export_growth_2020_2024_pct DECIMAL(18,4),
    avg_distance_km DECIMAL(18,2),
    concentration_index DECIMAL(18,4)
);
```

## Considerações de Implementação
- As percentagens vindas do Trade Map ou World Bank são convertidas para forma decimal durante o ETL
  (`pct * 0.01`) para evitar cálculos repetidos em Power BI.
- Todas as tabelas `CALC_*` são recriadas em cada execução do script `sql/30_facts.sql`, garantindo que
  o snapshot 2024 é consistente com o staging.
- O ficheiro `Trade_Map_-_List_of_importers_for_the_selected_product_in_2024_(Ceramic_products)` alimenta
  diretamente `CALC_IMP_PT_2024` e `CALC_IMP_CER_2024`, enquanto `FACT_IMP` usa a versão histórica
  `Trade_Map_-_List_of_importers_for_the_selected_product_(Ceramic_products)`.
- Os ficheiros específicos de segmentos (`Ceramic_flags_and_paving...`, `Glazed_ceramic_flags...`,
  `Ceramic_sinks...`) alimentam `FACT_IMP_SEGMENT`, permitindo cruzar `DIM_PRODUCT` e `DIM_COUNTRY`
  ao nível anual.
- Os indicadores macroeconómicos (`FACT_PIB`, `FACT_URBAN`, `FACT_CONSTRUCTION`) utilizam `DIM_DATE`
  com o trimestre fixo em `Q4`, simplificando análises anuais no DW.
