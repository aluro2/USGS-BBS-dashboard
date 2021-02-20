# Load packages -----------------------------------------------------------
library(tidyverse)
library(dbplyr)
library(DBI)


# Get states' species list --------------------------------------


   # Connect to database
    usgs_bbs_db <-
      DBI::dbConnect(RSQLite::SQLite(), "data/usgs-bbs-1966-2019.sqlite")


    usgs_bbs_db %>%
      tbl("states_bird_point_count") %>%
      filter(CountryNum == 840) %>%
      left_join(
        select(
          tbl(usgs_bbs_db, "region_codes"),
          CountryNum, StateNum, State),
        by= c("CountryNum", "StateNum")) %>%
      left_join(
        select(
          tbl(usgs_bbs_db, "species_codes"),
          AOU, English_Common_Name, Family),
        by = "AOU") %>%
      select(State, English_Common_Name, Family) %>%
      distinct() %>%
      collect() %>%
      write_csv("data/taxon_list.csv")