# helper script to parse the data of berlin.de

library(purrr)
library(tesseract)
library(dplyr)
source_url <- "https://www.berlin.de/sen/gpg/service/presse/2020/pressemitteilung.907568.php"
table_image <- "https://www.berlin.de/sen/gpg/service/presse/2020/20200316_bezirksverteilung.jpg"
reporting_datetime <- "2020-03-16 16:30:00 CET"


raw_data <- table_image %>%
  ocr(engine = tesseract("deu")) %>%
  strsplit("\n") %>%
  unlist() %>%
  head(14) %>%
  tail(13) %>%
  map(~ strsplit(.x, " ", fixed = TRUE)) %>%
  map(~ .x[[1]]) %>%
  map(~ tibble::tibble(place = .x[1], cases = .x[2], new_cases = .x[3], incidence = .x[4])) %>%
  bind_rows() %>%
  mutate(
    cases = as.integer(cases),
    new_cases = stringr::str_extract(new_cases, "\\d+") %>% as.integer(),
    incidence = stringr::str_replace_all(incidence, ",", ".") %>% as.numeric()
  )

list(
  source = source_url,
  report_datetime = reporting_datetime,
  cases_total = filter(raw_data, place == "Summe") %>% pull(cases),
  new_cases_total = filter(raw_data, place == "Summe") %>% pull(new_cases),
  incidence_total = filter(raw_data, place == "Summe") %>% pull(incidence),
  cases = list(
    by_admin3 = filter(raw_data, place != "Summe")
  )
) %>%
  jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE) %>%
  readr::write_file(paste0("data-raw/berlin.de/", reporting_datetime, ".json"))

# after that we need to manually edit the json file to fix OCR issues
