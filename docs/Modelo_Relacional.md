# Modelo Relacional – Ceramics World

Este documento descreve como as entidades se relacionam fisicamente na base de dados após a
normalização aplicada pelo ETL.

## Principais Relacionamentos
| Origem | Destino | Tipo | Descrição |
| --- | --- | --- | --- |
| `DIM_COUNTRY` | `FACT_EXP_PT`, `FACT_EXP`, `FACT_IMP`, `FACT_IMP_PT`, `FACT_PIB`, `FACT_URBAN`, `FACT_CONSTRUCTION` | 1:N | Cada país pode possuir múltiplas medições ao longo do tempo. |
| `DIM_COUNTRY` | `CALC_EXP_PT_2024`, `CALC_EXP_2024`, `CALC_EXP_WORLD`, `CALC_ALL_EXP_2024`, `CALC_IMP_2024`, `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024` | 1:N | KPIs 2024 por país. |
| `DIM_PRODUCT` | `FACT_EXP_PROD_BY_PT`, `FACT_IMP_PROD_BY_PT`, `CALC_EXP_PROD_BY_PT`, `CALC_IMP_PROD_BY_PT` | 1:N | Séries e KPIs por HS code. |
| `DIM_DATE` | Todas as `FACT_*` (exceto calc tables) | 1:N | Cada registo factual aponta para um ano/trimestre específico. |
| `DIM_DATE` | `FACT_EXP_SECTOR_BY_PT`, `FACT_IMP_SECTOR` | 1:N | Séries trimestrais agregadas por data. |

## Diagrama Lógico-Relacional
```mermaid
graph LR
    subgraph Dimensões
        dc[DIM_COUNTRY]
        dp[DIM_PRODUCT]
        dd[DIM_DATE]
    end

    subgraph Fatos Comércio
        fexppt[FACT_EXP_PT]
        fexp[FACT_EXP]
        fimpt[FACT_IMP_PT]
        fimp[FACT_IMP]
        fexpprod[FACT_EXP_PROD_BY_PT]
        fimpprod[FACT_IMP_PROD_BY_PT]
        fexpsec[FACT_EXP_SECTOR_BY_PT]
        fimpsec[FACT_IMP_SECTOR]
    end

    subgraph Macro
        fpib[FACT_PIB]
        furban[FACT_URBAN]
        fconst[FACT_CONSTRUCTION]
    end

    subgraph Calc
        cexpp[CALC_EXP_PT_2024]
        cexp[CALC_EXP_2024]
        cexpw[CALC_EXP_WORLD]
        call[CALC_ALL_EXP_2024]
        cexp_prod[CALC_EXP_PROD_BY_PT]
        cimp_prod[CALC_IMP_PROD_BY_PT]
        cimppt[CALC_IMP_PT_2024]
        cimpcer[CALC_IMP_CER_2024]
        cimpa[CALC_IMP_2024]
    end

    dc --> fexppt
    dc --> fexp
    dc --> fimpt
    dc --> fimp
    dc --> fpib
    dc --> furban
    dc --> fconst
    dc --> cexpp
    dc --> cexp
    dc --> cexpw
    dc --> call
    dc --> cimppt
    dc --> cimpcer
    dc --> cimpa

    dp --> fexpprod
    dp --> fimpprod
    dp --> cexp_prod
    dp --> cimp_prod

    dd --> fexppt
    dd --> fexp
    dd --> fexpprod
    dd --> fexpsec
    dd --> fimp
    dd --> fimpt
    dd --> fimpprod
    dd --> fimpsec
    dd --> fpib
    dd --> furban
    dd --> fconst
```

## Notas
- Todas as FKs usam `ON DELETE NO ACTION` para impedir remoção acidental de dimensões.
- `FACT_IMP` é alimentada pelo ficheiro histórico
  `Trade_Map_-_List_of_importers_for_the_selected_product_(Ceramic_products)` (2005‑2024),
  enquanto `CALC_IMP_CER_2024` continua dependente do snapshot
  `Trade_Map_-_List_of_importers_for_the_selected_product_in_2024_(Ceramic_products)`.
- `CALC_IMP_2024` reutiliza o ficheiro “all products” para espelhar o lado importador com os mesmos
  campos das tabelas de exportação.
