## code to prepare `tribunais` dataset goes here

tribunais <- listar_tribunais()

purrr::walk(tribunais$id, listar_municipios, "data-raw/municipios/")

municipios <- fs::dir_ls("data-raw/datajud/municipios/") |>
  purrr::map(jsonlite::read_json, simplifyDataFrame = TRUE) |>
  purrr::map_dfr(tibble::as_tibble, .id = "file") |>
  dplyr::transmute(
    id_tribunal = basename(tools::file_path_sans_ext(file)),
    id_municipio = id,
    nome
  )

purrr::walk2(
  municipios$id_tribunal,
  municipios$id_municipio,
  listar_oj,
  "data-raw/datajud/ojs/"
)

ojs <- fs::dir_ls("data-raw/datajud/ojs") |>
  purrr::map(jsonlite::read_json, simplifyDataFrame = TRUE) |>
  purrr::map_dfr(tibble::as_tibble, .id = "file") |>
  janitor::clean_names() |>
  dplyr::filter(is.na(timestamp)) |>
  dplyr::select(-timestamp, -status, -error, -path)


usethis::use_data(tribunais, overwrite = TRUE, compress = "xz")
usethis::use_data(municipios, overwrite = TRUE, compress = "xz")
usethis::use_data(ojs, overwrite = TRUE, compress = "xz")

