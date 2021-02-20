library(tidyverse)



# Summary data
summary_data <-
  function(data){
    data %>%
      group_by(Year) %>%
      summarise(
        total_birds = as.double(sum(SpeciesTotal, na.rm = T)/n_distinct(RouteDataID))
      ) %>%
      mutate(initial_birds = first(total_birds),
             pct_from_initial = (total_birds- initial_birds)/initial_birds)

  }
