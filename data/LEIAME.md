# Cadastro de municípios

`Cadastro_Municipios_2026.csv`: 5.570 municípios (incluindo o Distrito Federal), 21 variáveis, uma linha por município. Fornecido na disciplina PTE 3524 (ENCE/IBGE), com base no Censo Demográfico 2022 do IBGE (Tabela 9923, "População residente, por situação do domicílio", e tabelas correlatas).

| Variável | Descrição |
|---|---|
| `id_municipio`, `nome_municipio` | Código IBGE (7 dígitos) e nome |
| `uf_sigla`, `uf_nome`, `regiao_sigla`, `regiao_nome` | UF e macrorregião |
| `urbano_rural`, `tipologia_urb_rural` | Tipologias derivadas da proporção urbana |
| `capital` | Indicador de capital (1/0) |
| `regiao_imediata`, `regiao_intermediaria` | Regiões geográficas (ver ressalva) |
| `domicilios` | Domicílios particulares ocupados (ver ressalva) |
| `pop_total_censo2022`, `pop_urbana_censo2022`, `pop_rural_censo2022` | População residente |
| `area_km2`, `densidade` | Área territorial e densidade demográfica |
| `pct_urbana`, `pct_rural` | Proporções urbana e rural |
| `porte_populacional` | Classes de porte (faixas do IBGE) |
| `estrato_uf_porte` | UF × porte populacional |

## Ressalvas

Verificações de consistência feitas para este projeto (detalhes na §2.1 do [relatório](../relatorio.md)):

- **`domicilios`** equivale à população total dividida por um tamanho médio de domicílio fixo por macrorregião (2,60 a 3,18 pessoas), com erro máximo de 4 domicílios. Não é a contagem observada do Censo.
- **`regiao_imediata` e `regiao_intermediaria`** não correspondem à divisão regional do IBGE para a maior parte dos municípios.
- População, proporções, porte, tipologia, UF e macrorregião são consistentes entre si.

Para análises além do exercício, prefira as tabelas originais do IBGE (SIDRA) e a Divisão Territorial Brasileira.
