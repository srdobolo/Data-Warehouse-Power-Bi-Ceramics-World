# Modelo Relacional – Ceramics World

Mapa de relacionamento implementado após a normalização aplicada pelo ETL. A combinação de três dimensões compactas (País, Produto, Data) permite ligar qualquer métrica de comércio ou macroeconomia.

## Principais Relacionamentos
| Origem | Destino | Tipo | Descrição |
| --- | --- | --- | --- |
| `DIM_COUNTRY` | `FACT_EXP_PT`, `FACT_EXP`, `FACT_IMP`, `FACT_IMP_PT`, `FACT_IMP_SEGMENT`, `FACT_PIB`, `FACT_URBAN`, `FACT_CONSTRUCTION` | 1:N | Séries históricas por país. |
| `DIM_COUNTRY` | `CALC_EXP_PT_2024`, `CALC_EXP_2024`, `CALC_EXP_WORLD`, `CALC_ALL_EXP_2024`, `CALC_IMP_2024`, `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024` | 1:N | KPIs 2024 por país. |
| `DIM_PRODUCT` | `FACT_EXP_PROD_BY_PT`, `FACT_IMP_PROD`, `FACT_IMP_SEGMENT`, `CALC_EXP_PROD_BY_PT`, `CALC_IMP_PROD_BY_PT` | 1:N | Séries e KPIs por HS code. |
| `DIM_DATE` | Todas as `FACT_*` (exceto snapshots) | 1:N | Referência temporal anual/trimestral. |
| `DIM_DATE` | `FACT_EXP_SECTOR_BY_PT`, `FACT_IMP_SECTOR` | 1:N | Séries trimestrais agregadas. |

## Diagrama
```mermaid
graph LR
    subgraph Dimensões
        dc[DIM_COUNTRY]
        dp[DIM_PRODUCT]
        dd[DIM_DATE]
    end

    subgraph Fatos de Comércio
        fexppt[FACT_EXP_PT]
        fexp[FACT_EXP]
        fimp[FACT_IMP]
        fimpt[FACT_IMP_PT]
        fexpprod[FACT_EXP_PROD_BY_PT]
        fimpprod[FACT_IMP_PROD]
        fseg[FACT_IMP_SEGMENT]
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
        cimp[CALC_IMP_2024]
        cimppt[CALC_IMP_PT_2024]
        cimpcer[CALC_IMP_CER_2024]
        cexpprod[CALC_EXP_PROD_BY_PT]
        cimpprod[CALC_IMP_PROD_BY_PT]
    end

    dc --> fexppt
    dc --> fexp
    dc --> fimp
    dc --> fimpt
    dc --> fseg
    dc --> fpib
    dc --> furban
    dc --> fconst
    dc --> cexpp
    dc --> cexp
    dc --> cexpw
    dc --> call
    dc --> cimp
    dc --> cimppt
    dc --> cimpcer

    dp --> fexpprod
    dp --> fimpprod
    dp --> fseg
    dp --> cexpprod
    dp --> cimpprod

    dd --> fexppt
    dd --> fexp
    dd --> fexpprod
    dd --> fexpsec
    dd --> fimp
    dd --> fimpt
    dd --> fimpprod
    dd --> fseg
    dd --> fimpsec
    dd --> fpib
    dd --> furban
    dd --> fconst
```

## Notas Operacionais
1. **Integridade referencial rígida**: FKs com `ON DELETE NO ACTION`. Scripts `sql/20_dimensions.sql` e `sql/30_facts.sql` cuidam do drop ordenado antes de recriar estruturas.
2. **Ficheiros Trade Map**: versões históricas alimentam factos (`FACT_IMP`, `FACT_EXP`, etc.), enquanto ficheiros “in 2024” alimentam as tabelas `CALC_*`.
3. **Segmentação HS**: três ficheiros específicos (6907, 6908, 6910) permitem análises cruzadas `país x produto` sem sacrificar performance.
4. **Macro indicators**: alinhados por `id_country` e `id_date` para permitir análises de correlação direta com as métricas de comércio no Power BI.
