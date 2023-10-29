# Required libraries
library(stats)
library(dplyr)
library(lubridate)
library(readr)

dftopic <- read_csv("Data/topic_over_time_clean.csv")

qtr_insta <- readRDS("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data/qtr_insta.rds")
scaled_insta <- scale(qtr_insta$qtr_frq)[,1]
determine_category(scaled_insta)

#Bi Yearly topic data
#adding z-scores as in Steinininger et al.
dfbytopic <- dftopic %>% select(Topic, Frequency, Timestamp) %>%
  mutate(biyearly = floor_date(Timestamp, unit = 'halfyear'),
         zvalue = scale(Frequency)) %>%
  group_by(Topic, biyearly) %>%
  summarise(agg_zvalue = mean(zvalue))
        
write_rds(dfbytopic, 'Data/dfbytopic.rds')


# Linear Regression Classifier
determine_category <- function(z_scores){
  
  #Linear regression
  lm_model <- lm(z_scores ~ as.numeric(1:length(z_scores)))
  
  #LM Coefficients
  beta <- lm_model$coefficients[2]
  r_squared <- summary(lm_model)$r.squared
  
  #Differences
  differences <- diff(z_scores)

  # Check for Positive Trend
  if (beta > 0 && r_squared > 0.5) {
    # Calculate the number of consecutive decreases in the differences vector
    consecutive_decreases <- 
      sum(rle(differences < 
                0)$lengths[rle(differences < 0)$values == TRUE])
    # Check if the number of consecutive decreases is less than or equal to 2
    if (consecutive_decreases <= 2) {
      return("Positive Trend")
    }
  }
  
  # Check for Negative Trend
  if (beta < 0 && r_squared > 0.5) {
    consecutive_increases <- 
      sum(rle(diff(differences) > 
                0)$lengths[rle(diff(differences) > 0)$values == TRUE])
    if (consecutive_increases <= 2) {
      return("Negative Trend")
    }
  }
  
  #Checking for Fad and Recurring Fad
  for (i in 1:(length(z_scores) - 1)) {
    if (z_scores[i] >= 1.5 && z_scores[i + 1] >= 0.5) {
      if(any(z_scores[(i + 1):length(z_scores)] > 0.5) && r_squared <= 0.5) {
        if(any(z_scores[(i + 1):(i + 3)] <= 0.5, na.rm = TRUE)) {
          return('Recurring Fad')
        }
        else {
          return('FAD')
        }
      }
    }
  }
  
  # Check for Oscillating Topic
  oscillating_index <- which(z_scores > 0.8 | z_scores < -0.8)
  if (any(diff(oscillating_index) > 1) >= 2 && beta > -0.1 &&
      beta < 0.1 && r_squared <= 0.5) {
    return("Oscillating Topic")
  }
  
  # If none of the above
  return("Other")
}

feature_classification <- 0:37
category <- NULL
for(i in 0:37){
  dfsubset <- pull(dfbytopic[dfbytopic$Topic == i, 'agg_zvalue'])
  classification <- determine_category(dfsubset)
  category <- append(category, classification)
}
LM_classification <- data.frame(Topic = feature_classification, category)

