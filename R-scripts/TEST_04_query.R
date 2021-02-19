source("R-scripts/04_query_bbs_sqlite_db.R")

system.time({

    get_bbs_data(
      STATE = "MAINE",
      TAXON_LEVEL = "Family",
      TAXON = "Paridae",
      YEAR = 1970:2020)


})

test <-
  get_bbs_data(
    STATE = "MAINE",
    TAXON_LEVEL = "Family",
    TAXON = "Paridae",
    YEAR = 1970:2020)

as.tibble(test) %>%
  ggplot(aes(x = Year, y = pct_from_initial)) +
  geom_hline(yintercept = 0, color = "red", size = 2) +
  geom_line(alpha = 0.3) +
  geom_smooth(span = 0.3) +
  scale_y_continuous(labels=scales::percent)

test$species_list

