#' Baixa as tabelas de dados abertos do Datajud
#'
#' Baixa tabela fato, tabela de assuntos ou tabela de classes.
#'
#' Infelizmente, essas bases ainda não são de dados abertos. O nível de análise
#'   ainda é o de órgão julgador. Mas já é uma base bastante útil para fazer
#'   estatísticas.
#'
#' @param path caminho para salvar arquivo zip ou csv
#' @param unzip dezipar arquivo? Por padrão, sim
#'
#' @name dados-abertos
#'
#' @return caminho do arquivo csv ou zip baixado
#' @export
datajud_fato <- function(path, unzip = TRUE) {
  tipo <- "tbl_fato_unificada"
  datajud_download_generic(path, tipo, unzip)
}

#' @rdname dados-abertos
#'
#' @export
datajud_assuntos <- function(path, unzip = TRUE) {
  tipo <- "tbl_assunto"
  datajud_download_generic(path, tipo, unzip)
}

#' @rdname dados-abertos
#'
#' @export
datajud_classes <- function(path, unzip = TRUE) {
  tipo <- "tbl_classe"
  datajud_download_generic(path, tipo, unzip)
}


datajud_download_generic <- function(path, tipo, unzip) {
  link <- obter_link(tipo)

  usethis::ui_info("Link de download direto: {link}")
  usethis::ui_info("Baixando...")

  if (unzip) {
    result_file <- download_unzip(link, tipo, path)
  } else {
    result_file <- download_zip(link, tipo, path)
  }

  result_file
}


obter_link <- function(tipo) {
  u0 <- glue::glue(
    "https://painel-estatistica.stg.cloud.cnj.jus.br/s3.php",
    "?tabela_fato=true&front=true&ambiente=_d&nome_arquivo={tipo}"
  )
  r0 <- httr::POST(u0)
  link <- httr::content(r0, "text")
  link
}

download_unzip <- function(link, tipo, path) {
  tmp <- fs::file_temp()
  fs::dir_create(tmp)
  zip_file <- paste0(tmp, "/zip_file.zip")
  r <- httr::GET(link, httr::write_disk(zip_file, TRUE), httr::progress())
  usethis::ui_info("Dezipando...")
  unzip(zip_file, exdir = tmp)
  csv_file <- paste0(tmp, "/", tipo, ".csv")
  result_file <- fs::file_move(csv_file, path)
  fs::dir_delete(tmp)
  result_file
}

download_zip <- function(link, tipo, path) {
  zip_file <- paste0(path, "/", tipo, ".zip")
  r <- httr::GET(link, httr::write_disk(zip_file, TRUE), httr::progress())
  zip_file
}
