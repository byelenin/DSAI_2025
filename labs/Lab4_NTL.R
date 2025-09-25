#######################################################################################
# Title: R for Nighttime Light Analysis via BlackMarble package
# Task:  Make a map of North Korea and South Korea in 2020 using NTL data
# Author: Zhaopeng Qu
# Date: 2024-10-25
#######################################################################################



###################################################
#  Section 0: Setup
#  Task: Load packages and define bearer token
#  Note: 
###################################################

# Load packages
library(blackmarbler) # BlackMarble package

library(geodata) # geodata package
library(sf) # sf package
library(terra) # terra package

library(ggplot2) # ggplot2 package
library(tidyterra) # tidyterra package
library(lubridate) # lubridate package
library(tidyverse) # tidyverse package

#### Define NASA bearer token

bearer <- "your_bearer_token_here"



#######################################################################################
#  Section 1: Get NTL data for North Korea and South Korea via BlackMarble package
#  Task: 
#  Note: 
#######################################################################################


## 1.1 ROI for North Korea and South Korea 

#################################### NOTE: Define region of interest (roi) ################# 
#   The roi must be (1) an sf polygon and (2) in the WGS84 (epsg:4326) coordinate reference system. 
#   Here, we use the getData function to load a polygon of South Korea and North Korea

roi_sf_kor <- gadm(country = "KOR", level=1, path = tempdir()) 
roi_sf_prk <- gadm(country = "PRK", level=1, path = tempdir()) 


## 1.2 Select the year of interest and download the suitable NTL product

#################################### NOTE: BlackMarble Product Suits ####################################
#  1. Product ID: 
#     VNP46A1: Raw Daily NTL data
#     VNP46A2: Gap-filled Daily NTL data
#     VNP46A3: Monthly NTL data 
#     VNP46A4: Yearly NTL data
#  2. Detail of the products: 
#     https://viirsland.gsfc.nasa.gov/PDF/BlackMarbleUserGuide_Collection2.0.pdf
#########################################################################################################


R_NTL_TIF_KOR <- "SaveData/NTL_TIF_KOR"

R_NTL_HDF5_KOR <- "SaveData/NTL_HDF5_KOR"

if (!dir.exists(R_NTL_TIF_KOR)) {
  dir.create(R_NTL_TIF_KOR)
}

if (!dir.exists(R_NTL_HDF5_KOR)) {
  dir.create(R_NTL_HDF5_KOR)
}


#Sys.setenv(http_proxy = "127.0.0.1:1080")
#Sys.setenv(https_proxy = "127.0.0.1:1087") 


r_2020_KOR <- bm_raster(roi_sf = roi_sf_kor,
                    product_id = "VNP46A4",
                    date = 2020,
                    bearer = bearer,
                    output_location_type = "file",
                    file_dir = R_NTL_TIF_KOR,
                    h5_dir   = R_NTL_HDF5_KOR)


r_2020_KOR




#################################### NOTE: BlackMarbleR packages ####################################
#  1. roi_sf: Region of Interest (ROI) in sf format, must be in the WGS84 (epsg:4326) coordinate reference system
#  2. product_id: Product ID
#  3. date:  
#  4. bearer: NASA Bearer token
#  5. variable: Variable of interest
#  6. quality_flag: Quality flag 
#  7. check_all_tiles_exist: Whether to check if all tiles exist
#  8. interpol_na: Whether to interpolate NA values
#  9. h5_dir: Directory of the HDF5 files to save the downloaded data
#  10. output_location_type: Type of the output location
#########################################################################################################


r_2020_KOR
str(r_2020_KOR)
glimpse(r_2020_KOR)


R_NTL_TIF_PRK <-  "SaveData/NTL_TIF_PRK"
R_NTL_HDF5_PRK <- "SaveData/NTL_HDF5_PRK"

if (!dir.exists(R_NTL_TIF_PRK)) {
  dir.create(R_NTL_TIF_PRK)
}

if (!dir.exists(R_NTL_HDF5_PRK)) {
  dir.create(R_NTL_HDF5_PRK)
}

r_2020_PRK <- bm_raster(roi_sf = roi_sf_prk,
                    product_id = "VNP46A4",
                    date = 2020,
                    bearer = bearer,
                    output_location_type = "file",
                    file_dir = R_NTL_TIF_PRK,
                    h5_dir   = R_NTL_HDF5_PRK)

