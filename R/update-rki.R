library(rvest)
library(dplyr)

reporting_datetime <- "2020-03-17 19:20:00 CET"
raw_table <- html("https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html") %>%
  html_table()
raw_table <- raw_table[[1]][, 1:2]
colnames(raw_table) <- c("place", "cases")

raw_table <- raw_table %>%
  mutate(cases = stringr::str_replace(cases, stringr::fixed("."), "")) %>%
  mutate(cases = stringr::str_extract(cases, "\\d+") %>% as.integer()) %>%
  tibble::as_tibble()

list(
  source = "https://www.rki.de/DE/Content/InfAZ/N/Neuartiges_Coronavirus/Fallzahlen.html",
  report_datetime = reporting_datetime,
  cases_total = filter(raw_table, place == "Gesamt") %>% pull(cases),
  cases = list(
    by_admin2 = filter(raw_table, place != "Gesamt")
  )
) %>%
  jsonlite::toJSON(pretty = TRUE, auto_unbox = TRUE, force = TRUE) %>%
  readr::write_file(paste0("data-raw/rki.de/", reporting_datetime, ".json"))
