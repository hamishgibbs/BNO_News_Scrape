#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 28 23:30:36 2020

@author: hamishgibbs
"""

import requests
import pandas as pd
from bs4 import BeautifulSoup
from datetime import datetime
import re


#get list of countries to check that an identified country name is not actually a province
countries = ["AF|Afghanistan","AL|Albania","DZ|Algeria","AS|American Samoa","AD|Andorra","AO|Angola","AI|Anguilla","AQ|Antarctica","AG|Antigua And Barbuda","AR|Argentina","AM|Armenia","AW|Aruba","AU|Australia","AT|Austria","AZ|Azerbaijan","BS|Bahamas","BH|Bahrain","BD|Bangladesh","BB|Barbados","BY|Belarus","BE|Belgium","BZ|Belize","BJ|Benin","BM|Bermuda","BT|Bhutan","BO|Bolivia","BA|Bosnia And Herzegovina","BW|Botswana","BV|Bouvet Island","BR|Brazil","IO|British Indian Ocean Territory","BN|Brunei Darussalam","BG|Bulgaria","BF|Burkina Faso","BI|Burundi","KH|Cambodia","CM|Cameroon","CA|Canada","CV|Cape Verde","KY|Cayman Islands","CF|Central African Republic","TD|Chad","CL|Chile","CN|China","CX|Christmas Island","CC|Cocos (keeling) Islands","CO|Colombia","KM|Comoros","CG|Congo","CD|Congo, The Democratic Republic Of The","CK|Cook Islands","CR|Costa Rica","CI|Cote D'ivoire","HR|Croatia","CU|Cuba","CY|Cyprus","CZ|Czech Republic","DK|Denmark","DJ|Djibouti","DM|Dominica","DO|Dominican Republic","TP|East Timor","EC|Ecuador","EG|Egypt","SV|El Salvador","GQ|Equatorial Guinea","ER|Eritrea","EE|Estonia","ET|Ethiopia","FK|Falkland Islands (malvinas)","FO|Faroe Islands","FJ|Fiji","FI|Finland","FR|France","GF|French Guiana","PF|French Polynesia","TF|French Southern Territories","GA|Gabon","GM|Gambia","GE|Georgia","DE|Germany","GH|Ghana","GI|Gibraltar","GR|Greece","GL|Greenland","GD|Grenada","GP|Guadeloupe","GU|Guam","GT|Guatemala","GN|Guinea","GW|Guinea-bissau","GY|Guyana","HT|Haiti","HM|Heard Island And Mcdonald Islands","VA|Holy See (vatican City State)","HN|Honduras","HK|Hong Kong","HU|Hungary","IS|Iceland","IN|India","ID|Indonesia","IR|Iran","IQ|Iraq","IE|Ireland","IL|Israel","IT|Italy","JM|Jamaica","JP|Japan","JO|Jordan","KZ|Kazakstan","KE|Kenya","KI|Kiribati","KP|Korea, Democratic People's Republic Of","KR|South Korea","KV|Kosovo","KW|Kuwait","KG|Kyrgyzstan","LA|Lao People's Democratic Republic","LV|Latvia","LB|Lebanon","LS|Lesotho","LR|Liberia","LY|Libyan Arab Jamahiriya","LI|Liechtenstein","LT|Lithuania","LU|Luxembourg","MO|Macau","MK|Macedonia, The Former Yugoslav Republic Of","MG|Madagascar","MW|Malawi","MY|Malaysia","MV|Maldives","ML|Mali","MT|Malta","MH|Marshall Islands","MQ|Martinique","MR|Mauritania","MU|Mauritius","YT|Mayotte","MX|Mexico","FM|Micronesia, Federated States Of","MD|Moldova, Republic Of","MC|Monaco","MN|Mongolia","MS|Montserrat","ME|Montenegro","MA|Morocco","MZ|Mozambique","MM|Myanmar","NA|Namibia","NR|Nauru","NP|Nepal","NL|Netherlands","AN|Netherlands Antilles","NC|New Caledonia","NZ|New Zealand","NI|Nicaragua","NE|Niger","NG|Nigeria","NU|Niue","NF|Norfolk Island","MP|Northern Mariana Islands","NO|Norway","OM|Oman","PK|Pakistan","PW|Palau","PS|Palestinian Territory, Occupied","PA|Panama","PG|Papua New Guinea","PY|Paraguay","PE|Peru","PH|Philippines","PN|Pitcairn","PL|Poland","PT|Portugal","PR|Puerto Rico","QA|Qatar","RE|Reunion","RO|Romania","RU|Russia","RW|Rwanda","SH|Saint Helena","KN|Saint Kitts And Nevis","LC|Saint Lucia","PM|Saint Pierre And Miquelon","VC|Saint Vincent And The Grenadines","WS|Samoa","SM|San Marino","ST|Sao Tome And Principe","SA|Saudi Arabia","SN|Senegal","RS|Serbia","SC|Seychelles","SL|Sierra Leone","SG|Singapore","SK|Slovakia","SI|Slovenia","SB|Solomon Islands","SO|Somalia","ZA|South Africa","GS|South Georgia And The South Sandwich Islands","ES|Spain","LK|Sri Lanka","SD|Sudan","SR|Suriname","SJ|Svalbard And Jan Mayen","SZ|Swaziland","SE|Sweden","CH|Switzerland","SY|Syrian Arab Republic","TW|Taiwan","TJ|Tajikistan","TZ|Tanzania, United Republic Of","TH|Thailand","TG|Togo","TK|Tokelau","TO|Tonga","TT|Trinidad And Tobago","TN|Tunisia","TR|Turkey","TM|Turkmenistan","TC|Turks And Caicos Islands","TV|Tuvalu","UG|Uganda","UA|Ukraine","AE|United Arab Emirates","GB|United Kingdom","US|United States","UM|United States Minor Outlying Islands","UY|Uruguay","UZ|Uzbekistan","VU|Vanuatu","VE|Venezuela","VN|Vietnam","VG|Virgin Islands, British","VI|Virgin Islands, U.s.","WF|Wallis And Futuna","EH|Western Sahara","YE|Yemen","ZM|Zambia","ZW|Zimbabwe"]
countries = [c.split('|')[1] for c in countries]


#list of usa states to assign country if only state is provided
usa_states = pd.read_csv('https://raw.githubusercontent.com/jasonong/List-of-US-States/master/states.csv')
usa_states = list(usa_states['State'])

#target URL
url_1 = 'https://bnonews.com/index.php/2020/01/timeline-coronavirus-epidemic/'
url_2 = 'https://bnonews.com/index.php/2020/02/the-latest-coronavirus-cases/'

r = requests.get(url_2)

#parse website html
soup = BeautifulSoup(r.text, 'html.parser')


last_scrape_non_matching = pd.read_csv('/Users/hamishgibbs/Dropbox/nCov-2019/data_sources/case_data/International_Case_Data_BNO/BNO_non_matching_text.csv', parse_dates=['date'], index_col = 0)
last_scrape = pd.read_csv('/Users/hamishgibbs/Dropbox/nCov-2019/data_sources/case_data/International_Case_Data_BNO/BNO_Scraped_Data.csv', parse_dates=['date'], index_col = 0)
most_recent_scrape_time = max(last_scrape['date'])

#find all date elements and list items in the html
dates = soup.find(id = 'mvp-content-main').find_all('h4')
list_data = soup.find(id = 'mvp-content-main').find_all('ul')[2:]

#save any sections of text that do not match patterns
non_matching_text = last_scrape_non_matching.to_dict(orient='records')
#non_matching_text = []
#save correctly formatted text data
scraped_data = last_scrape.to_dict(orient='records')

#scraped_data = []
#for each date header element in the html
for i, date in enumerate(dates):
    
    #extract and parse date text
    date = date.text + ' 2020'
    date = datetime.strptime(date, '%d %B %Y')
            
    #find all list items (held in 'ul' element under the date header)
    list_items = list_data[i].find_all('li')
    
    #for each list entry on this date
    for li in list_items: 
        
        #extract text
        li_text = li.text
        
        #ignore day totals
        if 'Total at the end of the day' in li_text:
            continue
        
        if 'China’s National Health Commission' in li_text:
            li_text = li_text.split(',')[0]
        
        if 'China’s National Health Committee' in li_text:
            li_text = li_text.split(',')[0]
        
        #count the number of period characters in the text
        number_of_periods = sum([c == '.' for c in li_text])
        
        #if the text is made up of multiple sentences, only parse the first senetence
        if number_of_periods > 1:
            li_text = li_text.split('.')[0]
        
        #reinitialize all search values to None to force error if one is not matched
        link = None
        new_case = None
        new_death = None
        time = None
        country = None
        territory = None
        
        #strip article time from list item text and update current datetime object
        #do not parse entries that have no time info at the start     
        
        try:
            news_date = date
            time = li_text[0:5].split(':')
            news_date = news_date.replace(hour = int(time[0]), minute = int(time[1]))

        except:
            continue
            
        #only update the dataset if this record has not been scraped yet
        if news_date < most_recent_scrape_time:
            continue

        
        #find new cases
        case_split = li_text.split('new case')
        
        #CURRENTLY - searching for strings that mention new cases once - some that mantion them twice are double counting
        if len(case_split) > 1 and len(case_split) < 3:
            for s in case_split:
                try:
                    new_case = re.search('[0-9]+ $', s).group(0)
                except:
                    pass  
                    
        #assign one new case for text referring to case numbers
        if 'First' in li.text and new_case == None:
            new_case = 1

        if 'New case' in li.text and new_case == None:
            new_case = 1
            
        #if no new cases are found, continue to search for deaths
        if new_case == None:
            new_case = 0

        #find new deaths
        death_split = li_text.split('new death')
        
        #CURRENTLY - searching for strings that mention new deaths once - some that mention twice are double counting
        if len(death_split) > 1 and len(death_split) < 3:
            for s in death_split:
                try:
                    new_death = re.search('[0-9]+ $', s).group(0)
                except:
                    pass  
        
        #if no new deaths are found, assign 0
        if new_death == None:
            new_death = 0
                   
        #parse location pattern
        location = li_text.split(' in ')
    
        #only parse location from one string         
        if len(location) >= 2 and len(location) < 3:
            location = location[1].split('.')[0]
            
            #try to split into country, territory tuple
            try:
                territory = location.split(', ')[0]
                country = location.split(', ')[1]
                
            #on exception, only assign country (no territory)
            except:
                country = location
                
                if territory == country:
                    territory = ''
                pass
        
        try:
            #replace miscellaneous text from country
            country = country.replace('the ', '')
            country = country.replace(' (Source)', '')
        except:
            pass
        
        #record countries that do not match an accepted country name
        if country not in countries:
            territory = country
            country = None
            
        #manually define country, territory combinations. Country is sometimes not mentioned with these
        if territory in ['Beijing', 'Shanghai', 'Hubei province', 'Hebei province']:
            country = 'China'
        
        if territory in ['England']:
            country = 'United Kingdom'
            
        if territory in usa_states:
            country = 'United States'
            
        if 'China’s National Health Commission' in li_text:
            country = 'China'
            territory = ''
            
        if 'China’s National Health Committee' in li_text:
            country = 'China'
            territory = ''
        
        #find link elements
        source = li.find_all('a')
        
        try:
            link = source[0]['href']
        except:
            link = ''
            #extract url from link element
        
        if new_case == 0 and new_death == 0:
            new_case = None
        
        if 'previously reported' in li_text:
            new_case = None
        
        #if any of the desired data is not identified for this list item, store in non_matching_text
        if None in [link, new_case, new_death, country, territory]:
            
            #print(link, new_case, new_death, country, territory)
            
            non_matching_text.append({'date':news_date, 'source':link, 'text':li.text})
            continue
        else:
            scraped_data.append({'date':news_date, 
                                 'new_case':new_case,
                                 'new_death': new_death,
                                 'country': country,
                                 'territory': territory,
                                 'link':link})   
#save data to csvs   
sd = pd.DataFrame(scraped_data)
sd.to_csv('/Users/hamishgibbs/Dropbox/nCov-2019/data_sources/case_data/International_Case_Data_BNO/BNO_Scraped_Data.csv')    
pd.DataFrame(non_matching_text).to_csv('/Users/hamishgibbs/Dropbox/nCov-2019/data_sources/case_data/International_Case_Data_BNO/BNO_non_matching_text.csv')    

sd.drop(['territory', 'link'], axis=1, inplace=True)

country_col = []
for country in sd.country:
    if country == 'China':
        country_col.append('China')
    else:
        country_col.append('International')
sd['country'] = country_col

sd.to_csv('/Users/hamishgibbs/Dropbox/nCov-2019/data_sources/case_data/International_Case_Data_BNO/BNO_Scraped_International.csv')