## 1.3 Merge South Korea and North Korea NTL data


# Replace NA values with 0
r_2020_KOR[is.na(r_2020_KOR)] <- 0
r_2020_PRK[is.na(r_2020_PRK)] <- 0


merger_raster <- merge(r_2020_KOR, r_2020_PRK, na.rm = FALSE)



merger_raster
str(merger_raster)
glimpse(merger_raster)


# Distribution is skewed, so log
merger_raster[] <- log(merger_raster[] + 1)

merger_raster


#######################################################################################
#  Section 2: Make a map of NTL data for North Korea and South Korea
#  Task: 
#  Note: 
#######################################################################################


# 2.1 Map for South Korea and North Korea


ggplot() +
  geom_spatraster(data = merger_raster) +
  scale_fill_gradient2(low = "black",
                       mid = "yellow",
                       high = "red",
                       midpoint = 4.5,
                       na.value = "transparent") +
  labs(title = "Nighttime Lights: 2020") +
  coord_sf() +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none") +
  geom_sf(data = gadm(country = "KOR", level=0, path = tempdir()), 
          fill = NA, color = "blue", size = 0.5) +  # South Korea boundary
  geom_sf(data = gadm(country = "PRK", level=0, path = tempdir()), 
          fill = NA, color = "red", size = 0.5)    # North Korea boundary


### Only show the Nightlight data within the boundary of South Korea and North Korea

mask_data <- terra::mask(merger_raster, gadm(country = c("KOR", "PRK"), level = 0, path = tempdir()))


ggplot() +
  geom_spatraster(data = mask_data) + 
  scale_fill_gradient2(low = "black",
                       mid = "yellow",
                       high = "green",
                       midpoint = 4.5,
                       na.value = "transparent") +
  labs(title = "Nighttime Lights in 2020 North and South") +
  coord_sf() +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none") +
  geom_sf(data = gadm(country = "KOR", level=0, path = tempdir()), 
          fill = NA, color = "blue", size = 0.5) +  # South Korea boundary
  geom_sf(data = gadm(country = "PRK", level=0, path = tempdir()), 
          fill = NA, color = "red", size = 0.5) +   # North Korea boundary
  annotate("text", x = 126, y = 40, label = "North Korea", 
           color = "red", fontface = "bold", size = 4) +
  annotate("text", x = 128, y = 35.5, label = "South Korea", 
           color = "blue", fontface = "bold", size = 4)


#######################################################################################
#  Section 3: Plot the NTL data for China in 2022 using BlackMarble package
#  Task: 
#  Note: 
#######################################################################################

## 3.1 ROI for China

roi_sf_chn <- gadm(country = "CHN", level=1, path = tempdir()) 

roi_sf_chn

plot(roi_sf_chn)

## 3.2 Download the NTL data for China in 2022

# Create directories for China NTL data
R_NTL_TIF_CHN <- "SaveData/NTL_TIF_CHN"
R_NTL_HDF5_CHN <- "SaveData/NTL_HDF5_CHN"

if (!dir.exists(R_NTL_TIF_CHN)) {
  dir.create(R_NTL_TIF_CHN)
}

if (!dir.exists(R_NTL_HDF5_CHN)) {
  dir.create(R_NTL_HDF5_CHN)
}

r_2022_chn <- bm_raster(roi_sf = roi_sf_chn,
                       product_id = "VNP46A4",
                       date = 2022,
                       bearer = bearer,
                       output_location_type = "file",
                       file_dir = R_NTL_TIF_CHN,
                       h5_dir   = R_NTL_HDF5_CHN)


r_2022_chn


r_2022_chn[] <- log(r_2022_chn[] + 1)


plot(r_2022_chn, 
     main = "Log-Transformed Nighttime Lights (2022) - China",
     col = terrain.colors(100))


## 3.3 Plot the NTL data for China in 2022

ggplot() +
  geom_spatraster(data = r_2022_chn) +
  scale_fill_gradient2(low = "black",
                       mid = "yellow",
                       high = "red",
                       midpoint = 4.5,
                       na.value = "transparent") +
  labs(title = "Nighttime Lights in 2022") +
  coord_sf() +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none") +
  geom_sf(data = gadm(country = "CHN", level=1, path = tempdir()), fill = NA, color = "blue", size = 0.5)    # China boundary
          
          
