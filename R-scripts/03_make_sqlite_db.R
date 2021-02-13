
# Load packages -----------------------------------------------------------

library(zip)
library(data.table)
library(dplyr)
library(dbplyr)
library(DBI)
library(RSQLite)


# Unzip bbs_data data.zip archive into a temp directory -------------------

# Make a temporary directory for files
temp <- tempfile()

# Unzip the full data.zip archive into temp
zip::unzip("bbs_data/data.zip", exdir = temp)

# show unzipped files
dir(temp)

# States' bird point count data -------------------------------------------

# Unzip State bird count data into temp
zip::unzip(paste(temp,"/States.zip",sep=""),
           exdir = temp)
# get file
states <-
  list.files(paste(temp, "/States", sep = ""),
             full.names = T)

# Make a separate temp directory to extract states' .zip files into
states_temp <- tempfile()

# Unzip all states files into .csv
lapply(states, function(x){
  zip::unzip(x,
             exdir = states_temp)

})

# Get .csv files locations for all states data
states_csv <-
  list.files(states_temp, full.names = T)

# Create a single data table of all states' .csv data
states_bird_point_count <-
  rbindlist(lapply(states_csv, fread))

# Delete temp dirs used for states' files
file.remove(
  states,
  list.files(states_temp, full.names = T))

# Get species AOU names ---------------------------------------------------

# Function to parse SpeciesList.txt
get_species_codes <-
  function(File) {
    #File <- paste0(Dir, "SpeciesList.txt")

    All <- scan(File, what="character", sep="\n", encoding="latin1")
    Delimiter <- grep("^-", All)

    ColNames <- strsplit(All[Delimiter-1], split='[[:blank:]]+')[[1]]
    Widths <- nchar(strsplit(All[Delimiter], split='[[:blank:]]+')[[1]])

    Lines <- sapply(All[-(1:Delimiter)], function(str, w) {
      trimws(substring(str, c(1,cumsum(w[-length(w)])), cumsum(w)))
    }, w=Widths+1)
    colnames(Lines) <- NULL
    rownames(Lines) <- ColNames

    Lines.df <- as.data.frame(t(Lines), stringsAsFactors = FALSE)
    Lines.df$Seq <- as.numeric(Lines.df$Seq)
    Lines.df$AOU <- as.numeric(Lines.df$AOU)
    Lines.df
  }

species_codes <-
  get_species_codes(File = paste(temp, "/SpeciesList.txt", sep = ""))

# Get AOU region codes ----------------------------------------------------

region_codes <-
  read.csv("data/region_codes.csv") %>%
  mutate(
    Country = case_when(CountryNum == 840 ~ "Unites States",
                        CountryNum == 484 ~ "Mexico",
                        CountryNum == 124 ~ "Canada")
  )


# Get Route Names and Lat-Lon coordinates ---------------------------------

# Unzip routes.zip to routes.csv
unzip(paste(temp, "/routes.zip", sep = ""), exdir = temp)

# Import routes.csv
route_data <-
  read.csv(file = paste(temp, "/routes.csv", sep = ""))


# Get RunType values from weather.csv, RunType = 1 indicate acceptable counts based on USGS BBS standards--------
# See bbs_data/data.zip/Completeness_Report_NABBS_Dataset_1966-2019.pdf section 5

# Unzip Weather.zip to weather.csv (RunType is contained in this file)
unzip(paste(temp, "/Weather.zip", sep = ""), exdir = temp)

# Import routes.csv
runtype_data <-
  read.csv(file = paste(temp, "/weather.csv", sep = ""))

# Make Sqlite DB -----------------------------------------------------------


sql_db_path <-
  "data/usgs-bbs-1966-2019.sqlite"

bbs_db <- DBI::dbConnect(RSQLite::SQLite(), sql_db_path)

dbWriteTable(conn = bbs_db, name = "runtype_data", value = runtype_data, row.names = FALSE, overwrite = TRUE)

dbWriteTable(conn = bbs_db, name = "region_codes", value = region_codes, row.names = FALSE, overwrite = TRUE)

dbWriteTable(conn = bbs_db, name = "route_data", value = route_data, row.names = FALSE, overwrite = TRUE)

dbWriteTable(conn = bbs_db, name = "species_codes", value = species_codes, row.names = FALSE, overwrite = TRUE)

dbWriteTable(conn = bbs_db, name = "states_bird_point_count", value = states_bird_point_count, row.names = FALSE, overwrite = TRUE)



