latest_berlin <- sort(list.files("data-raw/berlin.de", full.names = TRUE), decreasing = TRUE)[1]
latest_rki <- sort(list.files("data-raw/rki.de", full.names = TRUE), decreasing = TRUE)[1]

fs::file_copy("data-raw/berlin.de", "docs/berlin.de")
fs::file_copy("data-raw/rki.de", "docs/rki.de")

list(
  "berlin.de" = jsonlite::fromJSON(latest_berlin),
  "rki.de" = jsonlite::fromJSON(latest_rki)
) %>%
  jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, force = TRUE) %>%
  readr::write_file("docs/latest.json")
