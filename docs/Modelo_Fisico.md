# Modelo Físico – Data Warehouse Power BI Ceramics World

## Especificações Técnicas

- SGBD: SQL Server.
- Padrão de nomenclatura:
    - DIM_ → tabelas dimensionais
    - FACT_ → tabelas fato
- Tipos de dados escolhidos:
    - INT para identificadores e anos
    - VARCHAR para texto variável
    - FLOAT para valores numéricos contínuos
    - CHAR(3) para códigos ISO
- Codificação recomendada: UTF-8
- Primary Key (PK) sempre not null
- Foreign Keys (FK) com integridade referencial

## Tabela DIM_PAIS

```sql
CREATE TABLE DIM_PAIS (
    ID_Pais INT PRIMARY KEY IDENTITY(1,1),
    Nome_Pais VARCHAR(100) NOT NULL,
    Continente VARCHAR(50),
    Regiao VARCHAR(100),
    Codigo_ISO CHAR(3)
);
```

## Tabela DIM_PRODUTO

```sql
CREATE TABLE DIM_PRODUTO (
    ID_Produto INT PRIMARY KEY IDENTITY(1,1),
    Codigo_HS VARCHAR(10) NOT NULL,
    Descricao_Produto VARCHAR(255)
);
```

## Tabela DIM_DATA

```sql
CREATE TABLE DIM_DATA (
    ID_Data INT PRIMARY KEY IDENTITY(1,1),
    Ano INT NOT NULL,
    Trimestre CHAR(2),
    Decada VARCHAR(10),
    Period_Label VARCHAR(10)
);
```

## Tabela FACT_EXPORTACAO

```sql
CREATE TABLE FACT_EXPORTACAO (
    ID_Exp INT PRIMARY KEY IDENTITY(1,1),
    ID_Pais INT NOT NULL,
    ID_Produto INT NOT NULL,
    ID_Data INT NOT NULL,
    Valor_Exportado FLOAT,
    Unidade VARCHAR(20),
    Ano INT,
    CONSTRAINT FK_Exportacao_Pais FOREIGN KEY (ID_Pais) REFERENCES DIM_PAIS(ID_Pais),
    CONSTRAINT FK_Exportacao_Produto FOREIGN KEY (ID_Produto) REFERENCES DIM_PRODUTO(ID_Produto),
    CONSTRAINT FK_Exportacao_Data FOREIGN KEY (ID_Data) REFERENCES DIM_DATA(ID_Data)
);
```

## Tabela FACT_IMPORTACAO

```sql
CREATE TABLE FACT_IMPORTACAO (
    ID_Imp INT PRIMARY KEY IDENTITY(1,1),
    ID_Pais INT NOT NULL,
    ID_Produto INT NOT NULL,
    ID_Data INT NOT NULL,
    Valor_Importado FLOAT,
    Unidade VARCHAR(20),
    Ano INT,
    CONSTRAINT FK_Importacao_Pais FOREIGN KEY (ID_Pais) REFERENCES DIM_PAIS(ID_Pais),
    CONSTRAINT FK_Importacao_Produto FOREIGN KEY (ID_Produto) REFERENCES DIM_PRODUTO(ID_Produto),
    CONSTRAINT FK_Importacao_Data FOREIGN KEY (ID_Data) REFERENCES DIM_DATA(ID_Data)
);
```

## Tabela FACT_SERVICO_CONSTRUCAO

```sql
CREATE TABLE FACT_SERVICO_CONSTRUCAO (
    ID_Servico INT PRIMARY KEY IDENTITY(1,1),
    ID_Pais INT NOT NULL,
    ID_Data INT NOT NULL,
    Tipo_Servico VARCHAR(100),
    Valor_Exportado FLOAT,
    Unidade VARCHAR(20),
    Ano INT,
    CONSTRAINT FK_Servico_Pais FOREIGN KEY (ID_Pais) REFERENCES DIM_PAIS(ID_Pais),
    CONSTRAINT FK_Servico_Data FOREIGN KEY (ID_Data) REFERENCES DIM_DATA(ID_Data)
);
```

## Tabela FACT_PIB_PER_CAPITA

```sql
CREATE TABLE FACT_PIB_PER_CAPITA (
    ID_PIB INT PRIMARY KEY IDENTITY(1,1),
    ID_Pais INT NOT NULL,
    ID_Data INT NOT NULL,
    PIB_Valor FLOAT,
    Ano INT,
    CONSTRAINT FK_PIB_Pais FOREIGN KEY (ID_Pais) REFERENCES DIM_PAIS(ID_Pais),
    CONSTRAINT FK_PIB_Data FOREIGN KEY (ID_Data) REFERENCES DIM_DATA(ID_Data)
);
```

## Tabela FACT_POPULACAO_URBANA

```sql
CREATE TABLE FACT_POPULACAO_URBANA (
    ID_Urbano INT PRIMARY KEY IDENTITY(1,1),
    ID_Pais INT NOT NULL,
    ID_Data INT NOT NULL,
    Total_Populacao FLOAT,
    Ano INT,
    CONSTRAINT FK_PopUrb_Pais FOREIGN KEY (ID_Pais) REFERENCES DIM_PAIS(ID_Pais),
    CONSTRAINT FK_PopUrb_Data FOREIGN KEY (ID_Data) REFERENCES DIM_DATA(ID_Data)
);
```

## Resumo Estrutural

| Tipo     | Tabela                  | PK         | FKs                          |
| -------- | ----------------------- | ---------- | ---------------------------- |
| Dimensão | DIM_PAIS                | ID_Pais    | —                            |
| Dimensão | DIM_PRODUTO             | ID_Produto | —                            |
| Dimensão | DIM_DATA                | ID_Data    | —                            |
| Fato     | FACT_EXPORTACAO         | ID_Exp     | ID_Pais, ID_Produto, ID_Data |
| Fato     | FACT_IMPORTACAO         | ID_Imp     | ID_Pais, ID_Produto, ID_Data |
| Fato     | FACT_SERVICO_CONSTRUCAO | ID_Servico | ID_Pais, ID_Data             |
| Fato     | FACT_PIB_PER_CAPITA     | ID_PIB     | ID_Pais, ID_Data             |
| Fato     | FACT_POPULACAO_URBANA   | ID_Urbano  | ID_Pais, ID_Data             |
