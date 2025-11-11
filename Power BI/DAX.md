# Measures

```dax
Default Country = 
IF (
    HASONEVALUE('DIM_COUNTRY'[country_name]),
    VALUES('DIM_COUNTRY'[country_name]),
    "World"
)
```

```dax
Industry Growth Last Year = 
IF (
    HASONEVALUE('DIM_COUNTRY'[id_country]),
    CALCULATE(
        MAX('CALC_EXP_2024'[growth_value_2023_2024_pct])
    ),
    CALCULATE(
        MAX('CALC_EXP_2024'[growth_value_2023_2024_pct]),
        'CALC_EXP_2024'[id_country] = 262
    )
)
```

```dax
Total Exports Ceramics 2024 = 
IF (
    HASONEVALUE('DIM_COUNTRY'[id_country]),
    SUM('CALC_EXP_2024'[value_2024_usd]),
    CALCULATE(
        SUM('CALC_EXP_2024'[value_2024_usd]),
        'CALC_EXP_2024'[id_country] = 262
    )
)
```

```dax
Country Rank by Exports = 
VAR CountryList =
    FILTER(
        ALLSELECTED('DIM_COUNTRY'[country_name]),
        'DIM_COUNTRY'[country_name] <> "World"
    )
VAR RankValue =
    RANKX(
        CountryList,
        [Total Exports 2024],
        ,
        DESC,
        SKIP
    )
RETURN
IF(
    SELECTEDVALUE('DIM_COUNTRY'[country_name]) = "World",
    BLANK(),
    RankValue
)
```

```dax
Total Exports World 2024 = 
IF (
    HASONEVALUE('DIM_COUNTRY'[id_country]),
    SUM('CALC_EXP_WORLD'[value_2024_usd]),
    CALCULATE(
        SUM('CALC_EXP_WORLD'[value_2024_usd]),
        'CALC_EXP_WORLD'[id_country] = 262
    )
)
```

```dax
Ceramics Share in Exports (%) = 
VAR CountryID = SELECTEDVALUE ( 'DIM_COUNTRY'[id_country] )
VAR CeramicsExports =
    CALCULATE (
        [Total Exports Ceramics 2024],
        'CALC_EXP_WORLD'[id_country] = CountryID
    )
VAR CountryExports =
    CALCULATE (
        [Total Exports World 2024],
        'CALC_EXP_WORLD'[id_country] = CountryID
    )
RETURN
DIVIDE ( CeramicsExports, CountryExports, 0 )
```

```dax
Share in Ceramics Exports (%) = 
DIVIDE(
    [Total Exports Ceramics 2024],
    CALCULATE([Total Exports Ceramics 2024], ALL('DIM_COUNTRY')),
    0
)
```

