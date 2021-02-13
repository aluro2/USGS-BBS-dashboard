library(tidyverse)

data <-
  readRDS("data/complete_bbs_data.rds") %>%
  filter(CountryNum == 840,
         RunType == 1) %>%
  na.omit()

states <-
  data %>%
  split(., .$State)

data_sample <-
  purrr::map(states, ~sample_n(.x, 50)) %>%
    bind_rows()

saveRDS(data_sample,
          "data/sample_data.rds")


# Saves state data as seprate files
# purrr::imap(states, function(x,n){
#
#   state_name <- str_replace(n, " ", "_")
#
#   saveRDS(
#     object = x,
#     file = paste("data/state_data/", state_name, ".rds", sep = ""))
#
# })

