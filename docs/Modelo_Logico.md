# Modelo Lógico

## Objetivo

Transformar o modelo conceptual num modelo lógico estruturado, com identificação clara de:

- Chaves primárias (PK)
- Chaves estrangeiras (FK)
- Tipos de relacionamento (1:N, N:M)
- Dependências funcionais
- Cardinalidades e integridade referencial

## Entidades Detalhadas

### PAIS

Descrição: Contém informação geográfica e económica de cada país.
Chave primária: `ID_Pais`

| Atributo   | Tipo   | PK | FK | Descrição                   |
| ---------- | ------ | -- | -- | --------------------------- |
| ID_Pais    | INT    | ✅  |    | Identificador único do país |
| Nome_Pais  | STRING |    |    | Nome oficial                |
| Continente | STRING |    |    | Continente                  |
| Regiao     | STRING |    |    | Região económica/geográfica |
| Codigo_ISO | STRING |    |    | Código ISO (Alpha-3)        |

Relações:

- 1:N → `EXPORTACAO`, `IMPORTACAO`, `SERVICO_CONSTRUCAO`, `PIB_PER_CAPITA`, `POPULACAO_URBANA`

### PRODUTO_CERAMICO

Descrição: Catálogo de produtos cerâmicos baseados nos códigos HS (6907, 6908, 6910).
Chave primária: `ID_Produto`

| Atributo          | Tipo   | PK | FK | Descrição                      |
| ----------------- | ------ | -- | -- | ------------------------------ |
| ID_Produto        | INT    | ✅  |    | Identificador único do produto |
| Codigo_HS         | STRING |    |    | Código harmonizado (HS Code)   |
| Descricao_Produto | STRING |    |    | Descrição do produto           |

Relações:

- 1:N → `EXPORTACAO`
- 1:N → `IMPORTACAO`

### EXPORTACAO

Descrição: Representa os valores de exportação de Portugal por produto e país de destino.
Chave primária: `ID_Exp`

| Atributo        | Tipo   | PK | FK | Descrição                                |
| --------------- | ------ | -- | -- | ---------------------------------------- |
| ID_Exp          | INT    | ✅  |    | Identificador único da exportação        |
| ID_Pais         | INT    |    | ✅  | País de destino                          |
| ID_Produto      | INT    |    | ✅  | Produto cerâmico exportado               |
| ID_Data         | INT    |    | ✅  | Referência temporal                      |
| Valor_Exportado | FLOAT  |    |    | Valor total exportado                    |
| Unidade         | STRING |    |    | Unidade de medida (USD, toneladas, etc.) |
| Ano             | INT    |    |    | Ano da operação                          |

Relações:

- N:1 → `PAIS`
- N:1 → `PRODUTO_CERAMICO`
- N:1 → `DATA`

### IMPORTACAO

Descrição: Representa os valores de importação de produtos cerâmicos por país.
Chave primária: `ID_Imp`

| Atributo        | Tipo   | PK | FK | Descrição                                |
| --------------- | ------ | -- | -- | ---------------------------------------- |
| ID_Imp          | INT    | ✅  |    | Identificador único da importação        |
| ID_Pais         | INT    |    | ✅  | País importador                          |
| ID_Produto      | INT    |    | ✅  | Produto cerâmico                         |
| ID_Data         | INT    |    | ✅  | Referência temporal                      |
| Valor_Importado | FLOAT  |    |    | Valor total importado                    |
| Unidade         | STRING |    |    | Unidade de medida (USD, toneladas, etc.) |
| Ano             | INT    |    |    | Ano da operação                          |

Relações:

- N:1 → `PAIS`
- N:1 → `PRODUTO_CERAMICO`
- N:1 → `DATA`

### SERVICO_CONSTRUCAO

Descrição: Serviços de construção exportados por Portugal.
Chave primária: `ID_Servico`

