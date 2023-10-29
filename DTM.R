library(readr)
library(dtw)
library(dplyr)
library(dtwclust)

dfbytopic <- readRDS("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data/dfbytopic.rds")

set.seed(450)
x <- 1:10
#generating discoure patterns
positive_trend <- x * 0.5 + 1)
negative_trend <- -x * 0.5 + 8 + rnorm(length(x), mean=0)
fad <- c(1, 1.5, 3.5, 4, 2, 1.2, 0.8, 0.7, 0.6, 0.5)
recurring_fad <- c(1, 1.5, 3.5, 4, 2, 1.2, 2.5, 3, 2.2, 1.8)
oscillating <- c(1, -1.5, 1.5, -1, 1, -1.5, 1.5, -1, 1, -1)

#function for nomralizing patterns
normalize_vector <- function(data){
  mean <- mean(data)
  sd <- sd(data)
  data <- (data - mean(data))/sd
  return(data)
}

#normalizing patterns
norm_positive_trend <- normalize_vector(positive_trend)
norm_negative_trend <- normalize_vector(negative_trend)
norm_fad <- normalize_vector(fad)
norm_recurring_fad <- normalize_vector(recurring_fad)
norm_oscillating <- normalize_vector(oscillating)


bmin <- data.frame()

for (i in 0:37){
zscores <- dfbytopic[dfbytopic$Topic == i,'agg_zvalue'] 
dtwResults <- lapply(list(norm_positive_trend, norm_negative_trend, 
                            norm_fad, norm_recurring_fad, norm_oscillating), function(pattern){
    dtw(zscores, pattern)$distance
  })

  bestMatchIndex <- unlist(list('Positive Trend', 'Negative Trend', 
                         'Fad', 'Recurring Fad', 'Oscillating Topic')[which.min(unlist(dtwResults))])
  min <- min(unlist(dtwResults))
  bmin <- rbind(bmin, data.frame(Topic = i, DTW = bestMatchIndex, min))
}  
DTM_classification <- bmin %>% select(Topic, DTW)

All_classification <- cbind(DTM_classification, RF_classification, LM_classification)
All_classification <- All_classification[,c(1,2,4,6)]
nbf <- c(
  "Other", "Need", "Benefit", "Benefit",
  "Benefit", "Need", "Other", "Need", "Benefit",
  "Need", "Benefit", "Benefit", "Need", "Need",
  "Other", "Need", "Other", "Other", "Benefit",
  "Need", "Benefit", "Benefit", "Need", "Need",
  "Attribute", "Attribute", "Need", "Benefit", "Attribute",
  "Other", "Attribute", "Other", "Need", "Benefit",
  "Attribute", "Other", "Need", "Benefit")
All_classification <- cbind(nbf, All_classification)
colnames(All_classification) <- c('NBF', 'Label', 'DTM', 'Random Forest', 'Linear Regression')

topic_label <- dftopic %>% 
  select(label, Topic) %>%
  distinct() %>%
  select(label)
All_classification$Label <- pull(topic_label)
write_csv(All_classification, 'Data/All_Classification.csv')

all_predictions$Topic <- pull(topic_label)
write_csv(all_predictions, 'all_prediction.csv')




zscores <- dfbytopic[dfbytopic$Topic == i,'agg_zvalue'] 
dtwResults <- lapply(list(norm_positive_trend, norm_negative_trend, 
                          norm_fad, norm_recurring_fad, norm_oscillating), function(pattern){
                            dtw(scaled_insta, pattern)$distance
                          })

bestMatchIndex <- unlist(list('Positive Trend', 'Negative Trend', 
                              'Fad', 'Recurring Fad', 'Oscillating Topic')[which.min(unlist(dtwResults))])
min <- min(unlist(dtwResults))
bmin <- rbind(bmin, data.frame(Topic = i, DTW = bestMatchIndex, min))
}
