# Relational Model – Ceramics World

Relationship map implemented after the ETL normalisation. Three compact dimensions (Country, Product, Date) let us connect any trade or macro metric.

## Key Relationships
| Source | Target | Type | Description |
| --- | --- | --- | --- |
| `DIM_COUNTRY` | `FACT_EXP_PT`, `FACT_EXP`, `FACT_IMP`, `FACT_IMP_PT`, `FACT_IMP_SEGMENT`, `FACT_PIB`, `FACT_URBAN`, `FACT_CONSTRUCTION` | 1:N | Historical series by country. |
| `DIM_COUNTRY` | `CALC_EXP_PT_2024`, `CALC_EXP_2024`, `CALC_EXP_WORLD`, `CALC_ALL_EXP_2024`, `CALC_IMP_2024`, `CALC_IMP_PT_2024`, `CALC_IMP_CER_2024` | 1:N | 2024 KPIs by country. |
| `DIM_PRODUCT` | `FACT_EXP_PROD_BY_PT`, `FACT_IMP_PROD`, `FACT_IMP_SEGMENT`, `CALC_EXP_PROD_BY_PT`, `CALC_IMP_PROD_BY_PT` | 1:N | Series and KPIs by HS code. |
| `DIM_DATE` | All `FACT_*` tables (snapshots excluded) | 1:N | Annual/quarterly temporal reference. |
| `DIM_DATE` | `FACT_EXP_SECTOR_BY_PT`, `FACT_IMP_SECTOR` | 1:N | Quarterly service series. |

## Diagram
```mermaid
graph LR
    subgraph Dimensions
        dc[DIM_COUNTRY]
        dp[DIM_PRODUCT]
        dd[DIM_DATE]
    end

    subgraph Trade Facts
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

    subgraph Macro Facts
        fpib[FACT_PIB]
        furban[FACT_URBAN]
        fconst[FACT_CONSTRUCTION]
    end

    subgraph Calc Tables
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

## Operational Notes
1. **Strict referential integrity**: every FK uses `ON DELETE NO ACTION`. Scripts `sql/20_dimensions.sql` and `sql/30_facts.sql` enforce the drop order before recreating objects.
2. **Trade Map files**: historic datasets feed fact tables (`FACT_IMP`, `FACT_EXP`, etc.) while the “in 2024” files populate `CALC_*` snapshots.
3. **HS segmentation**: the three dedicated files (6907, 6908, 6910) unlock `country × product` analysis without hurting performance.
4. **Macro indicators**: aligned by `id_country` and `id_date`, enabling direct correlation with trade metrics in Power BI.
