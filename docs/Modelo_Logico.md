# Modelo Lógico

## Visão Geral

| Tabela                  | Tipo  | Descrição breve                                                                |
| ----------------------- | ----- | ------------------------------------------------------------------------------ |
| `DIM_COUNTRY`           | Dim   | Dicionário de países/territórios (nome normalizado + código ISO3).             |
| `DIM_PRODUCT`           | Dim   | Catálogo HS dos produtos analisados.                                           |
| `DIM_DATE`              | Dim   | Calendário (ano, trimestre, década).                                           |
| `FACT_EXP_PT`           | Fato  | Exportações de Portugal por destino/ano.                                       |
| `FACT_EXP`              | Fato  | Exportações mundiais por exportador/ano.                                       |
| `FACT_EXP_PROD_BY_PT`   | Fato  | Exportações de Portugal por código HS.                                         |
| `FACT_EXP_SECTOR_BY_PT` | Fato  | Exportações de serviços de construção por trimestre.                           |
| `FACT_IMP_PT`           | Fato  | Importações mundiais por importador/ano.                                       |
| `FACT_IMP_PROD_BY_PT`   | Fato  | Importações por código HS.                                                     |
| `FACT_IMP_SECTOR`       | Fato  | Importações globais de serviços de construção (linha “World”).                 |
| `CALC_EXP_PT_2024`      | Calc  | KPIs 2024 para destinos das exportações portuguesas.                           |
| `CALC_EXP_2024`         | Calc  | KPIs 2024 para exportadores mundiais (produtos cerâmicos).                     |
| `CALC_ALL_EXP_2024`     | Calc  | KPIs 2024 para exportadores de todos os produtos (Total Trade Map).            |
| `CALC_EXP_PROD_BY_PT`   | Calc  | KPIs 2024 para produtos exportados por Portugal.                               |
| `CALC_IMP_PT_2024`      | Calc  | KPIs 2024 para importadores (inclui tarifa média aplicada).                    |
| `CALC_IMP_PROD_BY_PT`   | Calc  | KPIs 2024 para produtos importados.                                            |

## Estruturas

### DIM_COUNTRY

| Coluna        | Tipo         | PK | FK | Descrição                  |
| ------------- | ------------ | -- | -- | -------------------------- |
| `id_country`  | INT IDENTITY | ✅  |    | Chave surrogate            |
| `country_name`| VARCHAR(150) |    |    | Nome normalizado           |
| `country_code`| CHAR(3)      |    |    | ISO3 (único)               |

### DIM_PRODUCT

| Coluna        | Tipo          | PK | FK | Descrição                        |
| ------------- | ------------- | -- | -- | -------------------------------- |
| `id_product`  | INT IDENTITY  | ✅  |    | Chave surrogate                  |
| `code`        | VARCHAR(20)   |    |    | Código HS (sem apóstrofos)       |
| `product_label`| VARCHAR(255) |    |    | Descrição amigável               |

### DIM_DATE

| Coluna    | Tipo      | PK | FK | Descrição                 |
| --------- | --------- | -- | -- | ------------------------- |
| `id_date` | INT IDENTITY | ✅ |    | Chave surrogate          |
| `year`    | INT       |    |    | Ano (AAAA)                |
| `quarter` | CHAR(2)   |    |    | `Q1`, `Q2`, `Q3`, `Q4`    |
| `decade`  | VARCHAR(10)|   |    | Ex.: `2010s`              |

### FACT_EXP_PT

| Coluna      | Tipo        | PK | FK | Descrição                               |
| ----------- | ----------- | -- | -- | --------------------------------------- |
| `id_exp_pt` | INT IDENTITY| ✅ |    | Linha fact                              |
| `id_country`| INT         |    | ✔  | Destino das exportações (DIM_COUNTRY)   |
| `id_date`   | INT         |    | ✔  | Ano (DIM_DATE, quarter `Q4`)            |
| `value`     | DECIMAL     |    |    | Valor exportado (USD)                   |

### CALC_EXP_PT_2024

| Coluna                           | Tipo      | PK | FK | Descrição                                                |
| -------------------------------- | --------- | -- | -- | -------------------------------------------------------- |
| `id_country`                     | INT       | ✅ | ✔  | País destino                                             |
| `value_2024_usd`                 | DECIMAL   |    |    | Valor exportado em 2024                                  |
| `trade_balance_2024_usd`         | DECIMAL   |    |    | Balança comercial 2024                                   |
| `share_portugal_exports_pct`     | DECIMAL   |    |    | % na pauta portuguesa                                    |
| `growth_value_2020_2024_pct`     | DECIMAL   |    |    | CAGR 2020-24                                             |
| `growth_value_2023_2024_pct`     | DECIMAL   |    |    | Variação 2023-24                                         |
| `ranking_world_imports`          | INT       |    |    | Ranking do destino em importações mundiais               |
| `share_world_imports_pct`        | DECIMAL   |    |    | % nas importações mundiais                               |
| `partner_growth_2020_2024_pct`   | DECIMAL   |    |    | Crescimento das importações do parceiro                  |
| `avg_distance_km`                | DECIMAL   |    |    | Distância média (km)                                     |
| `concentration_index`            | DECIMAL   |    |    | Índice de concentração                                   |
| `avg_tariff_pct`                 | DECIMAL   |    |    | Tarifa média estimada                                    |

