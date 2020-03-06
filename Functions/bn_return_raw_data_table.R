bn_return_raw_data_table = function(list_elements){
  
  dates = c()
  text = c()
  
  for (node in list_elements){

    if ((html_name(node) %in% c('h4', 'p')) & (!grepl('The following is a timeline of new cases in China', html_text(node)))){
      date = as.Date(html_text(node), '%d %B')
      
      print(date)
    }
    
    if (html_name(node) == 'li'){
      
      li = html_text(node)
      
      time = parse_datetime(paste0(date, ' ' , substr(li, 1, 5)), format = '%Y-%m-%d %I:%M')
      print(time)
      
    }
    
    if (!is.na(time) & (!html_text(node) %in% c('Source', 'Source 1', 'Source 2'))){
      
      dates = append(dates, date)
      text = append(text, html_text(node))
      
    }
  }
  
  return(tibble(date = dates, text = text))
}