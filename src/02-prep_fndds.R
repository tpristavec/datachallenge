library(readr)
library(dplyr)


#
# Read in tables ----------------------------------------------------
#

# Main food description table
maindesc <- read_csv("./data/mainfooddesc1718.csv", 
                     col_types = cols(Food_code = col_character())) %>%
            select(-starts_with("WWEIA"), -contains("date")) %>%
            arrange(desc(Food_code))

# Additional food description table
adddesc <- read_csv("./data/addfooddesc1718.csv", 
                    col_types = cols(Food_code = col_character())) %>%
           select(-contains("date")) %>%
           arrange(desc(Food_code))

# Ingredients table
ingred <- read_csv("./data/fnddsingred1718.csv", 
                   col_types = cols(Food_code = col_character(), Ingredient_code = col_character())) %>%
          select(-Amount, -Measure, -Portion_code, -Retention_code, -Ingredient_weight, -contains("date")) %>%
          arrange(desc(Ingredient_code))  %>%
          arrange(Food_code, Ingredient_code, Seq_num)


#
# Reshape FNDDS ----------------------------------------------------
#

# Concatenate all additional food descriptions of one main food together
length(unique(adddesc$Food_code)) # Resulting DF should have 5,011 rows.

adddesc_concat <- adddesc %>%
  group_by(Food_code) %>%
  summarise(Additional_food_description = paste(Additional_food_description, collapse = ", ")) %>%
  ungroup()

# Concatenate the merged additional food descriptions and the main food description
length(setdiff(maindesc$Food_code, adddesc_concat$Food_code)) # 2,072 main food codes don't have an additional food description
length(setdiff(adddesc_concat$Food_code, maindesc$Food_code)) # 0 as expected.

maindesc_concat <- left_join(maindesc, adddesc_concat, by = "Food_code")

maindesc_concat <- maindesc_concat %>% 
                 mutate(Food_description = ifelse(!is.na(Additional_food_description), 
                                                  paste(Main_food_description, Additional_food_description, sep = ", "),
                                                  Main_food_description)) %>%
                 select(-Main_food_description, -Additional_food_description) %>%
                 rename(ec_code = Food_code, ec_description = Food_description)

# Prepare ingredients table
ingred_prep <- ingred %>% select(starts_with("Ing")) %>%
                          rename(ec_code = Ingredient_code, ec_description = Ingredient_description) %>%
                          arrange(ec_code, ec_description)

length(unique(ingred_prep$ec_code))
length(unique(ingred_prep$ec_description))

ingred_prep <- ingred_prep %>% distinct(.keep_all = T) %>% arrange(ec_code, ec_description)

# Append ingredients table to food (main and additional) table
data_fndds <- bind_rows(maindesc_concat, ingred_prep) %>%
              arrange(ec_description)

# Deduplicate (-ingredients that exactly replicate main food codes; sort so that the main food code is retained)
data_fndds <- data_fndds %>% 
                  group_by(ec_description) %>% 
                  mutate(dupl = n() > 1) %>%
                  ungroup()

data_fndds <- data_fndds %>% 
                  mutate(charnum = nchar(ec_code)) %>%
                  arrange(-dupl, ec_description, -charnum) %>%
                  filter(!duplicated(ec_description)) %>%
                  select(-charnum, -dupl)


#
# Clean up and write ----------------------------------------------------
#

rm(list = setdiff(ls(), "data_fndds")) 

write_rds(data_fndds, "./data/data_fndds.rds")