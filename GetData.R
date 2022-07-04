library(rtweet)

# ## authenticate via web browser
# token <- create_token(
#   app = "gxs",
#   consumer_key = Sys.getenv("key"),
#   consumer_secret = Sys.getenv("secret"))
# 
# get_token()

# search tweets
rt <- search_tweets("#peopleanalytics", n = 500, include_rts = TRUE, lang = "en")
View(rt)

#Save data for later
saveRDS(rt, "Data.rds")