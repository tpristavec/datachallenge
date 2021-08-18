# README

## Introduction
Coleridge Initiative's data challenge aims to identify machine learning or other computational tools that could be used in future updates of the United States Department of Agriculture (USDA)'s [Purchase-to-Plate Crosswalk](https://www.ers.usda.gov/publications/pub-details/?pubid=92570) (PPC). The Purchase to Plate Crosswalk (PPC) links Information Resources, Inc. (IRI) [food item data](https://www.ers.usda.gov/webdocs/publications/47633/57105_tb-1942.pdf?v=0) with USDA’s’ [Food and Nutrient Database for Dietary Studies](https://www.ars.usda.gov/northeast-area/beltsville-md-bhnrc/beltsville-human-nutrition-research-center/food-surveys-research-group/docs/fndds/) (FNDDS) nutrient and food group information, providing the agency with the ability to measure US consumers’ diet quality and assess USDA Food Plan market basket costs.

The challenge goal is to successfully match each IRI universal product code (UPC) with a single FNDDS ensemble code (EC). Materials in this repository provide a simple illustration of data layout and the challenge problem for potential participants without involving any proprietary datasets. 

The repository contains the following files, with scripts in `/src/`and data in `/data/`. Interested teams can run the code or simply inspect the relevant inputs and outputs, all available as `.csv` files.

## Preparing fictional IRI product dictionary data
The file `01-scrape-amazon.R` retrieves product names from the first page of results for 22 product categories on Amazon Fresh, associates them with a fictional aisle, 
assigns them a fictional UPC, and writes out the data. The resulting data file `data_amazon.csv` mimics the basic structure of the IRI point-of-sale product dictionary that will be used in the challenge. IRI data used in the challenge contains additional features. 

This file is provided to document data collection and does not need to be re-run. The resulting `data_amazon.csv` data frame, available in `/data/`, contains the following:
- `upc_code`: Fictional 11-digit UPC code; character.
- `upc_description`: Product name; character.
- `aisle`: Fictional aisle information; character.

## Preparing FNDDS food item data 
The file `02-prep_fndds.R` reads in FNDDS 2015-2016 main food description, additional food description, and ingredients tables. It prepares an EC file following Westat's current process: it concatenates main and additional food descriptions, appends ingredient descriptions, and deduplicates ingredients that exactly repeat main food descriptions. The resulting data file `data_fndds.csv` shows a simplified Westat EC file, where an EC is a unique food code or ingredient code. Teams do not need to follow Westat's FNDDS transformation process and may prepare FNDDS tables in any way they find useful. FNDDS data used in the challenge also offers additional tables that can be matched to the EC file.

This file is provided to document data transformation and does not need to be re-run. The resulting `data_fndds.rds` data frame, available in `/data/`, contains the following:
- `ec_code`: EC code (4-8 digit food code or ingredient code); character.
- `ec_description`: Product name; character.

## 03-link.R
The challenge goal is to match each UPC with a single EC. This file reads in `data_amazon.csv` and `data_fndds.csv`, and attempts a simple match of each UPC code (food item) from the former with an EC code from the latter. It implements two methods from the `RecordLinkage` package and four methods from the `fuzzyjoin` package to do so. The resulting data frames contain the top 3 `data_fndds.csv` EC matches for UPC codes from `data_amazon.csv` (more than 3 if there is a score tie, fewer if there are no matches that satisfy the threshold criterion). The data frames are sorted by link strength by default, but can also be sorted by UPC code to show which candidate EC codes were linked to a given UPC code. 

The resulting matches are shown in the following `data/output/` files:
- `RecordLinkage` results: `data_rl_jarowinkler.csv`, `data_rl_levenshteinSim.csv`
- `fuzzyjoin` results: `data_jarowinkler.csv`, `data_levenshtein.csv`

This file illustrates a simplified matching problem of associating each UPC code with a suitable EC code; it does not employ blocking, machine learning, or use any features to predict matches. In the challenge, teams will be free to implement any natural language processing or machine learning algorithm of their choice, using all available data to find a single EC match for each UPC code.