library(dplyr)
library(readr)
library(fuzzyjoin)
library(stringdist)
library(RecordLinkage)

options(scipen = 999)


#
# Read in ------------------------------------------------------
#

data_amazon <- read_rds("./data/data_amazon.rds")
data_fndds <- read_rds("./data/data_fndds.rds")


#
# Implement RecordLinkage ------------------------------------------------------
#

# Try two methods 
methods <- c("jarowinkler", "levenshteinSim")

# Prepare data
input_amazon <- data_amazon %>% rename(description = upc_description, code = upc_code) %>% select(-aisle)
input_fndds <- data_fndds %>% rename(description = ec_description, code = ec_code)

# Get linkage results. 
# The resulting dataframes contain the top 3 matches for UPC codes from data_amazon (more if there is a score tie, fewer if no matches), 
# sorted by link strength. (Alternatively, sort by code.1 to see matches by UPC codes.)
for (val in 1:length(methods)) {
  df <- compare.linkage(input_amazon, input_fndds, 
                        strcmp = T, strcmpfun = get(methods[val]), 
                        exclude = "code")
  df_weights <- epiWeights(df)
  
  df_full <- getPairs(df_weights, single.rows = TRUE) %>%
             group_by(code.1) %>%
             slice_max(order_by = Weight, n = 3) %>%
             arrange(-Weight)
  
  assign(paste("data", methods[val], sep = "_"), df_full)
}

# Clean up
rm(df, df_full, df_weights, input_amazon, input_fndds, methods, val)


#
# Implement fuzzyjoin ------------------------------------------------------
#

# Try four methods
methods <- c("jw", "lcs", "lv", "osa")

# Get match results. The resulting dataframes contain the top 3 matches for UPC codes from data_amazon (more if there is a score tie, fewer if no matches),
# sorted by sorted by link strength. (Alternatively, sort by upc_code to see matches by UPC codes.)
for (val in 1:length(methods)) {
  df <- stringdist_join(data_amazon, data_fndds, 
                        by = c("upc_description" = "ec_description"),
                        mode = "left",
                        ignore_case = T, 
                        method = methods[val], 
                        max_dist = 15, # Broadly applicable to all methods, can tailor for each.
                        distance_col = "dist") %>%
    group_by(upc_code) %>%
    slice_min(order_by = dist, n = 3) %>% # Get 3 best matches. 
    ungroup() %>%
    arrange(dist)
  
  assign(paste("data", methods[val], sep = "_"), df)
}

# Clean up
rm(methods, val, df)
                        