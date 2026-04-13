import json
import requests
import time 
import math
import datetime

year = datetime.date.today().year
#year = 2026
url_base = 'https://api.archives-ouvertes.fr/search?rows=10000&indent=true&wt=json&fl=label_s,abstract_s,docid,collection_t,uri_s,collCode_s,keyword_s,authFullName_s,title_s,domainAll_s,domainAllCode_s,en_domainAllCodeLabel_fs,fr_domainAllCodeLabel_fs,publicationDateY_i,publicationDateM_i,publicationDateD_i'
with open('get_all_publications_by_date_log.txt', 'a') as f:
    f.write(f'start time {datetime.datetime.now()} \n')

while True:
    start = 0
    count = 0
    num_found = 0
    #searching year by year, hopefully it doesnt time out or will have to change to 6 months or so
    with open('get_all_publications_by_date_log.txt', 'a') as f:
        f.write(f'  start time for year {year}: {datetime.datetime.now()} \n')
    url = f'{url_base}&start={start}&fq=submittedDateY_i:[{year} TO {year + 1}]'
    response = requests.get(url)
    data = response.json()
    
    if 'response' in data:
        data_response = data['response']
        num_found = data_response['numFound']
        print(f'found {num_found} entries for year {year}')
        #time.sleep(30)
        
        for page in range(math.ceil(num_found / 10000)):
            with open('get_all_publications_by_date_log.txt', 'a') as f:
                f.write(f'      {year} page: {count} time: {datetime.datetime.now()} \n')
            url = f'{url_base}&start={start}&fq=submittedDateY_i:[{year} TO {year + 1}]'
            response = requests.get(url)
            
            if 'response' in response.json():
                print(f'starting at entry: {start}, page number: {count}, for year: {year}')
                #time.sleep(30)
            elif 'error' in response.json():
                print(response.json())
                break
            
            filename = f'/mnt/database_data/date_full_search/data_{year}_page_{count}.json'
            with open(filename, 'w') as f:
                json.dump(response.json(), f, indent=4, ensure_ascii=False)
            
            start += 10000
            count += 1
        
        with open('get_all_publications_by_date_log.txt', 'a') as f:
            f.write(f'  end time for year {year}: {datetime.datetime.now()} \n')
        year -= 1
                     
    elif 'error' in data: 
        print(response.json())
        break 
    if year < 1:
        break

with open('get_all_publications_by_date_log.txt', 'a') as f:
    f.write(f'end time {datetime.datetime.now()} \n\n\n')