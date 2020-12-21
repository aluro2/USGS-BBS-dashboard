#!/bin/bash
## Make data dir if not present
mkdir -p bbs_data

cd bbs_data

## Import USGS 2020 Release- North American Breeding Bird Survey Dataset (1966-2019)
curl https://www.sciencebase.gov/catalog/file/get/5ea04e9a82cefae35a129d65 -o data.zip

unzip data.zip