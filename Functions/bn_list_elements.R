bn_list_elements = function(html){
  return(html %>% html_nodes(xpath = '//*[@id="mvp-content-main"]') %>% html_nodes('*'))
}