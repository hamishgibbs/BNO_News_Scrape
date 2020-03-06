#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar  4 09:30:21 2020

@author: hamishgibbs
"""

import requests
import pandas as pd

try:
    from bs4 import BeautifulSoup
except:
    print("PackageNotInstalledError: BeautifulSoup is not installed. Install using 'pip install bs4' or 'conda install bs4' in terminal")

from datetime import datetime
import re
import os
#%%
os.chdir('/Users/hamishgibbs/Documents/nCOV-2019/Connectivity_Analysis/BNO_News_Scrape/Test')
#%%
url_2 = 'https://docs.google.com/spreadsheets/d/e/2PACX-1vR30F8lYP3jG7YOq8es0PBpJIE5yvRVZffOyaqC0GgMBN6yt0Q-NI8pxS7hd1F9dYXnowSC6zpZmW9D/pubhtml/sheet?headers=false&gid=0'

r = requests.get(url_2)

soup = BeautifulSoup(r.text, 'html.parser')

#%%

def get_raw_table_data(soup):
    trs = soup.find_all('tbody')[0].find_all('tr')

    tr_data = []
    for tr in trs:
        tds = tr.find_all('td')
        
        td_data = []
        for td in tds:
            td_data.append(td.text)
        
        tr_data.append(td_data)
    
        
    return(tr_data)

def split_table_list_compression(list_compression):
    
    
    for i, l in enumerate(list_compression):
        if l == ['', '', '', '', '', '', '']:
            table_1_start = i
        
        if l == ['']:
            table_2_start = i
            
    
    t1 = pd.DataFrame.from_records(list_compression[table_1_start+1:table_2_start])
    t2 = pd.DataFrame.from_records(list_compression[table_2_start+1:])

    cols = ['location', 'cases', 'deaths', 'serious', 'critical', 'recovered', 'source']
    
    t1.columns = cols	
    t2.columns = cols

    t1.drop(0, inplace=True)
    t2.drop(0, inplace=True)
    
    t1.drop('source', axis=1, inplace=True)
    t2.drop('source', axis=1, inplace=True)

    t1.reset_index(inplace=True, drop=True)
    t2.reset_index(inplace=True, drop=True)
    
    t2 = t2.append(t1.loc[t1['location'] == 'CHINA TOTAL', :])
    
    #drop total row
    t2.drop([i for i, x in enumerate(t2['location'] == 'TOTAL') if x], axis=0, inplace=True)
    t1.drop([i for i, x in enumerate(t1['location'] == 'CHINA TOTAL') if x], axis=0, inplace=True)

    
    t2.loc[t2['location'] == 'CHINA TOTAL', 'location'] = 'China'
    t2.reset_index(inplace=True, drop=True)
    
    t1.replace(to_replace ="-", 
                 value = 0,
                 inplace=True) 
    
    t2.replace(to_replace ="-", 
                 value = 0,
                 inplace=True)
    
    return(t1, t2)
    

#%%
raw_list = get_raw_table_data(soup)

china_data_table, world_data_table = split_table_list_compression(raw_list)

#now: combine china counts into single df
