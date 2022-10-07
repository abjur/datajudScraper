#' Pega uma base zip do Datajud
#'
#' @param tribunal codigo do tribunal.
#' @param oj código da unidade judiciária.
#' @param path caminho da pasta para salvar o arquivo zip
#'
#' @return caminho do arquivo.
#' @export
baixar_datajud <- function(tribunal, oj, path) {
  f <- glue::glue("{path}/{tribunal}_{oj}.zip")
  if (!file.exists(f)) {
    u <- "https://painel-estatistica.stg.cloud.cnj.jus.br/s3.php"
    q <- list(
      tribunal = tribunal,
      indicador = "",
      oj = oj,
      front = "true",
      ambiente = "_d"
    )
    r <- httr::POST(u, query = q)
    link <- httr::content(r, "text")
    if (!stringr::str_detect(link, "^erro")) {
      httr::GET(link, httr::write_disk(f, TRUE))
    } else {
      usethis::ui_oops(link)
    }
  }
  f
}

#' Listar tribunais a partir da API do DataJud
#'
#' @return tibble com a lista dos tribunais.
#' @export
listar_tribunais <- function() {
  r <- "https://datajudbi.stg.cloud.cnj.jus.br/api/tribunal/listarProcessados" |>
    httr::GET()
  r |>
    httr::content(simplifyDataFrame = TRUE) |>
    tibble::as_tibble()
}

#' Listar os municípios
#'
#' @param id_tribunal id do tribunal para baixar os municipios.
#' @param path pasta para salvar o arquivo json.
#'
#' @return caminho para um arquivo do json que contém os municípios.
#' @export
listar_municipios <- function(id_tribunal, path) {
  f <- glue::glue("{path}/{id_tribunal}.json")
  if (!file.exists(f)) {
    u <- paste0(
      "https://datajudbi.stg.cloud.cnj.jus.br/api/oj/listarMunicipiosProcessados/",
      id_tribunal
    )
    r <- httr::GET(u, httr::write_disk(f, TRUE))
  }
  f
}

#' Listar Órgãos de Justiça
#'
#' @param id_tribunal id do tribunal para baixar os municípios
#' @param id_municipio id do municípiio para baixar ojs
#' @param path pasta para salvar o arquivo json.
#'
#' @return caminho do arquivo json que contém ojs.
#' @export
listar_oj <- function(id_tribunal, id_municipio, path) {
  f <- glue::glue("{path}/{id_tribunal}_{id_municipio}.json")
  if (!file.exists(f)) {
    u <- paste0(
      "https://datajudbi.stg.cloud.cnj.jus.br/api/oj/listarProcessados/",
      id_tribunal, ",", id_municipio
    )
    r <- httr::GET(u, httr::write_disk(f, TRUE))
  }
  f
}
