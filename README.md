# Data-Warehouse-Power-BI – Ceramics World

## Contexto
Uma empresa portuguesa de cerâmica quer identificar mercados prioritários para exportação,
acompanhando a realidade competitiva (exportadores/importadores), bem como os principais
drivers macroeconómicos (PIB per capita, urbanização e crescimento da construção). Todo o processo
foi modelado num data warehouse em SQL Server e exposto em Power BI.

## Objetivos
1. Consolidar dados do Trade Map, World Bank e outras fontes públicas num modelo dimensional único.
2. Calcular KPIs 2024 (balances, rankings, quotas, distâncias, tarifas) para países e produtos.
3. Disponibilizar séries históricas de comércio, PIB, urbanização e construção para análise temporal.
4. Alimentar dashboards Power BI com medidas DAX reutilizáveis.

## Estrutura do Repositório
```
├── data/                         # CSVs/Excels ingestidos pelo ETL
├── docker/                       # Variáveis de ambiente / compose (quando aplicável)
├── docs/                         # Modelos conceptual, lógico, físico e relacional
├── etl/                          # Scripts Python de ingestão (pandas + SQLAlchemy)
├── Power BI/                     # Medidas DAX e assets do relatório
└── sql/                          # Scripts de staging, dimensões, fatos e cálculos
```

## Fontes de Dados
| Fonte | Dataset | Utilização |
| --- | --- | --- |
| Trade Map | `Trade_Map_-_List_of_exporters_for_the_selected_product_in_2024_(Ceramic_products)` | KPIs para `CALC_EXP_2024`. |
| Trade Map | `Trade_Map_-_List_of_exporters_for_the_selected_product_in_2024_(All_products)` | KPIs globais (`CALC_EXP_WORLD`, `CALC_ALL_EXP_2024`, `CALC_IMP_2024`). |
| Trade Map | `Trade_Map_-_List_of_importers_for_the_selected_product_in_2024_(Ceramic_products)` | `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024`. |
| Trade Map | `Trade_Map_-_List_of_importers_for_the_selected_product_(Ceramic_products)` | `FACT_IMP`. |
| Trade Map | Séries históricas (export/import country/product) | `FACT_EXP_PT`, `FACT_EXP`, `FACT_IMP`, `FACT_IMP_PT`, `FACT_EXP_PROD_BY_PT`, `FACT_IMP_PROD_BY_PT`. |
| Trade Map | Serviços de construção (exports/imports) | `FACT_EXP_SECTOR_BY_PT`, `FACT_IMP_SECTOR`. |
| World Bank | `GDP per capita (NY.GDP.PCAP.CD)` | `FACT_PIB`. |
| World Bank | `Urban population (SP.URB.TOTL)` | `FACT_URBAN`. |
| World Bank | `NV.IND.TOTL.KD.ZG` (Industry incl. construction, value added growth) | `FACT_CONSTRUCTION`. |

## Scripts SQL
- `sql/10_staging.sql`: criação das views de staging, incluindo unpivot e normalização de países/HS codes.
- `sql/20_dimensions.sql`: carga das dimensões (`DIM_COUNTRY`, `DIM_PRODUCT`, `DIM_DATE`).
- `sql/30_facts.sql`: recria e popula todas as fact tables e tabelas de cálculo, incluindo as novas
  `CALC_EXP_WORLD`, `CALC_IMP_2024`, `CALC_IMP_CER_2024`, `FACT_IMP`, `FACT_PIB`, `FACT_URBAN`,
  `FACT_CONSTRUCTION`.

## Documentação Atualizada
- `docs/Modelo_Conceptual.md`: visão de alto nível com as novas entidades.
- `docs/Modelo_Logico.md`: grão, cardinalidades e regras das tabelas.
- `docs/Modelo_Fisico.md`: DDL consolidado (inclui novas tabelas).
- `docs/Modelo_Relacional.md`: relacionamentos e diagrama Mermaid.

## Power BI
O ficheiro `Power BI/DAX.md` contém as medidas principais usadas no relatório. Com a introdução das
novas tabelas (`CALC_IMP_CER_2024`, `CALC_IMP_2024`, `FACT_PIB`, etc.) é possível:
- Calcular shares cerâmica vs. exportações totais.
- Relacionar crescimento da construção e PIB per capita com o desempenho comercial.
- Diferenciar métricas de exportação (origem) e importação (destino).

## Como Executar
1. Configure o `.env` (ou `docker/.env`) com as credenciais do SQL Server.
2. Execute `etl/ingest_csv.py` para carregar/atualizar todas as tabelas staging.
3. Corra `sqlcmd -d CeramicsWorldDB -i sql/10_staging.sql`, depois `20_dimensions.sql` e `30_facts.sql`.
4. Atualize o relatório Power BI apontando para a base `CeramicsWorldDB`.

## Referências
- https://www.trademap.org/
- https://data.worldbank.org/indicator/SP.URB.TOTL
- https://data.worldbank.org/indicator/NV.IND.TOTL.KD.ZG
- https://data.worldbank.org/indicator/NY.GDP.PCAP.CD

## Licença
Projeto apenas para fins educativos – licenciado sob MIT.
