# Required libraries
library(stats)
library(forecast)
library(readr)
library(dplyr)
library(gridExtra)
library(tidyverse)
library(envalysis)
library(forecast)

setwd("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis")
topics_over_time <- read_csv("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data/topics_over_time.csv")

topics_over_time <- topics_over_time[topics_over_time$Topic != -1,]
topics_over_time <- topics_over_time[topics_over_time$Topic != 38,]

nbf <- c(
  "Other", "Need", "Benefit", "Benefit",
  "Benefit", "Need", "Other", "Need", "Benefit",
  "Need", "Benefit", "Benefit", "Need", "Need",
  "Other", "Need", "Other", "Other", "Benefit",
  "Need", "Benefit", "Benefit", "Need", "Need",
  "Attribute", "Attribute", "Need", "Benefit", "Attribute",
  "Other", "Attribute", "Other", "Need", "Benefit",
  "Attribute", "Other", "Need", "Benefit"
)

#adding needs benefits attributes to data.frame
Topic <- seq(0, 37)
indexvector <-data.frame(Topic, nbf)
topics_over_time<- merge(topics_over_time, indexvector)

topics_over_time$Timestamp <- floor_date(topics_over_time$Timestamp, unit = 'halfyear')
topics_over_time <- topics_over_time %>%
  group_by(Topic, Timestamp) %>%
  mutate(freq = mean(Frequency))
topics_over_time$Frequency <- scale(topics_over_time$Frequency)

topic_names <- names(topics_over_time)
names(topics_over_time)[names(topics_over_time) == "freq"] <- "Normalized Frequency"
names(topics_over_time)[names(topics_over_time) == "Timestamp"] <- "Time"


topic_plot <- function(data){
data %>% ggplot(aes(Time, `Normalized Frequency`)) + 
  geom_line(linewidth = 2) +
  geom_smooth(method=lm, se = FALSE) +
  theme(plot.background = element_blank(),
        panel.background = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        axis.ticks = element_blank(),
        axis.text = element_blank(),
        strip.text = element_text(size = 12))+
  facet_wrap(~ label, ncol = 4)
}
p_need <- topic_plot(topics_over_time[topics_over_time$nbf == 'Need',])
  grid.arrange(p_need, top='Needs')
p_benefit <- topic_plot(topics_over_time[topics_over_time$nbf == 'Benefit',])
  grid.arrange(p_benefit, top='Benefits')
p_topic_over_time <- topic_plot(topics_over_time[topics_over_time$nbf == 'Attribute',])
  grid.arrange(p_topic_over_time, top='Features')
p_other <-topic_plot(topics_over_time[topics_over_time$nbf == 'Other',])
  grid.arrange(p_other, top='Other')
  
names(topics_over_time) <- topic_names
write_csv(topics_over_time, "Data/topic_over_time_clean.csv")
