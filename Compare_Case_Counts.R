get_who_cases <- function(country = NULL, daily = FALSE) {
  who_cases <- data.table::fread("https://raw.githubusercontent.com/eebrown/data2019nCoV/master/data-raw/WHO_SR.csv")
  if (!is.null(country)) {
    who_cases <- who_cases[, c("Date", country), with = FALSE]
    colnames(who_cases) <- c("date", "cases")
  }
  if (daily) {
    cols <- colnames(who_cases)
    cols <- cols[!colnames(who_cases) %in% c("Date", "date", "SituationReport")]
    safe_diff <- purrr::safely(diff)
    who_cases <- dplyr::mutate_at(who_cases,
                                  .vars = cols,
                                  ~ . - dplyr::lag(., default = 0))
  }
  return(who_cases)
}

who_data = get_who_cases()

colnames(who_data)
plot(who_data$Italy)

BNO_data = read_csv('/Users/hamishgibbs/Dropbox/nCov-2019/data_sources/case_data/International_Case_Data_BNO/BNO_Scraped_Data.csv') %>% 
  group_by(country) %>% 
  summarise(sum_bno = sum(new_case))

BNO_data

as_tibble(who_data)

sums = who_data %>% 
  select(-SituationReport, -Date, -`RA-China`, -`RA-Global`, -`RA-Regional`) %>% 
  summarise_all(sum)
sums = tibble(country = rownames(t(sums)), sum_who = t(sums)[,1])

sums %>% left_join(BNO_data) %>% 
  filter(country != 'China')

plot(who_data$RepublicofKorea)
