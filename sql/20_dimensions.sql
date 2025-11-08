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
        Codigo_ISO  CHAR(3) NULL
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
ELSE
BEGIN
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

TRUNCATE TABLE dbo.DIM_PAIS;
INSERT INTO dbo.DIM_PAIS (Nome_Pais, Continente, Regiao, Codigo_ISO)
SELECT DISTINCT
    COALESCE(v.CountryName, 'Unknown'),
    v.Continent,
    v.Region,
    v.ISO3
FROM (
    SELECT CountryName, Continent, Region, ISO3 FROM staging.vw_exports_country_timeseries
    UNION
    SELECT CountryName, Continent, Region, ISO3 FROM staging.vw_imports_country_timeseries
    UNION
    SELECT CountryName, NULL, NULL, CountryCode FROM staging.vw_gdp_per_capita_timeseries
    UNION
    SELECT CountryName, NULL, NULL, CountryCode FROM staging.vw_urban_population_timeseries
) v;
GO

TRUNCATE TABLE dbo.DIM_PRODUTO;
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
WITH calendar AS (
    SELECT DISTINCT
        Ano,
        NULL AS Trimestre
    FROM (
        SELECT Ano FROM staging.vw_exports_country_timeseries
        UNION SELECT Ano FROM staging.vw_imports_country_timeseries
        UNION SELECT Ano FROM staging.vw_exports_products_timeseries
        UNION SELECT Ano FROM staging.vw_imports_products_timeseries
        UNION SELECT Ano FROM staging.vw_gdp_per_capita_timeseries
        UNION SELECT Ano FROM staging.vw_urban_population_timeseries
        UNION SELECT Ano FROM staging.vw_exports_services_quarterly
        UNION SELECT Ano FROM staging.vw_imports_services_quarterly
    ) q
)
INSERT INTO dbo.DIM_DATA (Ano, Trimestre, Mes, Decada, Period_Label)
SELECT
    Ano,
    CASE WHEN q.Quarters = '' THEN NULL ELSE q.Quarters END,
    NULL,
    CONCAT((Ano / 10) * 10, 's'),
    CASE WHEN q.Quarters = '' OR q.Quarters IS NULL THEN CAST(Ano AS VARCHAR(4))
         ELSE CONCAT(Ano, '_', q.Quarters)
    END
FROM (
    SELECT Ano, '' AS Quarters FROM calendar
    UNION
    SELECT Ano, Trimestre FROM staging.vw_exports_services_quarterly
    UNION
    SELECT Ano, Trimestre FROM staging.vw_imports_services_quarterly
) q
ORDER BY Ano, q.Quarters;
GO
