# -*- coding: utf-8 -*-
"""
Created on Tue Oct  3 10:09:03 2023

@author: moise
"""
from bertopic import BERTopicimport pandas as pd
import os
from datetime import datetime
from transformers import pipeline
from bertopic.representation import TextGeneration

#Loading DATA
df = pd.read_csv("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data/df_bert.csv")

#adding quarterly date
df['quarterdate'] = pd.to_datetime(df['quarterdate'])
df['quarterdate'] = df['quarterdate'].dt.strftime("%Y-%m-%d")

#promt for manual label REMOVE
prompt = "I have a topic described by the following keywords: [DOCUMENTS]. Based on the previous documents, what is this topic about?"

# Create your representation model
generator = pipeline('text2text-generation', model='google/flan-t5-base')
representation_model = TextGeneration(generator)

# Train the model
# Initiate BERTopic
topic_model = BERTopic(language="multilingual", min_topic_size = 25, nr_topics = 'auto', representation_model= representation_model)

# Run BERTopic model
topics = topic_model.fit_transform(df['text'])

# Get the list of topics
topic_model.get_topic_info()

#topic model over time
topics_over_time = topic_model.topics_over_time(df['text'], df['quarterdate'])
topic_model.visualize_topics_over_time(topics_over_time, top_n_topics=10)


x = topic_model.get_document_info(df['text'])

# Further reduce topics
topic_model.reduce_topics(df['text'], nr_topics=40)

topic_model.save("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data/bert_topic_reduced_final")

# Access updated topics
topics = topic_model.topics_
reduced_topics = topic_model.get_topic_info()
reduced_topics.to_csv("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data/reduced_topics.csv")

#Manually assigning labels
custom_labels = {
    -1: "Positive Food",
    0: "Agreement",
    1: "Vegan General",
    2: "Food Enthusiasm",
    3: "Positive Feedback",
    4: "Amazement",
    5: "Desire Try",
    6: "Gratitude",
    7: "Product Inquiry General",
    8: "Vegan Appreciation",
    9: "Picture Request",
    10: "Love Express",
    11: "Anticipation",
    12: "Animal Rights",
    13: "Recipe",
    14: "Attendance",
    15: "Germany Inquiry",
    16: "Promotions",
    17: "Direct Msg",
    18: "Food Presentation",
    19: "LA Inquiry",
    20: "Best Express",
    21: "Amazement",
    22: "Idea Praise",
    23: "Canada Request",
    24: "UK Inquiry",
    25: "Plant-Based",
    26: "Burger Comments",
    27: "Order Queries",
    28: "Sushi Love",
    29: "Ingredients",
    30: "Positive News",
    31: "Gluten Ask",
    32: "Check Encourage",
    33: "Soy Inquiry",
    34: "Financials",
    35: "Australia Inquiry",
    36: "Health Testimony",
    37: "Store Placement",
    38: "Team Welcome"
}

#set custom labels
topic_model.set_topic_labels(custom_labels)
fig = topic_model.visualize_barchart(custom_labels=True)

#rerun topics over time for reduced topics (k=40)
topics_over_time = topic_model.topics_over_time(df['text'], df['quarterdate'])

#adding custom labels to topics over time df
topics_over_time['label'] = topics_over_time['Topic'].map(custom_labels)

#saving topics over time df
topics_over_time.to_csv("C:/Users/moise/OneDrive - Erasmus University Rotterdam/Master Thesis/Data/topics_over_time.csv")