| Atributo        | Tipo   | PK | FK | Descrição                                     |
| --------------- | ------ | -- | -- | --------------------------------------------- |
| ID_Servico      | INT    | ✅  |    | Identificador único do serviço                |
| ID_Pais         | INT    |    | ✅  | País de destino                               |
| Tipo_Servico    | STRING |    |    | Categoria do serviço (ex: “Construção civil”) |
| Valor_Exportado | FLOAT  |    |    | Valor total exportado                         |
| Unidade         | STRING |    |    | Unidade (USD)                                 |
| Ano             | INT    |    |    | Ano da exportação                             |
| ID_Data         | INT    |    | ✅  | Referência temporal                           |

Relações:

- N:1 → `PAIS`
- N:1 → `DATA`

### PIB_PER_CAPITA

Descrição: Indicadores económicos anuais por país.
Chave primária: `ID_PIB`

| Atributo  | Tipo  | PK | FK | Descrição               |
| --------- | ----- | -- | -- | ----------------------- |
| ID_PIB    | INT   | ✅  |    | Identificador           |
| ID_Pais   | INT   |    | ✅  | País                    |
| PIB_Valor | FLOAT |    |    | Valor do PIB per capita |
| Ano       | INT   |    |    | Ano de referência       |
| ID_Data   | INT   |    | ✅  | Ligação à dimensão Data |

### POPULACAO_URBANA

Descrição: Indicadores de urbanização e crescimento populacional.
Chave primária: `ID_Urbano`

| Atributo        | Tipo  | PK | FK | Descrição              |
| --------------- | ----- | -- | -- | ---------------------- |
| ID_Urbano       | INT   | ✅  |    | Identificador          |
| ID_Pais         | INT   |    | ✅  | País                   |
| Total_Populacao | FLOAT |    |    | População total urbana |
| Ano             | INT   |    |    | Ano                    |
| ID_Data         | INT   |    | ✅  | Referência temporal    |

### DATA

Descrição: Dimensão temporal usada para análise histórica.
Chave primária: `ID_Data`

| Atributo     | Tipo   | PK | FK | Descrição              |
| ------------ | ------ | -- | -- | ---------------------- |
| ID_Data      | INT    | ✅  |    | Identificador temporal |
| Ano          | INT    |    |    | Ano                    |
| Trimestre    | STRING |    |    | Ex: “Q1”, “Q2”         |
| Decada       | STRING |    |    | Ex: “2010s”, “2020s”   |
| Period_Label | STRING |    |    | Ex: “2017_Q3”          |

## Cardinalidades Globais

| Relação                            | Tipo | Descrição                                         |
| ---------------------------------- | ---- | ------------------------------------------------- |
| PAIS → EXPORTACAO                  | 1:N  | Um país (Portugal) exporta para vários países     |
| PAIS → IMPORTACAO                  | 1:N  | Um país importa de vários fornecedores            |
| PAIS → SERVICO_CONSTRUCAO          | 1:N  | Um país recebe serviços de construção portugueses |
| PAIS → PIB_PER_CAPITA              | 1:N  | Um país tem vários registos anuais                |
| PAIS → POPULACAO_URBANA            | 1:N  | Um país tem indicadores anuais                    |
| PRODUTO_CERAMICO → EXPORTACAO      | 1:N  | Um produto é exportado várias vezes               |
| PRODUTO_CERAMICO → IMPORTACAO      | 1:N  | Um produto é importado várias vezes               |
| DATA → (todas as tabelas factuais) | 1:N  | Cada linha factual pertence a um período temporal |

## Resumo do Modelo Lógico

- Tabelas Dimensionais: `PAIS`, `PRODUTO_CERAMICO`, `DATA`
- Tabelas Fato: `EXPORTACAO`, `IMPORTACAO`, `SERVICO_CONSTRUCAO`, `PIB_PER_CAPITA`, `POPULACAO_URBANA`
- Tipo de Modelo: Snowflake simplificado → Star Schema híbrido
