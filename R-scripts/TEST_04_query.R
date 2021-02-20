source("R-scripts/04_query_bbs_sqlite_db.R")
source("R-scripts/05_summarize_data.R")

system.time({

    get_bbs_data(
      STATE = "MAINE",
      TAXON_LEVEL = "Family",
      TAXON = "Paridae",
      YEAR = 1970:2020)


})

test <-
  get_bbs_data(
    STATE = "ILLINOIS",
    TAXON_LEVEL = "Species",
    TAXON = "All Species",
    YEAR = 1966:2020)

# Plot summary data (Percent change from initial year) --------------------
test$subset_data %>%
  summary_data() %>%
  ggplot(aes(x = Year, y = pct_from_initial)) +
  geom_hline(yintercept = 0, color = "red", size = 2) +
  geom_line(alpha = 0.3) +
  geom_smooth(span = 0.3) +
  scale_y_continuous(labels=scales::percent) +
  labs(
    y = "Percent change in counted birds per route \n from initial year"
  )

# Make output data file -----------------------------------
test$subset_data %>%
  left_join(test$taxon_codes, by = "AOU") %>%
  left_join(test$route_coords, by = c("StateNum","Route")) %>%
  select(Year, State, RouteName, Latitude, Longitude, English_Common_Name, SpeciesTotal) %>%
  arrange(Year)




