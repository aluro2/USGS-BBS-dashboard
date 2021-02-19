
# Load packages -----------------------------------------------------------
library(tidyverse)
library(dbplyr)
library(DBI)


# Get DB connection -------------------------------------------------------

# Shows db tables
#src_dbi(usgs_bbs_db)

get_bbs_data <-
  function(STATE,
           TAXON_LEVEL,
           TAXON,
           YEAR
  ){

    # Connect to database
    usgs_bbs_db <-
      DBI::dbConnect(RSQLite::SQLite(), "data/usgs-bbs-1966-2019.sqlite")

    # Initial Year
    start <- YEAR[1]

    # State
    state <-
      usgs_bbs_db %>%
      tbl("region_codes") %>%
      filter(CountryNum == 840) %>%
      {if(STATE == "All States") . else filter(., State == STATE)} %>%
      select(CountryNum, StateNum)

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
      {if(TAXON_LEVEL == "Species" &  TAXON == "All Species") .
        if(TAXON_LEVEL == "Family") filter(., Family == TAXON)
        else filter( ., English_Common_Name == TAXON)} %>%
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
             pct_from_initial = (total_birds- initial_birds)/initial_birds)

    # Species list
    species_list <-
      usgs_bbs_db %>%
      tbl("states_bird_point_count") %>%
      left_join(state,., by = "StateNum") %>%
      distinct(AOU) %>%
      left_join(., tbl(usgs_bbs_db, "species_codes")) %>%
      pull(English_Common_Name) %>%
      .[!str_detect(., "(?i)unid")] %>%
      .[!str_detect(., "(?i)hybrid")] %>%
      .[!str_detect(., " ?\\(.*\\) ?")] %>%
      sort()

    # Family list
    family_list <-
      usgs_bbs_db %>%
      tbl("species_codes") %>%
      filter(English_Common_Name %in% species_list) %>%
      distinct(Family) %>%
      pull() %>%
      sort()



    return(list(subset_data = as_tibble(subset_data),
                species_list = species_list,
                family_list = family_list))


    DBI::dbDisconnect(usgs_bbs_db)
  }
