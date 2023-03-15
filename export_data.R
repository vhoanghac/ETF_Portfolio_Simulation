# Packages:
library(tidyverse) # Core
library(purrr) # Map
library(timetk) # summarise by time
library(tidyquant) # transmute, calculate returns
library(data.table)

# Duong dan folder data chua file CSV
paths <- fs::dir_ls("data")

# Lay ten cac tep
datanames <-  gsub("\\.csv$","", list.files(path    = "data", 
                                            pattern = "\\.csv$")) %>% 
  tolower()

# Import/read cac tep va gom vao 1 list
list <- paths %>% 
  map(function(path){
    fread(path)
  })

# Convert sang du lieu thang
list_converted <- list %>% 
  set_names(datanames) %>% 
  lapply(function(x){
    
    x %>%
      
      # Lay du lieu ngay dau tien trong thang
      summarise_by_time(.date_var = date,
                        .by       = "month",
                        price     = first(price),
                        .type     = "floor") %>% 
      
      # Monthly returns
      tq_transmute(select     = price,
                   mutate_fun = periodReturn,
                   period     = "monthly",
                   col_rename = "returns") 
  })

# Convert tu list sang table
data <- list_converted %>% 
  enframe() %>% 
  unnest(value) %>% 
  rename(symbol = name)

# Export
write_csv(data, "data_tidied/full_data.csv")