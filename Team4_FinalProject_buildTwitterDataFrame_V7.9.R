
#apply relevant packages
lapply(c('twitteR', 'dplyr', 'ggplot2', 'lubridate', 'network', 'sna', 'qdap', 'tm','igraph', 'SocialMediaLab', 'googlesheets', 'streamR'),
       library, character.only = TRUE)

#set-up authentication keys and tokens
#note that these will be obfuscated on github
my_key <- 'HIDDEN'
my_secret <- 'HIDDEN'
my_access_token <- 'HIDDEN'
my_access_secret <- 'HIDDEN'
set.seed(95616)

cred <- Authenticate("twitter", apiKey=my_key, apiSecret=my_secret, accessToken=my_access_token, accessTokenSecret=my_access_secret)

#Build the dataframe
#start with an empty dataframe so we can bind the collection
df_player_tweets <- data.frame(text=character(),
                               favorited=logical(),
                               favoriteCount=numeric(),
                               replyToSN=character(),
                               created_at=as.POSIXct(character()),
                               truncated=logical(),
                               replyToSID=character(),
                               id=character(),
                               replyToUID=character(),
                               statusSource=character(),
                               screen_name=character(),
                               retweetCount=numeric(),
                               isRetweet=logical(),
                               longitude=logical(),
                               latitude=logical(),
                               from_user=character(),
                               reply_to=character(),
                               users_mentioned=list(),
                               retweet_from=character(),
                               hashtags_used=list())

df_ptc <- df_player_tweets

#load the list of players from a csv file, not that pragmatically this is simply a list of twitter handles with meta-data
df_playerlist <- read.csv(file = "~/Downloads/Data620/playerList.csv", header = TRUE)

#iterate through the playerlist and collect tweets
for(i in 1:nrow(df_playerlist)){
  
  player <- df_playerlist[i,]
  handle <- paste('from:',player$handle, sep = '')
  print(paste('Attempting to gather information on: ',player$handle, sep = ''))
  collection <- Collect(cred, ego = FALSE, searchTerm = handle, numTweets = 50)
  collection$users_mentioned <- vapply(collection$users_mentioned, paste, collapse = ", ", character(1L))
  collection$hashtags_used <- vapply(collection$hashtags_used, paste, collapse = ", ", character(1L))
  
  #wite the collection to a cvs prior to binding in case there are issues as we build the larger file
  filename <- paste('~/Downloads/Data620/p_new_', player$handle, '.csv', sep = '')
  write.csv(collection, filename)
  
  #append to the current data frame
  df_player_tweets <- rbind(df_player_tweets, collection)
  
}

#Because we may run this function multiple times, we remove duplicates by calling uniques
df_player_tweets_unique <- unique(df_player_tweets)

write.csv(df_player_tweets_unique, file = '~/Downloads/Data620/Top20Tweets_and_Teams_and_Ancillary.csv')

#Check the igraph

igraph_tweets <- Create(df_player_tweets_unique, type = "bimodal")
plot(igraph_tweets)
