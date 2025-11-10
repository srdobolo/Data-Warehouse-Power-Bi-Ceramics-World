# Structure

DIM_DATE(id_date, year, quarter, decade)

DIM_COUNTRY(id_country, country_name, country_code)

DIM_PRODUCT(id_product, code, product_label)

FACT_EXP_PT(id_exp_pt, id_country, id_date, value)

CALC_EXP_PT_2024(id_country,trade_balance_2024, Share in Portugal's exports (%), Growth in exported value between 2020-2024 (%, p.a.), Growth in exported value between 2023-2024 (%, p.a.), Ranking of partner countries in world imports, Share of partner countries in world imports (%), Total imports growth in value of partner countries between 2020-2024 (%, p.a.), Average distance between partner countries and all their supplying markets (km), Concentration of all supplying countries of partner countries, Average tariff (estimated) faced by Portugal (%))

FACT_EXP(id_exp, id_country, id_date, value)

CALC_EXP_2024(id_country,trade_balance_2024, Growth in exported value between 2020-2024 (%, p.a.), Growth in exported value between 2023-2024 (%, p.a.), Share in world exports (%), Average distance of importing countries (km), Concentration of importing countries)

CALC_EXP_WORLD(id_country,value_2024_usd,trade_balance_2024_usd,Growth in exported value between 2020-2024 (%, p.a.),Growth in exported value between 2023-2024 (%, p.a.),Share in world exports (%),Average distance of importing countries (km),Concentration of importing countries)

CALC_IMP_2024(id_country,value_2024_usd,trade_balance_2024_usd,Growth in traded value between 2020-2024 (%, p.a.),Growth in traded value between 2023-2024 (%, p.a.),Share in world imports (%),Average distance of trading partners (km),Concentration of trading partners)

FACT_EXP_PROD_BY_PT(id_exp_prod_pt, id_product, id_date, value )

CALC_EXP_PROD_BY_PT(id_product, Trade balance 2024 (USD thousand), Annual growth in value between 2020-2024 (%, p.a.), Annual growth in quantity between 2020-2024 (%, p.a.), Annual growth in value between 2023-2024 (%, p.a.), Annual growth of world imports between 2020-2024 (%, p.a.), Share in world exports (%), Ranking in world exports, Average distance of importing countries (km), Concentration of importing countries)

FACT_EXP_SECTOR_BY_PT(id_exp_sector,id_date, value)

FACT_IMP_PT(id_imp_pt, id_country, id_date, value)

CALC_IMP_PT_2024(id_country,trade_balance_2024, Annual growth in value between 2020-2024 (%, p.a.), Annual growth in value between 2023-2024 (%, p.a.), Share in world imports (%), Average distance of supplying countries (km), Concentration of supplying countries, Average tariff (estimated) applied by the country (%))

CALC_IMP_CER_2024(id_country,trade_balance_2024, Annual growth in value between 2020-2024 (%, p.a.), Annual growth in value between 2023-2024 (%, p.a.), Share in world imports (%), Average distance of supplying countries (km), Concentration of supplying countries, Average tariff (estimated) applied by the country (%))

FACT_IMP_PROD_BY_PT(id_imp_prod_pt, id_product, id_date, value )

CALC_IMP_PROD_BY_PT(id_product, Trade balance 2024 (USD thousand), Annual growth in value between 2020-2024 (%, p.a.), Annual growth in quantity between 2020-2024 (%, p.a.), Annual growth in value between 2023-2024 (%, p.a.), Annual growth of world exports between 2020-2024 (%, p.a.), Average distance of supplying countries (km), Concentration of supplying countries)

FACT_IMP_SECTOR(id_imp_sector,id_date, value)

FACT_PIB(id_pib, id_country, id_date, gdp_per_capita_usd)

FACT_URBAN(id_urban, id_country, id_date, urban_population_total)

FACT_IMP(id_imp, id_country, id_date, value)

FACT_CONSTRUCTION(id_construction, id_country, id_date, value_added_growth_pct)
