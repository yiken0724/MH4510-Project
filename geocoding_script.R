library(ggmap)
library(tidyverse)

# Set your Google Maps API key here 
API_KEY <- Sys.getenv("GOOGLE_API_KEY")  # recommended: store in .Renviron

# Register it
register_google(key = API_KEY)

data <- read.csv("dataset/DataCoSupplyChainDataset.csv") 

unique_destinations <- data %>%
  select(`Order City`, `Order Country`) %>%
  distinct() %>%
  mutate(
    `Order City` = iconv(`Order City`, to = "UTF-8", sub = ""),
    `Order Country` = iconv(`Order Country`, to = "UTF-8", sub = ""),
    location = paste(`Order City`, `Order Country`, sep = ", ")
  )

cat("Total unique destinations to geocode:", nrow(unique_destinations), "\n")


unique_destinations <- read_csv("destinations_geocoded_progress.csv")
for (i in 1:nrow(unique_destinations)) {
  
  # Progress update every 10 locations
  if (i %% 10 == 0) {
    cat("Progress:", i, "/", nrow(unique_destinations), 
        "(", round(i/nrow(unique_destinations)*100, 1), "%)\n")
  }
  
  # Try to geocode this location
  tryCatch({
    result <- geocode(unique_destinations$location[i], output = "latlon")
    
    unique_destinations$dest_lat[i] <- result$lat
    unique_destinations$dest_long[i] <- result$lon
    unique_destinations$geocode_status[i] <- "success"
    
    # Small delay to respect rate limits
    Sys.sleep(0.1)
    
  }, error = function(e) {
    # Log the error but continue
    cat("Failed at row", i, ":", unique_destinations$location[i], "\n")
    cat("Error:", e$message, "\n")
  })
  
  # Save progress every 50 locations (in case of interruption)
  if (i %% 50 == 0) {
    write_csv(unique_destinations, "destinations_geocoded_progress.csv")
    cat("Progress saved at row", i, "\n\n")
  }
}

cat("Successfully geocoded:", sum(!is.na(unique_destinations$dest_lat)), "locations\n")
cat("Failed:", sum(is.na(unique_destinations$dest_lat)), "locations\n\n")

write_csv(unique_destinations, "dataset/destinations_geocoded.csv")
cat("\nSaved to: destinations_geocoded.csv\n")