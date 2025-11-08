USE [CeramicsWorldDB];
GO

SET NOCOUNT ON;

/* ---------------------------------------------------------------------------
   Ensure fact tables exist
--------------------------------------------------------------------------- */
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FACT_EXPORTACAO' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.FACT_EXPORTACAO (
        ID_Exp           INT IDENTITY(1,1) PRIMARY KEY,
        ID_Pais          INT NOT NULL,
        ID_Produto       INT NOT NULL,
        ID_Data          INT NOT NULL,
        Valor_Exportado  DECIMAL(18, 2) NULL,
        Unidade          VARCHAR(20) NULL,
        Ano              INT NULL,
        CONSTRAINT FK_FactExportacao_Pais FOREIGN KEY (ID_Pais) REFERENCES dbo.DIM_PAIS(ID_Pais),
        CONSTRAINT FK_FactExportacao_Produto FOREIGN KEY (ID_Produto) REFERENCES dbo.DIM_PRODUTO(ID_Produto),
        CONSTRAINT FK_FactExportacao_Data FOREIGN KEY (ID_Data) REFERENCES dbo.DIM_DATA(ID_Data)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FACT_IMPORTACAO' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.FACT_IMPORTACAO (
        ID_Imp           INT IDENTITY(1,1) PRIMARY KEY,
        ID_Pais          INT NOT NULL,
        ID_Produto       INT NOT NULL,
        ID_Data          INT NOT NULL,
        Valor_Importado  DECIMAL(18, 2) NULL,
        Unidade          VARCHAR(20) NULL,
        Ano              INT NULL,
        CONSTRAINT FK_FactImportacao_Pais FOREIGN KEY (ID_Pais) REFERENCES dbo.DIM_PAIS(ID_Pais),
        CONSTRAINT FK_FactImportacao_Produto FOREIGN KEY (ID_Produto) REFERENCES dbo.DIM_PRODUTO(ID_Produto),
        CONSTRAINT FK_FactImportacao_Data FOREIGN KEY (ID_Data) REFERENCES dbo.DIM_DATA(ID_Data)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FACT_SERVICO_CONSTRUCAO' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.FACT_SERVICO_CONSTRUCAO (
        ID_Servico       INT IDENTITY(1,1) PRIMARY KEY,
        ID_Pais          INT NOT NULL,
        ID_Data          INT NOT NULL,
        Tipo_Servico     VARCHAR(100) NULL,
        Valor_Exportado  DECIMAL(18, 2) NULL,
        Unidade          VARCHAR(20) NULL,
        Ano              INT NULL,
        CONSTRAINT FK_FactServico_Pais FOREIGN KEY (ID_Pais) REFERENCES dbo.DIM_PAIS(ID_Pais),
        CONSTRAINT FK_FactServico_Data FOREIGN KEY (ID_Data) REFERENCES dbo.DIM_DATA(ID_Data)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FACT_PIB_PER_CAPITA' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.FACT_PIB_PER_CAPITA (
        ID_PIB     INT IDENTITY(1,1) PRIMARY KEY,
        ID_Pais    INT NOT NULL,
        ID_Data    INT NOT NULL,
        PIB_Valor  DECIMAL(18, 2) NULL,
        Ano        INT NULL,
        CONSTRAINT FK_FactPIB_Pais FOREIGN KEY (ID_Pais) REFERENCES dbo.DIM_PAIS(ID_Pais),
        CONSTRAINT FK_FactPIB_Data FOREIGN KEY (ID_Data) REFERENCES dbo.DIM_DATA(ID_Data)
    );
END;

IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'FACT_POPULACAO_URBANA' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE dbo.FACT_POPULACAO_URBANA (
        ID_Urbano         INT IDENTITY(1,1) PRIMARY KEY,
        ID_Pais           INT NOT NULL,
        ID_Data           INT NOT NULL,
        Total_Populacao   DECIMAL(18, 2) NULL,
        Ano               INT NULL,
        CONSTRAINT FK_FactPopUrb_Pais FOREIGN KEY (ID_Pais) REFERENCES dbo.DIM_PAIS(ID_Pais),
        CONSTRAINT FK_FactPopUrb_Data FOREIGN KEY (ID_Data) REFERENCES dbo.DIM_DATA(ID_Data)
    );
END;
GO

/* ---------------------------------------------------------------------------
   FACT_EXPORTACAO
--------------------------------------------------------------------------- */
TRUNCATE TABLE dbo.FACT_EXPORTACAO;

WITH base AS (
    SELECT CountryName, ISO3, Ano, Valor_USD
    FROM staging.vw_exports_country_timeseries
    WHERE Valor_USD IS NOT NULL
),
dim_prod AS (
    SELECT ID_Produto
    FROM dbo.DIM_PRODUTO
    WHERE Codigo_HS = 'CERAMICS_ALL'
),
dim_pais AS (
    SELECT Codigo_ISO, Nome_Pais, ID_Pais
    FROM dbo.DIM_PAIS
)
INSERT INTO dbo.FACT_EXPORTACAO (ID_Pais, ID_Produto, ID_Data, Valor_Exportado, Unidade, Ano)
SELECT
    COALESCE(p_iso.ID_Pais, p_name.ID_Pais)      AS ID_Pais,
    prod.ID_Produto,
    d.ID_Data,
    base.Valor_USD,
    'USD' AS Unidade,
    base.Ano
