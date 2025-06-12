tf <- withr::local_tempfile()
download.file(
  "https://files.digital.nhs.uk/assets/ods/current/epraccur.zip",
  tf,
  mode = "wb"
)

unzip(tf, "epraccur.csv")

gps <- readr::read_csv("epraccur.csv", col_names = FALSE) |>
  dplyr::select(practiceCode = X1, practiceName = X2, postCode = X10)

# Download NHSPD Online Latest Centroids shape file from
# https://geoportal.statistics.gov.uk/datasets/bc2f6cabd9cf4531a631a82765e5cd0d_1/
postcodes <- sf::read_sf(
  "postcodes_shp",
  query = "SELECT pcds FROM NHSPD_Online_Latest_Centroids"
)

gps |>
  dplyr::arrange(practiceCode) |>
  dplyr::inner_join(postcodes, by = dplyr::join_by("postCode" == "pcds")) |>
  sf::st_as_sf() |>
  dplyr::filter((!sf::st_is_empty(geometry))) |>
  sf::st_transform(crs = 4326) |>
  sf::st_write("gps.geojson")
