# Data-Warehouse-Power-Bi-Ceramics-World

## Contexto do Projeto

Uma empresa portuguesa de cerâmica (pavimentos, revestimentos e louça sanitária) procura expandir a sua exportação para mercados internacionais com crescimento no setor da construção e renovação urbana.

O objetivo principal é utilizar análises de dados e visualizações em Power BI para identificar oportunidades de mercado e clusters de países com características semelhantes, suportando decisões estratégicas de internacionalização

## Objetivos do Projeto

### 1. Analisar o mercado global de produtos cerâmicos, com foco em

- Importações e exportações (Trade Map, HS Codes: 6907, 6908, 6910)
- Crescimento do setor da construção (Eurostat)
- Urbanização e indicadores demográficos (World Bank)

### 2. Aplicar técnicas de Data Warehousing e Data Analytics, incluindo

- ETL (Extract, Transform, Load) de múltiplas fontes de dados
- Normalização e integração num modelo dimensional
- Criação de medidas e KPIs relevantes (PIB per capita, crescimento urbano, quota de mercado, etc.)

### 3. Desenvolver dashboards interativos em Power BI, que permitam

- Visualizar clusters de países
- Avaliar a evolução setorial da construção nos últimos 5 anos
- Analisar quota de mercado por origem
- Realizar análise competitiva (preço vs. qualidade)

## Estrutura do Repositório

```kotlin
📦 produtos-ceramicos
 ┣ 📂 data
 ┃ ┣ trade_map.csv
 ┃ ┣ eurostat_construction.csv
 ┃ ┗ worldbank_urbanization.csv
 ┣ 📂 scripts
 ┃ ┣ etl_process.py
 ┃ ┗ clustering_analysis.ipynb
 ┣ 📂 powerbi
 ┃ ┗ dashboard.pbix
 ┣ 📄 README.md
 ┗ 📄 data_model.sql
 ```

## Stack Tecnológico

| Tecnologia                            | Utilização                          |
| ------------------------------------- | ----------------------------------- |
| **SQL Server / Azure Data Warehouse** | Armazenamento e modelagem de dados  |
| **Power BI Desktop / Service**        | Criação e publicação dos dashboards |
| **Python (Pandas, Scikit-learn)**     | Pré-processamento e clustering      |
| **Excel / CSV / API Connectors**      | Fontes de dados externas            |

## Estrutura Analítica

| Fonte           | Descrição                                             | Tipo de Dados          |
| --------------- | ----------------------------------------------------- | ---------------------- |
| **Trade Map**   | Importações e exportações (HS 6907, 6908, 6910)       | Comércio Internacional |
| **World Bank**  | Urbanização, PIB per capita, crescimento populacional | Macroeconômico         |

## Modelo Conceptual

[Modelo Conceptual]('https://github.com/srdobolo/Data-Warehouse-Power-Bi-Ceramics-World/blob/main/docs/Modelo_Conceptual.md')

## Modelo Lógico

[Modelo Lógico]('https://github.com/srdobolo/Data-Warehouse-Power-Bi-Ceramics-World/blob/42a5820d779a75e8285f5d3949c0b53080c2bd4e/docs/Modelo_Conceptual.md')

## Modelo Físico

[Modelo Físico]('https://github.com/srdobolo/Data-Warehouse-Power-Bi-Ceramics-World/blob/42a5820d779a75e8285f5d3949c0b53080c2bd4e/docs/Modelo_Conceptual.md')

## Modelo Relacional

[Modelo Relacional]('https://github.com/srdobolo/Data-Warehouse-Power-Bi-Ceramics-World/blob/42a5820d779a75e8285f5d3949c0b53080c2bd4e/docs/Modelo_Conceptual.md')

## References

> https://data.worldbank.org/indicator/SP.URB.TOTL?end=2024&start=2024&view=map

> https://www.trademap.org/Country_SelService_TS.aspx

> https://tradingeconomics.com/country-list/construction-output ?????????????

## licença

Este projeto é apenas para fins educativos e não contém dados confidenciais.
Licenciado sob a MIT License.