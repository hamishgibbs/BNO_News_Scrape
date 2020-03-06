bn_strip_time = function(raw_data){
  strip_time = sapply(raw_data$text, str_split, pattern = ':')
  
  text = c()
  for (s in strip_time){
    
    full_text = s[3]
    
    full_text = gsub("\\s*\\([^\\)]+\\)","", full_text)
  
    text = append(text, full_text)

  }
  
  raw_data$text = text
  
  return(raw_data)
  
}