
# Download region codes from trashbirdecology/bbsAssistant ----------------

region_codes_url <-
  "https://github.com/trashbirdecology/bbsAssistant/raw/main/data/region_codes.rda"

temp <- tempfile()

download.file(url = region_codes_url,
              destfile = temp)
load(temp)

dir.create("data")

write.csv(region_codes,
          file="data/region_codes.csv")

