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
Total Exports 2024 = 
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
RANKX(
    ALL('DIM_COUNTRY'[country_name]),
    [Total Exports 2024],
    ,
    DESC,
    Skip
)
```

