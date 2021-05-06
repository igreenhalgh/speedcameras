# Install Packages ----

if (require("pacman"))
  install.packages("pacman")
pacman::p_load(pacman, httr, rlist, jsonlite, tidyverse, ggmap, sf, mapview)

# Get Data ----

query <- list(page = "1")
resp <-
  GET(
    "https://opendata.arcgis.com/datasets/504cc474c13a45908fc0b4f45afa595c_13.geojson",
    query = query
  )
jsonRespText <- content(resp, as = "text")
jsonRespParsed <- content(resp, as = "parsed")
modJson <- fromJSON(jsonRespText, flatten = TRUE)
modJson <- as_tibble(modJson$features)
data <- modJson
rm(jsonRespParsed, modJson, query, resp, jsonRespText)

# Clean Data ----

data2 <- select(data, properties.ID:properties.LONGITUDE)
data3 <- rename(
  data2,
  ID = properties.ID,
  RoadName = properties.ROADNAME,
  RoadDirection = properties.ROADDIR,
  Latitude = properties.LATITUDE,
  Longitude = properties.LONGITUDE
)
rm(data, data2)
df <- data3
rm(data3)
df <- filter(df, Latitude != 0)

# Map Data ----

locations_df <- select(df, -ID,-RoadDirection) %>%
  rename(road = "RoadName") %>%
  rename(lon = "Longitude") %>%
  rename(lat = "Latitude") %>%
  print()
locations_sf <-
  st_as_sf(locations_df, coords = c("lon", "lat"), crs = 4326)
mapview(locations_sf)