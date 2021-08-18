library(rvest)
library(xml2)
library(dplyr)
library(readr)

options(scipen = 999)


#
# Prepare item list --------------------------------------------------------
#

items <- c("https://www.amazon.com/s?bbn=10329849011&rh=n%3A9865332011&s=featured-rank&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&ref=fs_dsk_cp_ai_sml_10_6506977011",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16318751%2Cn%3A18776870011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625609&rnid=10329849011&ref=sr_nr_n_3",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16318751%2Cn%3A6548788011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625609&rnid=10329849011&ref=sr_nr_n_7",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16310251%2Cn%3A16318891&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625707&rnid=10329849011&ref=sr_nr_n_4",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16310251%2Cn%3A11713205011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625707&rnid=10329849011&ref=sr_nr_n_6",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16322461%2Cn%3A6558923011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625771&rnid=10329849011&ref=sr_nr_n_4",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A371460011%2Cn%3A6520506011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625862&rnid=10329849011&ref=sr_nr_n_14",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A371460011%2Cn%3A371464011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625862&rnid=10329849011&ref=sr_nr_n_8",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A371460011%2Cn%3A6520456011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625862&rnid=10329849011&ref=sr_nr_n_2",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A371460011%2Cn%3A6520421011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625862&rnid=10329849011&ref=sr_nr_n_1",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A371460011%2Cn%3A119343011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625862&rnid=10329849011&ref=sr_nr_n_10",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A18773724011%2Cn%3A9847696011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625991&rnid=10329849011&ref=sr_nr_n_9",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A6459122011%2Cn%3A6459230011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625992&rnid=10329849011&ref=sr_nr_n_11",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A371469011%2Cn%3A371477011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625995&rnid=10329849011&ref=sr_nr_n_10",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A6518859011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625595&rnid=10329849011&ref=sr_nr_n_13",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A6506977011%2Cn%3A16322881&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625998&rnid=10329849011&ref=sr_nr_n_5",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A6506977011%2Cn%3A16318981&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625998&rnid=10329849011&ref=sr_nr_n_2",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A6506977011%2Cn%3A16319281&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625998&rnid=10329849011&ref=sr_nr_n_4",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16322721%2Cn%3A6524464011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625998&rnid=10329849011&ref=sr_nr_n_2",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16322721%2Cn%3A16322991&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625998&rnid=10329849011&ref=sr_nr_n_14",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A16322721%2Cn%3A6524481011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628625998&rnid=10329849011&ref=sr_nr_n_17",
           "https://www.amazon.com/s?i=grocery&bbn=10329849011&rh=n%3A10329849011%2Cn%3A16310101%2Cn%3A6459122011%2Cn%3A6459171011%2Cn%3A6459179011&s=featured-rank&dc&pd_rd_r=2925aef1-9280-4609-9cf2-0d6e6a1e7a79&pd_rd_w=rKOam&pd_rd_wg=WQGQU&pf_rd_p=1b269efe-3eda-4adf-ae81-cfcb4747eaa0&pf_rd_r=91P3A2ZNDBZ23XQH6DCP&qid=1628626355&rnid=10329849011&ref=sr_nr_n_2")

names(items) <- c("dried fruit", "bread", "desserts", "cereals", "baking mixes",
                  "chocolate candy", "yogurt", "eggs", "cheese", "butter", "dairy alternatives",
                  "pickled", "pizza", "seafood", "meat alternatives", "nuts and seeds", "fruit",
                  "vegetables", "bars", "popcorn", "rice cakes", "ice cream")


#
# Get items --------------------------------------------------------
#

for (val in 1:length(items)) {
  products <- read_html(items[val])
  
  upc_description <- products %>% 
    html_elements(".a-link-normal .a-text-normal") %>%
    html_text()
  
  df <- as.data.frame(upc_description)
  df$aisle <- paste(names(items[val])) 
  
  assign(paste("data", names(items[val]), sep = "_"), df)
}


#
# Join and clean up --------------------------------------------------------
#

# Join
datalist <- mget(ls(pattern = "data_"))
data <- bind_rows(datalist)

# Clean
rm(list = setdiff(ls(), "data")) 


#
# Generate item IDs and reorder columns--------------------------------------------------------
#

# IDs
upc_code <- sample(10000000000:99999999999, nrow(data), replace = F)
upc_code <- as.character(upc_code)
data$upc_code <- upc_code

rm(upc_code)

# Swap column order
data <- data %>% select(upc_code, upc_description, aisle)


#
# Write --------------------------------------------------------
#

write_csv(data, "./data/input/data_amazon.csv")
  