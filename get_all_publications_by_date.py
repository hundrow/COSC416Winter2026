import json
import requests
import time 
import math
from datetime import date

#year = date.today().year
year = 2022
url_base = 'https://api.archives-ouvertes.fr/search?rows=10000'

while True:
    start = 0
    count = 0
    num_found = 0
    #searching year by year, hopefully it doesnt time out or will have to change to 6 months or so
    url = f'{url_base}&start={start}&fq=submittedDateY_i:[{year} TO {year + 1}]'
    response = requests.get(url)
    data = response.json()
    
    if 'response' in data:
        data_response = data['response']
        num_found = data_response['numFound']
        print(f'found {num_found} entries for year {year}')
        #time.sleep(30)
        
        for page in range(math.ceil(num_found / 10000)):
            url = f'{url_base}&start={start}&fq=submittedDateY_i:[{year} TO {year + 1}]'
            response = requests.get(url)
            
            if 'response' in response.json():
                print(f'starting at entry: {start}, page number: {count}, for year: {year}')
                #time.sleep(30)
            elif 'error' in response.json():
                print(response.json())
                break
            
            filename = f'date_search/data_{year}_page_{count}.json'
            with open(filename, 'w') as f:
                json.dump(response.json(), f, indent=4)
            
            start += 10000
            count += 1
        year -= 1
                
    elif 'error' in data: 
        print(response.json())
        break 
    if year < 1:
        break