FROM base
CROSS JOIN dim_prod AS prod
LEFT JOIN dim_pais AS p_iso
    ON p_iso.Codigo_ISO = base.ISO3
LEFT JOIN dim_pais AS p_name
    ON p_name.Codigo_ISO IS NULL
   AND p_name.Nome_Pais = base.CountryName
JOIN dbo.DIM_DATA AS d
    ON d.Ano = base.Ano
   AND d.Trimestre = 'Q4'
   AND d.Mes = 12
WHERE COALESCE(p_iso.ID_Pais, p_name.ID_Pais) IS NOT NULL;
GO

/* ---------------------------------------------------------------------------
   FACT_IMPORTACAO
--------------------------------------------------------------------------- */
TRUNCATE TABLE dbo.FACT_IMPORTACAO;

WITH base AS (
    SELECT CountryName, ISO3, Ano, Valor_USD
    FROM staging.vw_imports_country_timeseries
    WHERE Valor_USD IS NOT NULL
),
dim_prod AS (
    SELECT ID_Produto
    FROM dbo.DIM_PRODUTO
    WHERE Codigo_HS = 'CERAMICS_ALL'
),
dim_pais AS (
    SELECT Codigo_ISO, Nome_Pais, ID_Pais
    FROM dbo.DIM_PAIS
)
INSERT INTO dbo.FACT_IMPORTACAO (ID_Pais, ID_Produto, ID_Data, Valor_Importado, Unidade, Ano)
SELECT
    COALESCE(p_iso.ID_Pais, p_name.ID_Pais)      AS ID_Pais,
    prod.ID_Produto,
    d.ID_Data,
    base.Valor_USD,
    'USD' AS Unidade,
    base.Ano
FROM base
CROSS JOIN dim_prod AS prod
LEFT JOIN dim_pais AS p_iso
    ON p_iso.Codigo_ISO = base.ISO3
LEFT JOIN dim_pais AS p_name
    ON p_name.Codigo_ISO IS NULL
   AND p_name.Nome_Pais = base.CountryName
JOIN dbo.DIM_DATA AS d
    ON d.Ano = base.Ano
   AND d.Trimestre = 'Q4'
   AND d.Mes = 12
WHERE COALESCE(p_iso.ID_Pais, p_name.ID_Pais) IS NOT NULL;
GO

/* ---------------------------------------------------------------------------
   FACT_SERVICO_CONSTRUCAO
--------------------------------------------------------------------------- */
TRUNCATE TABLE dbo.FACT_SERVICO_CONSTRUCAO;

DECLARE @PortugalID INT = (
    SELECT TOP 1 ID_Pais FROM dbo.DIM_PAIS WHERE Codigo_ISO = 'PRT' OR Nome_Pais = 'Portugal'
);

INSERT INTO dbo.FACT_SERVICO_CONSTRUCAO (ID_Pais, ID_Data, Tipo_Servico, Valor_Exportado, Unidade, Ano)
SELECT
    @PortugalID,
    d.ID_Data,
    svc.ServiceLabel,
    svc.Valor_USD,
    'USD',
    svc.Ano
FROM staging.vw_exports_services_quarterly AS svc
JOIN dbo.DIM_DATA AS d
    ON d.Ano = svc.Ano
   AND d.Trimestre = svc.Trimestre
   AND d.Mes = CASE svc.Trimestre WHEN 'Q1' THEN 3 WHEN 'Q2' THEN 6 WHEN 'Q3' THEN 9 WHEN 'Q4' THEN 12 END
WHERE svc.Valor_USD IS NOT NULL
  AND @PortugalID IS NOT NULL;
GO

/* ---------------------------------------------------------------------------
   FACT_PIB_PER_CAPITA
--------------------------------------------------------------------------- */
TRUNCATE TABLE dbo.FACT_PIB_PER_CAPITA;

INSERT INTO dbo.FACT_PIB_PER_CAPITA (ID_Pais, ID_Data, PIB_Valor, Ano)
SELECT
    pais.ID_Pais,
    data.ID_Data,
    gdp.Valor_USD,
    gdp.Ano
FROM staging.vw_gdp_per_capita_timeseries AS gdp
JOIN dbo.DIM_PAIS AS pais
    ON pais.Codigo_ISO = gdp.CountryCode
JOIN dbo.DIM_DATA AS data
    ON data.Ano = gdp.Ano
   AND data.Trimestre = 'Q4'
   AND data.Mes = 12
WHERE gdp.Valor_USD IS NOT NULL;
GO

/* ---------------------------------------------------------------------------
   FACT_POPULACAO_URBANA
--------------------------------------------------------------------------- */
TRUNCATE TABLE dbo.FACT_POPULACAO_URBANA;

INSERT INTO dbo.FACT_POPULACAO_URBANA (ID_Pais, ID_Data, Total_Populacao, Ano)
SELECT
    pais.ID_Pais,
    data.ID_Data,
    urb.Total_Populacao,
    urb.Ano
FROM staging.vw_urban_population_timeseries AS urb
JOIN dbo.DIM_PAIS AS pais
    ON pais.Codigo_ISO = urb.CountryCode
JOIN dbo.DIM_DATA AS data
    ON data.Ano = urb.Ano
   AND data.Trimestre = 'Q4'
   AND data.Mes = 12
WHERE urb.Total_Populacao IS NOT NULL;
GO
