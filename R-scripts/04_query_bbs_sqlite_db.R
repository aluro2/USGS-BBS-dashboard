
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

    # Location codes
    location_codes <-
      usgs_bbs_db %>%
      tbl("region_codes") %>%
      filter(CountryNum == 840) %>%
      {if(STATE == "All States") . else filter(., State == STATE)} %>%
      select(CountryNum, StateNum, State)

    # Route Coordinates
    route_coords <-
      usgs_bbs_db %>%
      tbl("route_data") %>%
      left_join(location_codes, .) %>%
      select(StateNum, State, Route, RouteName, Latitude, Longitude)

    # taxon codes
    taxon_codes <-
      usgs_bbs_db %>%
      tbl("species_codes") %>%
      {if(TAXON_LEVEL == "Family") filter(., Family == TAXON)
        else {if(TAXON == "All Species") . else filter( ., English_Common_Name == TAXON)} } %>%
      select(AOU, English_Common_Name, Family)

    # Routes (Runtype & RouteID)
    routes <-
      usgs_bbs_db %>%
      tbl("runtype_data") %>%
      filter(CountryNum == 840,
             RunType == 1,
             Year %in% YEAR) %>%
      inner_join(location_codes) %>%
      pull(RouteDataID)

    # Species/family
    taxon <-
      taxon_codes %>%
      pull(AOU)

    # Get raw data
    get_data <-
      usgs_bbs_db %>%
      tbl("states_bird_point_count") %>%
      filter(CountryNum == 840)

    # Data Entries
    subset_data <-
      get_data %>%
      filter(Year %in% YEAR,
             AOU %in% taxon,
             RouteDataID %in% routes)

    # # Species list
    # species_list <-
    #   get_data %>%
    #   left_join(location_codes,., by = "StateNum") %>%
    #   distinct(AOU) %>%
    #   left_join(., tbl(usgs_bbs_db, "species_codes")) %>%
    #   pull(English_Common_Name) %>%
    #   .[!str_detect(., "(?i)unid")] %>%
    #   .[!str_detect(., "(?i)hybrid")] %>%
    #   .[!str_detect(., " ?\\(.*\\) ?")] %>%
    #   sort()
    #
    # # Family list
    # family_list <-
    #   usgs_bbs_db %>%
    #   tbl("species_codes") %>%
    #   filter(English_Common_Name %in% species_list) %>%
    #   distinct(Family) %>%
    #   pull() %>%
    #   sort()


    return(list(subset_data = subset_data,
                #species_list = species_list,
                #family_list = family_list,
                taxon_codes = taxon_codes,
                route_coords = route_coords))


    DBI::dbDisconnect(usgs_bbs_db)
  }