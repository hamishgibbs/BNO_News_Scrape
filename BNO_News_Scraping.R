pacman::p_load(rvest,
               tidyverse)

source("./Functions/bn_list_elements.R")
source("./Functions/bn_return_raw_data_table.R")
source("./Functions/bn_strip_time_source.R")
source("./Functions/bn_extract_new_cases.R")



url_1 = 'https://bnonews.com/index.php/2020/01/timeline-coronavirus-epidemic/'

list_elements = bn_list_elements(read_html(url_1))
raw_data = bn_return_raw_data_table(list_elements)
time_strip = bn_strip_time(raw_data) 

bn_extract_new_cases(time_strip)

str_split(raw_data$text[4], ':')[[1]][3]



strip_time = sapply(raw_data$text, str_split, pattern = ':')

text = c()
for (s in strip_time){
  text = append(text, s[3])
}

text[1:10]

raw_data$text[581]

raw_data %>% 
  separate(text, ':')

?separate

data$date[1]


sapply(html_data, get_text)


html_data = read_html(url_1)

for (i in 1:100000){print(i)}
rm(text)
