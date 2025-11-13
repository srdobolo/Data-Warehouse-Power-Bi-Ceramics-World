# Modelo Físico – Ceramics World

Implementação em SQL Server (`CeramicsWorldDB`) com scripts versionados no diretório `sql/`. As tabelas são recriadas a cada ciclo de carga para garantir reprodutibilidade.

## Dimensões
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

## Fatos (padrão)
- Chaves substitutas (`id_country`, `id_product`, `id_date`) com `FOREIGN KEY` explícitas.
- Valores monetários em `DECIMAL(18,2)` e percentuais em `DECIMAL(18,4)`.
- Todas as tabelas são criadas em `sql/30_facts.sql` após o drop completo das estruturas anteriores.

Exemplo (`FACT_IMP_PROD`):
```sql
CREATE TABLE dbo.FACT_IMP_PROD (
    id_imp_prod INT IDENTITY(1,1) PRIMARY KEY,
    id_product  INT NOT NULL REFERENCES dbo.DIM_PRODUCT(id_product),
    id_date     INT NOT NULL REFERENCES dbo.DIM_DATE(id_date),
    value       DECIMAL(18,2) NULL
);
```

## Tabelas de cálculo
Estruturas homogéneas com PK alinhada à dimensão correspondente. Exemplo:
```sql
CREATE TABLE dbo.CALC_IMP_PT_2024 (
    id_country INT PRIMARY KEY REFERENCES dbo.DIM_COUNTRY(id_country),
    value_2024_usd            DECIMAL(18,2),
    trade_balance_2024_usd    DECIMAL(18,2),
    growth_value_2020_2024_pct DECIMAL(18,4),
    growth_value_2023_2024_pct DECIMAL(18,4),
    share_world_imports_pct   DECIMAL(18,4),
    avg_distance_km           DECIMAL(18,2),
    concentration_index       DECIMAL(18,4),
    avg_tariff_pct            DECIMAL(18,4)
);
```

## Considerações Técnicas
1. **Conversão de percentagens**: realizada nas views de staging (`* * 0.01`) para manter consistência e facilitar cálculos no BI.
2. **Q4 como proxy anual**: datas provenientes de séries anuais são armazenadas com `quarter = 'Q4'`, permitindo joins simples com dimensões temporais.
3. **Snapshots idempotentes**: as tabelas `CALC_*` são recriadas em cada ciclo para assegurar que alterações de staging se propagam imediatamente.
4. **Referential integrity**: todas as FKs usam `ON DELETE NO ACTION`; qualquer remoção exige limpeza prévia das tabelas dependentes (automatizado nos scripts).
5. **Nomeação de tabelas de staging**: `etl/ingest_csv.py` gera nomes seguros como `imports_products_csv_trade_map_list_of_imported_products_for_the_selected_product_ceramic_products_xls`, garantindo rastreabilidade do ficheiro original.
