USE [CeramicsWorldDB];
GO

SET NOCOUNT ON;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DIM_PAIS' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.DIM_PAIS (
        ID_Pais     INT IDENTITY(1,1) PRIMARY KEY,
        Nome_Pais   VARCHAR(100) NOT NULL,
        Continente  VARCHAR(50) NULL,
        Regiao      VARCHAR(100) NULL,
        Codigo_ISO  CHAR(3) NOT NULL,
        CONSTRAINT UQ_DIM_PAIS_Nome UNIQUE (Nome_Pais),
        CONSTRAINT UQ_DIM_PAIS_ISO UNIQUE (Codigo_ISO)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DIM_PRODUTO' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.DIM_PRODUTO (
        ID_Produto        INT IDENTITY(1,1) PRIMARY KEY,
        Codigo_HS         VARCHAR(20) NOT NULL,
        Descricao_Produto VARCHAR(255) NULL,
        Grupo_Produto     VARCHAR(100) NULL
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'DIM_DATA' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.DIM_DATA (
        ID_Data      INT IDENTITY(1,1) PRIMARY KEY,
        Ano          INT NOT NULL,
        Trimestre    CHAR(2) NULL,
        Mes          INT NULL,
        Decada       VARCHAR(10) NULL,
        Period_Label VARCHAR(12) NULL
    );
END;
GO

/* ---------------------------------------------------------------------------
   Ensure fact tables are empty (prevents FK violations during dimension reload)
--------------------------------------------------------------------------- */
IF OBJECT_ID('dbo.FACT_EXPORTACAO', 'U') IS NOT NULL
    TRUNCATE TABLE dbo.FACT_EXPORTACAO;
IF OBJECT_ID('dbo.FACT_IMPORTACAO', 'U') IS NOT NULL
    TRUNCATE TABLE dbo.FACT_IMPORTACAO;
IF OBJECT_ID('dbo.FACT_SERVICO_CONSTRUCAO', 'U') IS NOT NULL
    TRUNCATE TABLE dbo.FACT_SERVICO_CONSTRUCAO;
IF OBJECT_ID('dbo.FACT_PIB_PER_CAPITA', 'U') IS NOT NULL
    TRUNCATE TABLE dbo.FACT_PIB_PER_CAPITA;
IF OBJECT_ID('dbo.FACT_POPULACAO_URBANA', 'U') IS NOT NULL
    TRUNCATE TABLE dbo.FACT_POPULACAO_URBANA;

TRUNCATE TABLE dbo.DIM_PAIS;
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'DIM_PAIS'
      AND COLUMN_NAME = 'Codigo_ISO'
      AND IS_NULLABLE = 'YES'
)
BEGIN
    ALTER TABLE dbo.DIM_PAIS ALTER COLUMN Codigo_ISO CHAR(3) NOT NULL;
END;
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UQ_DIM_PAIS_Nome'
      AND object_id = OBJECT_ID('dbo.DIM_PAIS')
)
BEGIN
    ALTER TABLE dbo.DIM_PAIS ADD CONSTRAINT UQ_DIM_PAIS_Nome UNIQUE (Nome_Pais);
END;
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = 'UQ_DIM_PAIS_ISO'
      AND object_id = OBJECT_ID('dbo.DIM_PAIS')
)
BEGIN
    ALTER TABLE dbo.DIM_PAIS ADD CONSTRAINT UQ_DIM_PAIS_ISO UNIQUE (Codigo_ISO);
END;

