bn_extract_new_cases = function(clean_text){
  
  
  for (s in clean_text$text){
    print(grep(s, pattern='\bnew case\b'))
  }
  
}