## Package Loading
library(readr)
library(lubridate)
library(zoo)
library(readxl)
library(ggplot2)
library(envalysis)
library(dplyr)
library(gridEx)
library(xlsx)

#Data Loading
setwd("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data")

insta1 <- read_csv("dataset_instagram-hashtag-scraper_2023-09-27_19-54-19-495.csv", show_col_types = FALSE)
insta2 <- read_csv("dataset_instagram-hashtag-scraper_2023-09-29_18-08-03-497.csv", show_col_types = FALSE)
colnames(insta2)[which(!colnames(insta2) %in% colnames(insta1))] #hashtags 30 in insta 2 maar niet in insta 1
insta2 <- insta2 %>% select(-`hashtags/30`)
insta <- rbind(insta1, insta2)


saveRDS(insta[, c("ownerUsername", "url")], 'insta.rds') #Saving insta for exluding comments from accountowners.

#Time to lubridate
insta$timestamp <- ymd_hms(insta$timestamp) #to lubridate
insta$timestamp <- format(insta$timestamp, "%Y-%m-%d") #to d/m/Y
#Filter dates from 2018 t/m 2022
insta <- insta %>%
  filter(timestamp >= "2018-01-01" & timestamp < "2023-01-01")

I <- insta$url[1:1000]
II <- insta$url[1001:2000]
III <- insta$url[2001:3000]
IV <- insta$url[3001:4000]
V <- insta$url[4001:4806]

dfs <- list(I,II,III,IV,V)

write.xlsx(I, 'url_1.xlsx')
write.xlsx(II, 'url_2.xlsx')
write.xlsx(III, 'url_3.xlsx')
write.xlsx(IV, 'url_4.xlsx')
write.xlsx(V, 'url_5.xlsx')