### FACT_EXP

| Coluna      | Tipo        | PK | FK | Descrição                         |
| ----------- | ----------- | -- | -- | --------------------------------- |
| `id_exp`    | INT IDENTITY| ✅ |    | Linha fact                        |
| `id_country`| INT         |    | ✔  | País exportador                   |
| `id_date`   | INT         |    | ✔  | Ano (`Q4`)                        |
| `value`     | DECIMAL     |    |    | Valor exportado (USD)             |

### CALC_EXP_2024

Semelhante a `CALC_EXP_PT_2024`, mas com métricas globais (share mundial, distância média, etc.) e sem campos específicos de parceiros, sempre para o portfólio cerâmico.

### CALC_ALL_EXP_2024

| Coluna                           | Tipo    | PK | FK | Descrição                                         |
| -------------------------------- | ------- | -- | -- | ------------------------------------------------- |
| `id_country`                     | INT     | ✅  | ✔  | País exportador (todos os produtos)               |
| `value_2024_usd`                 | DECIMAL |    |    | Valor exportado total em 2024                     |
| `trade_balance_2024_usd`         | DECIMAL |    |    | Balança comercial 2024                            |
| `growth_value_2020_2024_pct`     | DECIMAL |    |    | Crescimento anual composto 2020‑24 (convertido)   |
| `growth_value_2023_2024_pct`     | DECIMAL |    |    | Crescimento 2023‑24                               |
| `share_world_exports_pct`        | DECIMAL |    |    | Participação nas exportações mundiais             |
| `avg_distance_km`                | DECIMAL |    |    | Distância média dos importadores                  |
| `concentration_index`            | DECIMAL |    |    | Índice de concentração dos importadores           |

### FACT_EXP_PROD_BY_PT / CALC_EXP_PROD_BY_PT

- `FACT_EXP_PROD_BY_PT`: `id_product`, `id_date (Q4)`, `value`.
- `CALC_EXP_PROD_BY_PT`: métricas 2024 por HS (`value_2024_usd`, `trade_balance_2024_usd`, `growth_value_2020_2024_pct`, `growth_quantity_2020_2024_pct`, `growth_value_2023_2024_pct`, `world_import_growth_2020_2024_pct`, `share_world_exports_pct`, `ranking_world_exports`, `avg_distance_km`, `concentration_index`).

### FACT_EXP_SECTOR_BY_PT

| Coluna         | Tipo   | PK | FK | Descrição                                    |
| -------------- | ------ | -- | -- | -------------------------------------------- |
| `id_exp_sector`| INT IDENTITY | ✅ |    | Linha fact                                   |
| `id_date`      | INT    |    | ✔  | Trimestre (DIM_DATE)                         |
| `value`        | DECIMAL|    |    | Valor exportado em serviços de construção    |

### FACT_IMP_PT / CALC_IMP_PT_2024

Estrutura idêntica às tabelas de exportação, mas usando as views de importação (país importador). Os campos de cálculo incluem `avg_tariff_pct`.

### FACT_IMP_PROD_BY_PT / CALC_IMP_PROD_BY_PT

Usam `id_product` + `id_date` e métricas correspondentes.

### FACT_IMP_SECTOR

- `id_imp_sector` (PK), `id_date` (FK), `value`.
- Apenas linha “World” do dataset de serviços importados.

## Cardinalidades

- `DIM_COUNTRY` 1:N (`FACT_EXP_PT`, `FACT_EXP`, `FACT_IMP_PT`, `CALC_EXP_*`, `CALC_IMP_*`)
- `DIM_PRODUCT` 1:N (`FACT_EXP_PROD_BY_PT`, `FACT_IMP_PROD_BY_PT`, `CALC_EXP_PROD_BY_PT`, `CALC_IMP_PROD_BY_PT`)
- `DIM_DATE` 1:N (`FACT_EXP_PT`, `FACT_EXP`, `FACT_EXP_PROD_BY_PT`, `FACT_EXP_SECTOR_BY_PT`, `FACT_IMP_PT`, `FACT_IMP_PROD_BY_PT`, `FACT_IMP_SECTOR`)

Não há FKs para `DIM_DATE` nas tabelas CALC porque representam apenas o snapshot 2024.
