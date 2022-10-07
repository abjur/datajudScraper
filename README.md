
<!-- README.md is generated from README.Rmd. Please edit that file -->

# datajudScraper

<!-- badges: start -->
<!-- badges: end -->

O pacote `{datjudScraper}` possui funções para baixar os arquivos .zip
disponibilizados pelo [painel de estatísticas do poder
judiciário](https://painel-estatistica.stg.cloud.cnj.jus.br/estatisticas.html),
através da função `datajudScraper::baixar_datajud()`.

Para baixar um arquivo zip com os dados do DataJud, precisamos passar o
nome do tribunal e o código do órgão judiciário (OJ).

O painel de estatísticas permite a coleta desses dados, que foram
organizados em três conjuntos de dados deste pacote:

1.  Tribunais: base `datajudScraper::tribunais`.
2.  Municípios: base `datajudScraper::municipios`.
3.  OJs: base `datajudScraper::ojs`

A base de OJs é a mais importante, pois contém todos os links que usamos
para baixar um arquivo zip.

Por exemplo, digamos que o interesse seja baixar todos os dados do
Tribunal de Justiça do Ceará (TJCE), na comarca de Sobral/CE.

O código abaixo lista todas as OJs dessa comarca.

``` r
ojs_sobral <- datajudScraper::ojs |> 
  dplyr::filter(
    sigla_tribunal == "TJCE",
    nome_municipio == "SOBRAL"
  ) |> 
  dplyr::select(-file)

knitr::kable(ojs_sobral)
```

|   id | id_tribunal | id_origem | nome                                                                                | sigla_tribunal | nome_tribunal                          | id_segmento_justica | nome_segmento_justica                                   | id_municipio | nome_municipio | uf  |
|-----:|------------:|----------:|:------------------------------------------------------------------------------------|:---------------|:---------------------------------------|--------------------:|:--------------------------------------------------------|-------------:|:---------------|:----|
| 4548 |          70 |      8835 | 1ª VARA CIVEL DA COMARCA DE SOBRAL                                                  | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4373 |          70 |      8542 | 1ª VARA CRIMINAL DA COMARCA DE SOBRAL                                               | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4764 |          70 |     78409 | 1ª VARA DE FAMILIA E SUCESSOES DA COMARCA DE SOBRAL                                 | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4432 |          70 |      8620 | 2ª VARA CIVEL DA COMARCA DE SOBRAL                                                  | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4446 |          70 |      8640 | 2ª VARA CRIMINAL DA COMARCA DE SOBRAL                                               | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4747 |          70 |     78385 | 2ª VARA DE FAMILIA E SUCESSOES DA COMARCA DE SOBRAL                                 | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4624 |          70 |     14320 | 3ª VARA CIVEL DA COMARCA DE SOBRAL                                                  | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4630 |          70 |     14589 | 3ª VARA CRIMINAL DA COMARCA DE SOBRAL                                               | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4846 |          70 |     81798 | CEJUSC - CENTRO JUDICIÁRIO DE SOLUÇÃO DE CONFLITOS E CIDADANIA DA COMARCA DE SOBRAL | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4549 |          70 |      8838 | JUIZADO ESPECIAL DA COMARCA DE SOBRAL                                               | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4798 |          70 |     79765 | VARA UNICA DA INFANCIA E JUVENTUDE DA COMARCA DE SOBRAL                             | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |
| 4454 |          70 |      8649 | VARA UNICA DE FAMILIA E SUCESSOES DA COMARCA DE SOBRAL                              | TJCE           | Tribunal de Justiça do Estado do Ceará |                   8 | Justiça dos Estados e do Distrito Federal e Territórios |          786 | SOBRAL         | CE  |

Para baixar os links, utilizamos `purrr::walk2()` em conjunto com a
função `baixar_datajud()`:

``` r
purrr::walk2(
  ojs_sobral$sigla_tribunal,
  ojs_sobral$id_origem,
  baixar_datajud,
  path = "data-raw/zip"
)
```

Nem todos os arquivos baixam com sucesso. Nos casos em que temos
sucesso, podemos acessar os arquivos zip e olhar os CSV. Abaixo, um
código para dezipar e empilhar as bases.

``` r
# lista os arquivos zip
zips <- fs::dir_ls("data-raw/zip")

# dá unzip nos arquivos
purrr::walk(zips, ~{
  usethis::ui_info(.x)
  unzip(.x, exdir = "data-raw/csv")
})

# lê os arquivos em uma base única

csv <- fs::dir_ls("data-raw/csv")

ler_csv <- function(f) {
  loc <- readr::locale(decimal_mark = ",", grouping_mark = ".")
  readr::read_csv2(f, show_col_types = FALSE, locale = loc)
}

dados_consolidados <- purrr::map(csv, ler_csv) |> 
  dplyr::bind_rows(.id = "file")

dplyr::glimpse(dados_consolidados)
```

Os resultados dessa consulta ficam assim:

    Rows: 62,453
    Columns: 22
    $ file                         <chr> "data-raw/csv/TJCE_14320_5PorcMaisAntigos…
    $ Tribunal                     <chr> "TJCE", "TJCE", "TJCE", "TJCE", "TJCE", "…
    $ `Código órgão`               <dbl> 14320, 14320, 14320, 14320, 14320, 14320,…
    $ `Nome órgão`                 <chr> "3ª VARA CIVEL DA COMARCA DE SOBRAL", "3ª…
    $ Processo                     <chr> "0040915-19.2012.8.06.0167", "0040934-25.…
    $ Grau                         <chr> "G1", "G1", "G1", "G1", "G1", "G1", "G1",…
    $ `Recurso Originario`         <chr> "Originário", "Originário", "Originário",…
    $ `Pendente desde`             <date> 2012-03-22, 2012-03-22, 2012-04-25, 2012…
    $ `Quant dias até 31-Jul-2022` <dbl> 3783, 3783, 3749, 3747, 3740, 3715, 3713,…
    $ Formato                      <chr> "Eletrônico", "Eletrônico", "Eletrônico",…
    $ Procedimento                 <chr> "Conhecimento não criminal", "Conheciment…
    $ `Nível de sigilo`            <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,…
    $ Ano                          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ Mês                          <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ `Data de Referência`         <date> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    $ Município                    <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ UF                           <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ Classe                       <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ `Código classe`              <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ `Concluso desde`             <date> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, …
    $ `Tipo de conclusão`          <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
    $ `Última movimentação`        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, N…
