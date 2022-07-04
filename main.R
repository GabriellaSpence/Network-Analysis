library(dplyr)
library(tidytext)
library(stringr)
library(wordcloud)
library(vosonSML)

# Load in data (rt data frame)
githubURL = "https://github.com/GabriellaSpence/Network-Analysis/raw/main/Data.RData"
load(url(githubURL))

# Convert class to work with vosonSML package
class(rt) = append(c("datasource", "twitter"), class(rt))
rt = rt %>% ImportData("twitter")

# Data Exploration: View (English) tweets over time
ts_plot(rt, "hours") +
  labs(x = NULL, y = NULL,
       title = "Frequency of tweets with a #PeopleAnalytics hashtag",
       subtitle = paste0(format(min(rt$created_at), "%B %d, %Y"), " to ", format(max(rt$created_at),"%B %d, %Y"))) +
  theme_minimal()

# Data Exploration: Top locations for tweets (almost all tweets are missing location data)
rt %>% 
  filter(!is.na(place_full_name)) %>% 
  count(place_full_name, sort = TRUE) %>% 
  top_n(5)

# Data Exploration: Most retweeted tweets
rt %>% 
  arrange(-retweet_count) %>%
  select(created_at, screen_name, text, retweet_count) %>%
  distinct(text)

# Data Exploration: Most active tweeters
rt %>% 
  count(screen_name, sort = TRUE) %>%
  top_n(10) %>%
  mutate(screen_name = paste0("@", screen_name))

# Data Exploration: Top hashtags other than people analytics
rt %>% 
  unnest_tokens(hashtag, text, "tweets", to_lower = FALSE) %>%
  filter(str_detect(hashtag, "^#"),
         hashtag != "#peopleanalytics",
         hashtag != "#PeopleAnalytics") %>%
  count(hashtag, sort = TRUE) %>%
  top_n(10)

# Data Exploration: Top Mentions
rt %>% 
  unnest_tokens(mentions, text, "tweets", to_lower = FALSE) %>%
  filter(str_detect(mentions, "^@")) %>%  
  count(mentions, sort = TRUE) %>%
  top_n(10)

# Data Exploration: Create word cloud
words = rt %>%
  mutate(text = str_remove_all(text, "&amp;|&lt;|&gt;"),
         text = str_remove_all(text, "\\s?(f|ht)(tp)(s?)(://)([^\\.]*)[\\.|/](\\S*)"),
         text = str_remove_all(text, "[^\x01-\x7F]")) %>% 
  unnest_tokens(word, text, token = "tweets") %>%
  filter(!word %in% stop_words$word,
         !word %in% str_remove_all(stop_words$word, "'"),
         str_detect(word, "[a-z]"),
         !str_detect(word, "^#"),         
         !str_detect(word, "@\\S+")) %>%
  count(word, sort = TRUE)


words %>% 
  with(wordcloud(word, n, random.order = FALSE, max.words = 100, colors = "#F29545"))


########### Build network data frames [In Progress] ####################

# Activity network: Nodes are tweets, edges are the relationship to other tweets (replying, retweeting, or quoting tweets)
activity = rt


# Actor network: Nodes are users, edges are the relationship to other users
actor = rt


# Semantic network: Nodes are concepts, edges are words or hashtags
semantic = rt

