# Modelo Lógico – Ceramics World

O modelo lógico descreve as estruturas, cardinalidades e regras de negócio usadas no DW antes da
implementação física. Todas as tabelas usam chaves inteiras (`INT`) geradas a partir das dimensões,
enquanto as métricas são armazenadas em `DECIMAL(18,2)` ou `DECIMAL(18,4)` conforme necessário.

## Dimensões
| Tabela | Descrição | Campos chave / atributos |
| --- | --- | --- |
| `DIM_COUNTRY` | Catálogo único de países enriquecido com ISO3, continente e região. | `id_country` (PK), `country_name`, `country_code`, `continent`, `region` |
| `DIM_PRODUCT` | Lista de HS Codes (4 dígitos) usados para o portefólio cerâmico. | `id_product` (PK), `code`, `product_label`, `hs_section`, `hs_chapter` |
| `DIM_DATE` | Calendário simplificado com granularidade anual/trimestral. | `id_date` (PK), `year`, `quarter`, `decade_label` |

## Fatos (séries temporais)
| Tabela | Grão | Métricas principais |
| --- | --- | --- |
| `FACT_EXP_PT` | (`id_country`, `id_date`) | `value` (USD) |
| `FACT_EXP` | (`id_country`, `id_date`) | `value` |
| `FACT_EXP_PROD_BY_PT` | (`id_product`, `id_date`) | `value` |
| `FACT_EXP_SECTOR_BY_PT` | (`id_date`) trimestral | `value` |
| `FACT_IMP` | (`id_country`, `id_date`) | `value` |
| `FACT_IMP_PT` | (`id_country`, `id_date`) | `value` |
| `FACT_IMP_PROD_BY_PT` | (`id_product`, `id_date`) | `value` |
| `FACT_IMP_SECTOR` | (`id_date`) trimestral | `value` |
| `FACT_PIB` | (`id_country`, `id_date`) | `gdp_per_capita_usd` |
| `FACT_URBAN` | (`id_country`, `id_date`) | `urban_population_total` |
| `FACT_CONSTRUCTION` | (`id_country`, `id_date`) | `value_added_growth_pct` |

Todas as fact tables possuem:
- FK obrigatória para `DIM_COUNTRY` ou `DIM_PRODUCT` quando aplicável.
- FK obrigatória para `DIM_DATE`, garantindo alinhamento temporal entre as séries.

## Tabelas de Cálculo (snapshot 2024)
Estas tabelas concentram indicadores pré-calculados para acelerar o Power BI. O grão é sempre
`id_country` ou `id_product` + snapshot 2024.

| Tabela | Descrição | Campos chave / métricas |
| --- | --- | --- |
| `CALC_EXP_PT_2024` | KPIs por destino das exportações portuguesas. | `id_country` + `value_2024_usd`, `trade_balance_2024_usd`, `share_portugal_exports_pct`, `growth_value_*`, `ranking_world_imports`, `share_world_imports_pct`, `partner_growth_2020_2024_pct`, `avg_distance_km`, `concentration_index`, `avg_tariff_pct` |
| `CALC_EXP_2024` | KPIs para exportadores cerâmicos globais. | `id_country` + `value_2024_usd`, `trade_balance_2024_usd`, `growth_value_*`, `share_world_exports_pct`, `avg_distance_km`, `concentration_index` |
| `CALC_EXP_WORLD` | KPIs para exportadores globais (todos os produtos cerâmicos). | Mesmo layout de `CALC_EXP_2024`. |
| `CALC_ALL_EXP_2024` | KPIs para exportadores considerando todos os produtos do Trade Map. | Mesmo layout de `CALC_EXP_WORLD`. |
| `CALC_IMP_2024` | KPIs para importadores (all products). | `id_country` + `value_2024_usd`, `trade_balance_2024_usd`, `growth_value_*`, `share_world_imports_pct`, `avg_distance_km`, `concentration_index`. |
| `CALC_IMP_PT_2024` | KPIs para importadores (cerâmica) incluindo tarifa média. | Layout semelhante ao anterior + `avg_tariff_pct`. |
| `CALC_IMP_CER_2024` | KPIs cerâmicos do ficheiro `Trade_Map_-_List_of_importers_for_the_selected_product_in_2024_(Ceramic_products)`. | Igual a `CALC_IMP_PT_2024`. |
| `CALC_EXP_PROD_BY_PT` | KPIs por produto exportado (Portugal). | `id_product` + métricas de crescimento, ranking e concentração. |
| `CALC_IMP_PROD_BY_PT` | KPIs por produto importado. | `id_product` + métricas equivalentes. |

## Cardinalidades
- `DIM_COUNTRY` 1:N `FACT_*` (exceto `FACT_EXP_SECTOR_BY_PT` e `FACT_IMP_SECTOR`, que só dependem de
  `DIM_DATE`) e 1:N `CALC_*` baseadas em país.
- `DIM_PRODUCT` 1:N `FACT_*` / `CALC_*` baseadas em produto.
- `DIM_DATE` 1:N todos os fatos temporais, garantindo consistência anual/trimestral.

## Regras de Negócio
1. Todos os valores monetários são carregados em USD e converteram-se percentuais para forma decimal
   (`share_world_exports_pct` = valor original × 0.01).
2. Snapshots de 2024 são carregados diretamente das views de staging e não dependem de `DIM_DATE`.
3. As views de staging cuidam da limpeza (trim, normalização de códigos e unpivot), deixando o
   modelo lógico limpo e normalizado.