## 3.4 Only show the Nightlight data within the boundary of China


mask_data <- terra::mask(r_2022_chn, gadm(country = "CHN", level = 1, path = tempdir()))

ggplot() +
  geom_spatraster(data = mask_data) + 
  scale_fill_gradient2(low = "black",
                       mid = "yellow",
                       high = "red",
                       midpoint = 4.5,
                       na.value = "transparent") +
  labs(title = "Nighttime Lights in 2022") +
  coord_sf() +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none") +
  geom_sf(data = gadm(country = "CHN", level=1, path = tempdir()), 
          fill = NA, color = "blue", size = 0.5)    # China boundary



## 3.5 Plot the NTL data for China in 2022 with the offical map of China

### base path

shapes_path <- "RawData/Shapes"

shapes_path

### Prov shapes file path 

provmap_path <- paste(shapes_path, "2022/2022年省级/2022年省级.shp", sep = "/")

provmap_sf_off <- read_sf(provmap_path)
provmap_sf_off

plot(provmap_sf_off)

plot(provmap_sf_off["geometry"], col = NA)


desired_crs <- crs(provmap_sf_off)
desired_crs


# check the crs of both data 

vector_crs <- st_crs(provmap_sf_off)
raster_crs <- crs(r_2022_chn)


print(vector_crs)
print(raster_crs)


## 3.2 Download the NTL data for China in 2022

#r_2022_chn <- bm_raster(roi_sf = roi_sf_chn,
#                       product_id = "VNP46A4",
#                       date = 2022,
#                       bearer = bearer) 
#r_2022_chn[] <- log(r_2022_chn[] + 1)


ggplot() +
  geom_spatraster(data = r_2022_chn) +
  scale_fill_gradient2(low = "black",
                       mid = "yellow",
                       high = "red",
                       midpoint = 4.5,
                       na.value = "transparent") +
  labs(title = "Nighttime Lights in 2022: China") +
  coord_sf() +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none") +
  geom_sf(data = provmap_sf_off, fill = NA, color = "blue", size = 0.5)  

ggplot() +
      geom_spatraster(data = terra::mask(r_2022_chn, provmap_sf_off)) +
      scale_fill_gradient2(low = "black",
                           mid = "yellow",
                           high = "red",
                           midpoint = 4.5,
                           na.value = "transparent") +
      labs(title = "Nighttime Lights in 2022: China") +
      coord_sf() +
      theme_void() +
      theme(plot.title = element_text(face = "bold", hjust = 0.5),
      legend.position = "none") +
      geom_sf(data = provmap_sf_off, fill = NA, color = "blue", size = 0.5)


#####################################################################
#  Section 4: Calculate the mean NTL value for each province in China
#####################################################################

library(exactextractr)


# Calculate the mean NTL value for each province in China

r_2022_chn

str(r_2022_chn)

mean_ntl_prov <- provmap_sf_off %>%
  mutate(mean_ntl = exact_extract(r_2022_chn, ., 'mean'))

# Print the data frame
print(mean_ntl_prov)

glimpse(mean_ntl_prov)

# Print the mean NTL values for each province
print(mean_ntl_prov[, c("省", "mean_ntl")])

mean_ntl_prov$mean_ntl <- log(mean_ntl_prov$mean_ntl + 1)


# Plot the mean NTL values for each province

ggplot(data = mean_ntl_prov) +
  geom_sf(aes(fill = mean_ntl)) +
  scale_fill_viridis_c() +
  labs(title = "Mean Nighttime Lights in 2022: China",
       fill = "Log-Transformed Mean NTL") +
  theme_minimal() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "bottom") 



#########################################################################
#  Practice 1 : Use .h5 files to remap the NTL data for China
#  Task: 按照练习指导，使用原始.h5夜光文件制作中国夜光图
#  Note: 
#########################################################################

################################################################################                      Hints:
# Step 1: Load the raw .h5 files into and extract the NTL data from the .h5 files
# Step 2: Use China shapefile and BlackMarble shapefiles to limit the tiles of interest
# Step 3: Based on the tile IDs, extract the corresponding NTL data from the NTL raster
# Step 4: Merge all the NTL raster into a single raster
# Step 5: Plot the merged raster
########################################################################
















































#