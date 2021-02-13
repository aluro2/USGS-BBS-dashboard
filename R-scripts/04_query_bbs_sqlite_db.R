
# Load packages -----------------------------------------------------------
library(tidyverse)
library(dbplyr)
library(DBI)


# Get DB connection -------------------------------------------------------

usgs_bbs_db <-
  DBI::dbConnect(RSQLite::SQLite(), "data/usgs-bbs-1966-2019.sqlite")

src_dbi(usgs_bbs_db)

STATE <- "MAINE"
TAXON_LEVEL  <- "Species"
TAXON <- "American Robin"
FAMILY <- "Turdidae"
YEAR <- 1966:2019

get_bbs_data <-
  function(STATE,
           TAXON_LEVEL,
           TAXON,
           YEAR
  ){
    # Initial Year
    start <- YEAR[1]

    # State
    state <-
      usgs_bbs_db %>%
      tbl("region_codes") %>%
      filter(CountryNum == 840) %>%
      {if(STATE == "All States"). else filter(STATE ==STATE)} %>%
      select(CountryNum, StateNum, State)

    # Routes (Runtype & RouteID)
    routes <-
      usgs_bbs_db %>%
      tbl("runtype_data") %>%
      filter(CountryNum == 840,
             RunType == 1,
             Year %in% YEAR) %>%
      inner_join(state) %>%
      pull(RouteDataID)


    # Species/family
    taxon <-
      usgs_bbs_db %>%
      tbl("species_codes") %>%
      filter(English_Common_Name == TAXON) %>%
      pull(AOU)

    # Data Entries
    subset_data <-
      usgs_bbs_db %>%
      tbl("states_bird_point_count") %>%
      filter(CountryNum == 840,
             Year %in% YEAR,
             AOU %in% taxon,
             RouteDataID %in% routes) %>%
      group_by(Year) %>%
      summarise(
        total_birds = as.double(sum(SpeciesTotal, na.rm = T)/n_distinct(RouteDataID))
      ) %>%
      mutate(initial_birds = first(total_birds),
             pct_from_initial = (total_birds- initial_birds)/initial_birds * 100)

    return(subset_data)


  }


get_bbs_data(STATE = "All States",
             TAXON_LEVEL = TAXON_LEVEL,
             TAXON = TAXON,
             YEAR = YEAR)

DBI::dbDisconnect(usgs_bbs_db)