WITH unioned AS (
    SELECT CountryName, Continent, Region, ISO3
    FROM staging.vw_exports_country_timeseries
    UNION
    SELECT CountryName, Continent, Region, ISO3
    FROM staging.vw_imports_country_timeseries
    UNION
    SELECT CountryName, NULL AS Continent, NULL AS Region, CountryCode AS ISO3
    FROM staging.vw_gdp_per_capita_timeseries
    UNION
    SELECT CountryName, NULL, NULL, CountryCode
    FROM staging.vw_urban_population_timeseries
),
ranked AS (
    SELECT
        ISO3,
        CountryName,
        Continent,
        Region,
        ROW_NUMBER() OVER (
            PARTITION BY ISO3
            ORDER BY
                CASE WHEN Continent IS NOT NULL THEN 0 ELSE 1 END,
                CountryName
        ) AS rn
    FROM unioned
    WHERE ISO3 IS NOT NULL
),
ai_lookup AS (
    SELECT
        UPPER(Codigo_ISO) AS ISO3,
        Continente,
        Regiao
    FROM staging.ref_country_lookup
    UNION ALL
    SELECT *
    FROM (VALUES
        ('USA','North America','Northern America'),
        ('CAN','North America','Northern America'),
        ('MEX','North America','Northern America'),
        ('BRA','South America','South America'),
        ('ARG','South America','South America'),
        ('COL','South America','South America'),
        ('PER','South America','South America'),
        ('CHL','South America','South America'),
        ('URY','South America','South America'),
        ('DEU','Europe','Western Europe'),
        ('FRA','Europe','Western Europe'),
        ('ESP','Europe','Southern Europe'),
        ('PRT','Europe','Southern Europe'),
        ('ITA','Europe','Southern Europe'),
        ('GBR','Europe','Northern Europe'),
        ('IRL','Europe','Northern Europe'),
        ('NLD','Europe','Western Europe'),
        ('BEL','Europe','Western Europe'),
        ('LUX','Europe','Western Europe'),
        ('CHE','Europe','Western Europe'),
        ('AUT','Europe','Western Europe'),
        ('DNK','Europe','Northern Europe'),
        ('SWE','Europe','Northern Europe'),
        ('NOR','Europe','Northern Europe'),
        ('FIN','Europe','Northern Europe'),
        ('POL','Europe','Eastern Europe'),
        ('CZE','Europe','Eastern Europe'),
        ('SVK','Europe','Eastern Europe'),
        ('HUN','Europe','Eastern Europe'),
        ('ROU','Europe','Eastern Europe'),
        ('BGR','Europe','Eastern Europe'),
        ('GRC','Europe','Southern Europe'),
        ('TUR','Asia','Western Asia'),
        ('SAU','Asia','Western Asia'),
        ('ARE','Asia','Western Asia'),
        ('QAT','Asia','Western Asia'),
        ('EGY','Africa','Northern Africa'),
        ('ZAF','Africa','Southern Africa'),
        ('NGA','Africa','Western Africa'),
        ('GHA','Africa','Western Africa'),
        ('KEN','Africa','Eastern Africa'),
        ('ETH','Africa','Eastern Africa'),
        ('MAR','Africa','Northern Africa'),
        ('DZA','Africa','Northern Africa'),
        ('CHN','Asia','Eastern Asia'),
        ('JPN','Asia','Eastern Asia'),
        ('KOR','Asia','Eastern Asia'),
        ('SGP','Asia','South-Eastern Asia'),
        ('MYS','Asia','South-Eastern Asia'),
        ('THA','Asia','South-Eastern Asia'),
        ('VNM','Asia','South-Eastern Asia'),
        ('PHL','Asia','South-Eastern Asia'),
        ('IDN','Asia','South-Eastern Asia'),
        ('IND','Asia','Southern Asia'),
        ('PAK','Asia','Southern Asia'),
        ('BGD','Asia','Southern Asia'),
        ('AUS','Oceania','Australia and New Zealand'),
        ('NZL','Oceania','Australia and New Zealand'),
        ('RUS','Europe','Eastern Europe'),
        ('UKR','Europe','Eastern Europe'),
        ('USA','North America','Northern America'),
        ('MYS','Asia','South-Eastern Asia'),
        ('PAN','North America','Central America'),
        ('CRI','North America','Central America'),
        ('GTM','North America','Central America'),
        ('SLV','North America','Central America'),
        ('HND','North America','Central America'),
        ('DOM','North America','Caribbean'),
        ('CUB','North America','Caribbean'),
        ('JAM','North America','Caribbean'),
        ('KWT','Asia','Western Asia'),
        ('OMN','Asia','Western Asia'),
        ('ISR','Asia','Western Asia'),
        ('IRN','Asia','Southern Asia'),
        ('QAT','Asia','Western Asia'),
        ('LBN','Asia','Western Asia'),
        ('JOR','Asia','Western Asia'),
        ('KAZ','Asia','Central Asia'),
        ('UZB','Asia','Central Asia'),
        ('TZA','Africa','Eastern Africa'),
        ('AGO','Africa','Middle Africa'),
        ('CMR','Africa','Middle Africa'),
        ('MOZ','Africa','Eastern Africa'),
        ('BOL','South America','South America'),
        ('PAR','South America','South America')
    ) AS data(ISO3, Continente, Regiao)
)
INSERT INTO dbo.DIM_PAIS (Nome_Pais, Continente, Regiao, Codigo_ISO)
SELECT
    COALESCE(r.CountryName, CONCAT('ISO-', r.ISO3)) AS Nome_Pais,
    COALESCE(r.Continent, ai.Continente, 'Unknown') AS Continente,
    COALESCE(r.Region, ai.Regiao, 'Unknown') AS Regiao,
    r.ISO3
