# Important packages
library(tidyverse)

# Importing pipe-delimited raw text
txt <- read_lines("telegram_history.txt")

# First processing
txb <- tibble(raw = txt) %>% 
  # Removing chrome extension message
  slice(-1) %>% 
  # Filtering out empty lines
  filter(raw != "")

# Creating id by message
txb$id <- 0
index <- 0

for(i in 1:nrow(txb)){
  if(str_detect(txb$raw[i], "\\|")){
    
    txb$id[i] <- index + 1
    index= index + 1
    
  }else{
    
    txb$id[i] <- index  
    
  }
}

# Pasting multiple lines together by id
raw_messages <- txb %>% 
  group_by(id) %>% 
  summarise(text = paste(raw, sep = " ", collapse = " ")) %>% 
  ungroup(id) %>% select(-id)


# Processing lines into data frame
df_tlg <- raw_messages %>% 
  # Classifying events based on the presence of "....."
  mutate(class = ifelse(str_detect(text, "\\.\\.\\.\\.\\."), "Event", "Message"),
         prep = str_replace(text, "\\.\\.\\.\\.\\.", ""),
         prep = str_replace(prep, "\\(you\\)", ""),
         prep = paste(prep, class, sep = "|")) %>% 
  select(-text, -class) %>% 
  separate(prep, into = c("date_time", "sender", "message", "class"), sep = "\\|")


# Pre-processing data frame
df_final <- df_tlg %>% 
         # Turning date into R's datetime format
  mutate(date_time = parse_datetime(date_time, "%d.%m.%Y %H:%M:%S"),
         # Removing @s from name
         sender = str_replace(sender, pattern = " \\[.*\\]", ""),
         media = str_extract(message, "\\[\\[.*\\]\\]"),
         media = case_when(str_detect(media, "\\[\\[Photo") ~ "Photo",
                           str_detect(media, "\\[\\[GIF") ~ "GIF",
                           str_detect(media, "\\[\\[Webpage") ~ "Link",
                           str_detect(media, "\\[\\[Document") ~ "Document",
                           str_detect(media, "\\[\\[Geo") ~ "Geolocation"),
         message = str_replace(message, "\\[\\[.*\\]\\]", ""),
         member_count = case_when(str_detect(message, ">>.*created.*<<") ~ 1,
                                  str_detect(message, ">>.*joined.*<<") ~ 1,
                                  str_detect(message, ">>.*left.*<<") ~ 0))

# Exporting the "|" delimited csv
write_delim(df_final, "telegram_processed.csv", delim = "|")
