# Modelo Lógico – Ceramics World

O modelo lógico descreve granulações, cardinalidades e regras de negócio antes da materialização física. Todas as chaves técnicas são inteiras (`INT`) e os valores monetários usam `DECIMAL(18,2)` (USD); percentagens são armazenadas em `DECIMAL(18,4)` após conversão para formato decimal no ETL.

## Dimensões
| Tabela | Descrição | Campos principais |
| --- | --- | --- |
| `DIM_COUNTRY` | Catálogo único de países enriquecido com ISO3, continente, região e slug normalizado. | `id_country` (PK), `country_name`, `country_code`, `continent`, `region`, `country_slug` |
| `DIM_PRODUCT` | HS Codes a 4 dígitos relevantes para o portefólio cerâmico. | `id_product` (PK), `code`, `product_label`, `hs_section`, `hs_chapter` |
| `DIM_DATE` | Calendário anual/trimestral com etiqueta de década (ex.: "2010s"). | `id_date` (PK), `year`, `quarter`, `decade` |

## Fatos (séries temporais)
| Tabela | Grão | Métricas |
| --- | --- | --- |
| `FACT_EXP_PT` | (`id_country`, `id_date`) | `value` |
| `FACT_EXP` | (`id_country`, `id_date`) | `value` |
| `FACT_EXP_PROD_BY_PT` | (`id_product`, `id_date`) | `value` |
| `FACT_EXP_SECTOR_BY_PT` | (`id_date`, trimestre) | `value` |
| `FACT_IMP` | (`id_country`, `id_date`) | `value` |
| `FACT_IMP_PT` | (`id_country`, `id_date`) | `value` |
| `FACT_IMP_PROD` | (`id_product`, `id_date`) | `value` |
| `FACT_IMP_SEGMENT` | (`id_product`, `id_country`, `id_date`) | `value` |
| `FACT_IMP_SECTOR` | (`id_date`, trimestre) | `value` |
| `FACT_PIB` | (`id_country`, `id_date`) | `gdp_per_capita_usd` |
| `FACT_URBAN` | (`id_country`, `id_date`) | `urban_population_total` |
| `FACT_CONSTRUCTION` | (`id_country`, `id_date`) | `value_added_growth_pct` |

Regras comuns:
1. Todas as tabelas factuais dependem de `DIM_DATE` (exceto snapshots).
2. Países/produtos inexistentes são tratados no staging; o DW só recebe chaves válidas.
3. Valores trimestrais (serviços) acumulam quatro registros por ano para análises sazonais.

## Tabelas de Cálculo (snapshot 2024)
| Tabela | Grão | Métricas principais |
| --- | --- | --- |
| `CALC_EXP_PT_2024` | `id_country` | `value_2024_usd`, `trade_balance_2024_usd`, `share_portugal_exports_pct`, `growth_value_*`, `ranking_world_imports`, `share_world_imports_pct`, `partner_growth_2020_2024_pct`, `avg_distance_km`, `concentration_index`, `avg_tariff_pct`. |
| `CALC_EXP_2024` / `CALC_EXP_WORLD` / `CALC_ALL_EXP_2024` | `id_country` | Mesmo layout (variam apenas as fontes). |
| `CALC_IMP_2024`, `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024` | `id_country` | Métricas de importação, incluindo tarifa média quando aplicável. |
| `CALC_EXP_PROD_BY_PT`, `CALC_IMP_PROD_BY_PT` | `id_product` | Crescimentos, quotas, ranking mundial, concentração e distâncias médias por HS code. |

## Cardinalidades
- `DIM_COUNTRY` 1:N `FACT_*` e `CALC_*` orientadas a país.
- `DIM_PRODUCT` 1:N `FACT_*`/`CALC_*` orientadas a produto.
- `DIM_DATE` 1:N todos os factos temporais.

## Regras de Negócio
1. Percentagens são convertidas para decimal (`pct * 0.01`) ainda no staging.
2. `DIM_DATE` contém todos os anos disponíveis nas séries; novas fontes apenas acrescentam anos, sem reprocessos completos.
3. Snapshots `CALC_*` são reconstruídos a cada execução do `sql/30_facts.sql`, garantindo alinhamento com o staging.
4. O ETL assegura nomes de países e HS codes harmonizados antes da carga nas dimensões, evitando duplicidades.