FROM ranked AS r
OUTER APPLY (
    SELECT Continente, Regiao
    FROM ai_lookup
    WHERE ISO3 = r.ISO3
) AS ai
WHERE r.rn = 1;
GO

TRUNCATE TABLE dbo.DIM_PRODUTO;
IF EXISTS (
    SELECT 1
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'dbo'
      AND TABLE_NAME = 'DIM_PRODUTO'
      AND COLUMN_NAME = 'Codigo_HS'
      AND CHARACTER_MAXIMUM_LENGTH < 20
)
BEGIN
    ALTER TABLE dbo.DIM_PRODUTO ALTER COLUMN Codigo_HS VARCHAR(20) NOT NULL;
END;

INSERT INTO dbo.DIM_PRODUTO (Codigo_HS, Descricao_Produto, Grupo_Produto)
SELECT DISTINCT Codigo_HS, Descricao_Produto, Grupo_Produto
FROM (
    SELECT HSCode AS Codigo_HS, ProductLabel AS Descricao_Produto, ProductGroup AS Grupo_Produto
    FROM staging.vw_exports_products_timeseries
    UNION
    SELECT HSCode, ProductLabel, ProductGroup
    FROM staging.vw_imports_products_timeseries
    UNION ALL
    SELECT 'CERAMICS_ALL', 'All ceramic products', 'Aggregate'
) v
WHERE Codigo_HS IS NOT NULL;
GO

TRUNCATE TABLE dbo.DIM_DATA;

WITH all_years AS (
    SELECT DISTINCT Ano FROM staging.vw_exports_country_timeseries
    UNION SELECT DISTINCT Ano FROM staging.vw_imports_country_timeseries
    UNION SELECT DISTINCT Ano FROM staging.vw_exports_products_timeseries
    UNION SELECT DISTINCT Ano FROM staging.vw_imports_products_timeseries
    UNION SELECT DISTINCT Ano FROM staging.vw_gdp_per_capita_timeseries
    UNION SELECT DISTINCT Ano FROM staging.vw_urban_population_timeseries
    UNION SELECT DISTINCT Ano FROM staging.vw_exports_services_quarterly
UNION SELECT DISTINCT Ano FROM staging.vw_imports_services_quarterly
),
months AS (
    SELECT v.Mes
    FROM (VALUES
        (1),(2),(3),(4),(5),(6),(7),(8),(9),(10),(11),(12)
    ) v(Mes)
)
INSERT INTO dbo.DIM_DATA (Ano, Trimestre, Mes, Decada, Period_Label)
SELECT
    y.Ano,
    CONCAT('Q', ((m.Mes - 1) / 3) + 1) AS Trimestre,
    m.Mes,
    CONCAT((y.Ano / 10) * 10, 's') AS Decada,
    CONCAT(
        y.Ano, '_',
        'Q', ((m.Mes - 1) / 3) + 1, '_',
        RIGHT('00' + CAST(m.Mes AS VARCHAR(2)), 2)
    ) AS Period_Label
FROM all_years y
CROSS JOIN months m
ORDER BY y.Ano, m.Mes;
GO
