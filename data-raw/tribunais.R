## code to prepare `tribunais` dataset goes here

path_municipios <- "data-raw/municipios"
path_ojs <- "data-raw/ojs"
fs::dir_create(path_municipios)
fs::dir_create(path_ojs)

# tribunais ---------------------------------------------------------------
tribunais <- listar_tribunais()


# municipios --------------------------------------------------------------

purrr::walk(
  tribunais$id,
  listar_municipios,
  "data-raw/municipios",
  .progress = TRUE
)

municipios <- fs::dir_ls(path_municipios) |>
  purrr::map(jsonlite::read_json, simplifyDataFrame = TRUE) |>
  purrr::map_dfr(tibble::as_tibble, .id = "file") |>
  dplyr::transmute(
    id_tribunal = basename(tools::file_path_sans_ext(file)),
    id_municipio = id,
    nome
  )

# ojs ---------------------------------------------------------------------

# download
purrr::walk2(
  municipios$id_tribunal,
  municipios$id_municipio,
  listar_oj,
  path_ojs,
  .progress = TRUE
)

# parse
ojs <- fs::dir_ls(path_ojs) |>
  purrr::map(jsonlite::read_json, simplifyDataFrame = TRUE) |>
  purrr::map_dfr(tibble::as_tibble, .id = "file") |>
  janitor::clean_names() |>
  dplyr::filter(is.na(timestamp)) |>
  dplyr::select(-timestamp, -status, -error, -path)

# export ------------------------------------------------------------------

usethis::use_data(tribunais, overwrite = TRUE, compress = "xz")
usethis::use_data(municipios, overwrite = TRUE, compress = "xz")
usethis::use_data(ojs, overwrite = TRUE, compress = "xz")

