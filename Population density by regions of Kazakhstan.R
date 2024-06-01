# Load necessary libraries
library(devtools)
library(geokz)
library(dplyr)
library(sf)
library(tmap)

# Install the geokz package from GitHub if not already installed
devtools::install_github("arodionoff/geokz")

# Read population density data
Population_Density_df <- read.csv('C:/Users/Admin/Рабочий стол/Audandar_with_data.csv') %>%
  dplyr::select(ADM2_PCODE, ADM2_EN, Area, Population) %>%
  dplyr::rename(ISO_3166_2 = ADM2_PCODE, Region = ADM2_EN) %>%
  dplyr::mutate(Population_Density = round(Population / Area, 1))

# Strip leading/trailing spaces from the join columns
Population_Density_df$ISO_3166_2 <- trimws(Population_Density_df$ISO_3166_2)
rayons_map <- get_kaz_rayons_map(Year = 2024)
rayons_map$ADM2_PCODE <- trimws(rayons_map$ADM2_PCODE)

# Convert to character type if not already
Population_Density_df$ISO_3166_2 <- as.character(Population_Density_df$ISO_3166_2)
rayons_map$ADM2_PCODE <- as.character(rayons_map$ADM2_PCODE)

# Print unique values to manually inspect
print(unique(Population_Density_df$ISO_3166_2))
print(unique(rayons_map$ADM2_PCODE))

# Perform the join
map_data <- dplyr::inner_join(
  x = rayons_map,
  y = Population_Density_df[, c("ISO_3166_2", "Population_Density")],
  by = c("ADM2_PCODE" = "ISO_3166_2")
)

# Check the result of the join
print(map_data)



# Create the map plot
map_plot <- tmap::qtm(
  shp = map_data, 
  fill = "Population_Density", 
  fill.n = 6,
  fill.style = "quantile",
  fill.text = "Population_Density",
  fill.title = "чел. на кв. км",
  format = "World",
  border = NA
)

# Save the map plot
tmap::tmap_save(map_plot, "C:/Users/Admin/Рабочий стол/Audandar_Tygyz_2024.jpeg")









